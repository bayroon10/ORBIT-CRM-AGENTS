-- T-ARC-02 Migración A: copiar las 3 filas legacy de public.cotizaciones
-- hacia el modelo canónico public.quotes, sin eliminar el origen todavía.
--
-- Referencia: docs/rfc/RFC-0003-modelo-dominio-es-en.md §8 (plan) y §9
-- (decisiones del Owner: ownership fijo y semántica de métrica).
--
-- Esta migración es SOLO COPIA. No hace DROP/DELETE/TRUNCATE de
-- cotizaciones ni ventas. La eliminación de las tablas legacy es
-- Migración B, con aprobación separada, después de un período de
-- observación.
--
-- Precondiciones verificadas en vivo inmediatamente antes de escribir
-- esta migración (2026-07-22, kgrfhfwtcanthrymmvkb):
--   - cotizaciones = 3 filas, ventas = 0, quotes = 0.
--   - 0 referencias huérfanas (oportunidad_id -> deals).
--   - 0 colisiones de id y de numero_cotizacion contra quotes.
--   - profiles.id = '83c12ae6-0d10-4392-b3fc-cda014dd8a64' existe
--     (Administrador General, ownership aprobado en RFC-0003 §9.1).
--   - quotes_status_check acepta exactamente:
--     draft, sent, accepted, rejected, expired.
--
-- Mapeo de columnas (RFC-0003 §8.3):
--   id                 -> id                (UUID legacy preservado)
--   oportunidad_id      -> deal_id
--   numero_cotizacion   -> quote_number
--   monto_cotizado      -> amount
--   fecha_emision       -> issue_date
--   fecha_validez       -> valid_until
--   estado_cotizacion   -> status            (traducción ES -> EN)
--   fecha_creacion      -> created_at
--   (sin origen)        -> owner_id          (fijo, aprobado en §9.1)

-- Guard explícito: aborta la migración completa si aparece un estado
-- legacy no cubierto por el mapeo ES->EN aprobado. Se implementa como
-- una excepción real en PL/pgSQL, separada de la expresión CASE del
-- INSERT, para no forzar unificación de tipos entre las ramas del CASE.
DO $$
DECLARE
  unmapped_count integer;
BEGIN
  SELECT COUNT(*) INTO unmapped_count
  FROM public.cotizaciones
  WHERE estado_cotizacion::text NOT IN ('borrador', 'enviada', 'aceptada', 'rechazada', 'expirada');

  IF unmapped_count > 0 THEN
    RAISE EXCEPTION 'T-ARC-02: % fila(s) de cotizaciones con estado_cotizacion no mapeado a quotes.status', unmapped_count;
  END IF;
END;
$$;

INSERT INTO public.quotes (
  id,
  deal_id,
  quote_number,
  amount,
  issue_date,
  valid_until,
  status,
  owner_id,
  created_at
)
SELECT
  c.id,
  c.oportunidad_id,
  c.numero_cotizacion,
  c.monto_cotizado,
  c.fecha_emision,
  c.fecha_validez,
  CASE c.estado_cotizacion::text
    WHEN 'borrador'  THEN 'draft'
    WHEN 'enviada'   THEN 'sent'
    WHEN 'aceptada'  THEN 'accepted'
    WHEN 'rechazada' THEN 'rejected'
    WHEN 'expirada'  THEN 'expired'
  END,
  '83c12ae6-0d10-4392-b3fc-cda014dd8a64',
  c.fecha_creacion
FROM public.cotizaciones c;
