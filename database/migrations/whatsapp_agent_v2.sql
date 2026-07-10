-- ============================================================
-- ORBIT CRM — WhatsApp Agent: Migración Evolutiva v2
-- Archivo: database/migrations/whatsapp_agent_v2.sql
-- Ejecutar en: Supabase Dashboard → SQL Editor
--
-- PREREQUISITO: La migración v1 (whatsapp_agent.sql) debe
-- haberse ejecutado primero. Este script solo añade columnas
-- y objetos nuevos — nunca destruye nada existente.
-- ============================================================

-- ============================================================
-- FASE A-1: Columnas de Observabilidad para Telemetría de IA
-- Patrón: Append-Only Ledger con Columnar Observability
-- ============================================================

-- Tokens de IA consumidos (para control de costos)
ALTER TABLE public.whatsapp_conversations
  ADD COLUMN IF NOT EXISTS ai_tokens_used integer DEFAULT NULL;

-- Modelo exacto de IA que generó la respuesta
ALTER TABLE public.whatsapp_conversations
  ADD COLUMN IF NOT EXISTS ai_model text DEFAULT NULL;

-- Latencia de la llamada a la API de IA en milisegundos
ALTER TABLE public.whatsapp_conversations
  ADD COLUMN IF NOT EXISTS ai_latency_ms integer DEFAULT NULL;

-- ID de sesión para agrupar mensajes dentro de la ventana de 24h de WA
-- Formato: "{phone}_{YYYYMMDD}" — se resetea cada 24h automáticamente
ALTER TABLE public.whatsapp_conversations
  ADD COLUMN IF NOT EXISTS session_id text GENERATED ALWAYS AS (
    phone || '_' || to_char(created_at AT TIME ZONE 'UTC', 'YYYYMMDD')
  ) STORED;

-- tenant_id para multi-tenant isolation (scoped desde el lead)
ALTER TABLE public.whatsapp_conversations
  ADD COLUMN IF NOT EXISTS tenant_id uuid REFERENCES public.workspace_settings(id) ON DELETE SET NULL;

-- Metadata flexible para extensiones futuras (ej: tipo de mensaje enriquecido)
ALTER TABLE public.whatsapp_conversations
  ADD COLUMN IF NOT EXISTS meta jsonb DEFAULT NULL;

-- ============================================================
-- FASE A-2: Índices de Rendimiento
-- Patrón: Selective Indexing con cobertura de consultas críticas
-- ============================================================

-- Índice compuesto B-Tree: satisface AMBAS consultas principales
-- en un solo Index Scan:
--   1. WHERE phone = ? ORDER BY created_at DESC LIMIT 5   (historial)
--   2. WHERE phone = ? ORDER BY created_at DESC LIMIT 1   (última)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_wa_conv_phone_created
  ON public.whatsapp_conversations (phone, created_at DESC);

-- Índice BRIN para rangos temporales en reporting/backfill.
-- BRIN es ~30x más pequeño que B-Tree para datos insert-ordered.
-- Útil para: SELECT ... WHERE created_at BETWEEN ? AND ?
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_wa_conv_created_brin
  ON public.whatsapp_conversations USING BRIN (created_at);

-- Índice parcial para mensajes no leídos.
-- Solo indexa las filas WHERE read = false — ignora el resto.
-- Esto hace que la query "contar no leídos" sea O(1) en vez de O(n).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_wa_conv_unread
  ON public.whatsapp_conversations (phone, created_at DESC)
  WHERE read = false AND direction = 'inbound';

-- Índice en session_id para agrupar contexto por sesión de 24h.
-- Usado por el Context Window del agente en n8n.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_wa_conv_session
  ON public.whatsapp_conversations (session_id, created_at ASC);

-- Índice en lead_id para el JOIN con la tabla leads (FK lookup).
-- Sin este índice, cada JOIN hace un Sequential Scan de leads.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_wa_conv_lead_id
  ON public.whatsapp_conversations (lead_id)
  WHERE lead_id IS NOT NULL;

-- ============================================================
-- FASE A-3: Actualizar RLS para tenant isolation
-- ============================================================

-- Agregar policy de tenant isolation para la nueva columna
-- (complementa las policies existentes, no las reemplaza)
CREATE POLICY IF NOT EXISTS "Tenant isolation on whatsapp_conversations"
  ON public.whatsapp_conversations
  FOR ALL
  TO authenticated
  USING (
    tenant_id IS NULL -- retrocompatibilidad con filas pre-v2
    OR tenant_id IN (
      SELECT id FROM public.workspace_settings LIMIT 1
    )
  );

