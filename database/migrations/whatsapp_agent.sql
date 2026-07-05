-- ====================================================
-- ORBIT CRM — WhatsApp Agent Migration
-- Ejecutar en: https://supabase.com/dashboard/project/kgrfhfwtcanthrymmvkb/sql/new
-- ====================================================

-- A1. Crear tabla de conversaciones WhatsApp
CREATE TABLE IF NOT EXISTS public.whatsapp_conversations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id uuid REFERENCES public.leads(id) ON DELETE SET NULL,
  phone text NOT NULL,
  direction text NOT NULL CHECK (direction IN ('inbound', 'outbound')),
  message text NOT NULL,
  wa_message_id text,
  ai_generated boolean DEFAULT false,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  owner_id uuid REFERENCES auth.users(id) ON DELETE SET NULL
);

-- A2. Habilitar RLS
ALTER TABLE public.whatsapp_conversations ENABLE ROW LEVEL SECURITY;

-- A3. Policy: admins ven todo
CREATE POLICY "Admins full access whatsapp_conversations"
ON public.whatsapp_conversations
FOR ALL
TO authenticated
USING (
  (auth.jwt() -> 'user_metadata' ->> 'role') IN ('admin', 'superadmin')
);

-- A4. Policy: vendedores ven solo sus propios leads
CREATE POLICY "Sellers see own lead conversations"
ON public.whatsapp_conversations
FOR SELECT
TO authenticated
USING (
  lead_id IN (
    SELECT id FROM public.leads WHERE owner_id = auth.uid()
  )
);

-- A5. Habilitar Realtime para la tabla
ALTER TABLE public.whatsapp_conversations REPLICA IDENTITY FULL;

-- A6. Agregar tabla a publicación realtime (requerido por Supabase Realtime)
ALTER PUBLICATION supabase_realtime ADD TABLE public.whatsapp_conversations;

-- ====================================================
-- VERIFICACIONES (ejecutar después de la migración)
-- ====================================================

-- Confirmar columnas
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'whatsapp_conversations'
ORDER BY ordinal_position;

-- Confirmar RLS
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'whatsapp_conversations';

-- Confirmar policies
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'whatsapp_conversations';

-- ====================================================
-- B. Verificar estructura de provider_settings
-- ====================================================
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'provider_settings'
ORDER BY ordinal_position;

-- B2. Ver registros actuales
SELECT id, provider, is_active, created_at FROM provider_settings;

-- ====================================================
-- C. Crear registro de automation para WhatsApp Agent
-- ====================================================
INSERT INTO automations (name, status, type, description)
VALUES ('WhatsApp Agent', 'active', 'webhook', 'Agente IA que responde mensajes de WhatsApp automáticamente')
ON CONFLICT DO NOTHING
RETURNING id, name;

-- Verificar el UUID (necesario para el workflow de n8n)
SELECT id, name FROM automations WHERE name = 'WhatsApp Agent';