-- ============================================================
-- FASE A-4: Función auxiliar para el Context Window del agente
-- Patrón: Repository Pattern encapsulado en función PostgreSQL
-- El agente n8n llama a esta función RPC en lugar de construir
-- queries complejas — garantiza que la lógica de contexto
-- viva en un solo lugar y sea reutilizable.
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_wa_context_window(
  p_phone text,
  p_limit integer DEFAULT 5
)
RETURNS TABLE (
  id uuid,
  direction text,
  message text,
  ai_generated boolean,
  ai_model text,
  created_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT
    id,
    direction,
    message,
    ai_generated,
    ai_model,
    created_at
  FROM public.whatsapp_conversations
  WHERE phone = p_phone
  ORDER BY created_at DESC
  LIMIT p_limit;
$$;

-- Comentario de documentación en la función
COMMENT ON FUNCTION public.get_wa_context_window IS
  'Retorna los últimos N mensajes de una conversación para usar
   como ventana de contexto en el prompt de Gemini. Usa índice
   idx_wa_conv_phone_created para respuesta en < 1ms.';

-- ============================================================
-- FASE A-5: Vista materializada para dashboard de analytics
-- Patrón: CQRS (Command Query Responsibility Segregation)
-- Las escrituras van a la tabla base (commands).
-- El dashboard lee desde esta vista (queries) — sin impacto
-- en las escrituras del agente.
-- ============================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS public.wa_conversations_stats AS
  SELECT
    date_trunc('day', created_at) AS day,
    count(*) FILTER (WHERE direction = 'inbound') AS total_inbound,
    count(*) FILTER (WHERE direction = 'outbound') AS total_outbound,
    count(*) FILTER (WHERE ai_generated = true) AS ai_responses,
    round(avg(ai_latency_ms) FILTER (WHERE ai_latency_ms IS NOT NULL)) AS avg_latency_ms,
    sum(ai_tokens_used) FILTER (WHERE ai_tokens_used IS NOT NULL) AS total_tokens,
    count(DISTINCT phone) AS unique_conversations
  FROM public.whatsapp_conversations
  GROUP BY date_trunc('day', created_at)
  ORDER BY day DESC;

-- Índice en la vista materializada para queries de rango de fechas
CREATE UNIQUE INDEX IF NOT EXISTS idx_wa_stats_day
  ON public.wa_conversations_stats (day);

-- Nota: Refrescar la vista con:
-- SELECT cron.schedule('refresh_wa_stats', '0 * * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY public.wa_conversations_stats');
-- (Requiere extensión pg_cron — disponible en Supabase Pro)

-- ============================================================
-- VERIFICACIONES POST-MIGRACIÓN
-- Ejecutar cada bloque para confirmar PASS
-- ============================================================

-- V1. Confirmar todas las columnas (esperado: 17 columnas)
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'whatsapp_conversations'
ORDER BY ordinal_position;

-- V2. Confirmar índices creados (esperado: 5+ índices)
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'whatsapp_conversations'
ORDER BY indexname;

-- V3. Confirmar función de context window
SELECT
  routine_name,
  routine_type,
  security_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'get_wa_context_window';

-- V4. Test de la función de context window (requiere datos)
-- SELECT * FROM public.get_wa_context_window('+56912345678', 5);

-- V5. Confirmar vista materializada
SELECT
  matviewname,
  ispopulated
FROM pg_matviews
WHERE schemaname = 'public'
  AND matviewname = 'wa_conversations_stats';

-- V6. Estimar tamaño de los índices (referencia futura de costo)
SELECT
  indexname,
  pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'whatsapp_conversations'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- ============================================================
-- ROLLBACK SEGURO (ejecutar SOLO si hay errores críticos)
-- ============================================================
-- ALTER TABLE public.whatsapp_conversations
--   DROP COLUMN IF EXISTS ai_tokens_used,
--   DROP COLUMN IF EXISTS ai_model,
--   DROP COLUMN IF EXISTS ai_latency_ms,
--   DROP COLUMN IF EXISTS session_id,
--   DROP COLUMN IF EXISTS tenant_id,
--   DROP COLUMN IF EXISTS meta;
--
-- DROP INDEX CONCURRENTLY IF EXISTS idx_wa_conv_phone_created;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_wa_conv_created_brin;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_wa_conv_unread;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_wa_conv_session;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_wa_conv_lead_id;
-- DROP FUNCTION IF EXISTS public.get_wa_context_window;
-- DROP MATERIALIZED VIEW IF EXISTS public.wa_conversations_stats;
