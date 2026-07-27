-- ============================================================================
-- Migration: Security Fixes (SEC-VULN-01, SEC-VULN-02, SEC-VULN-04)
-- ============================================================================
-- Contexto:
--   SEC-VULN-01: Se elimina la política 'Allow authenticated update automations'
--   en public.automations para que solo administradores ('Automations admin only')
--   puedan modificar automatizaciones.
--
--   SEC-VULN-02: Se actualizan las políticas 'User can manage own leads' y
--   'User can manage own deals' para incluir 'is_admin_or_higher()' en el WITH CHECK,
--   permitiendo a admins asignar/reasignar leads y deals a vendedores.
--
--   SEC-VULN-03: (No requiere DDL) 'ventas' es una tabla legacy sin uso en
--   componentes Vue ni servicios de frontend.
--
--   SEC-VULN-04: Se añade la columna n8n_webhook_url a public.workspace_settings
--   y se actualiza la función invoke_n8n_webhook() para leer dinámicamente
--   el webhook URL desde workspace_settings.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SEC-VULN-01: Restringir escritura en public.automations a Admins
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Allow authenticated update automations" ON "public"."automations";

-- ----------------------------------------------------------------------------
-- 2. SEC-VULN-02: Permitir a Admins gestionar leads y deals en WITH CHECK
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "User can manage own leads" ON "public"."leads";
CREATE POLICY "User can manage own leads" ON "public"."leads"
    TO "authenticated"
    USING ((("owner_id" = "auth"."uid"()) OR "public"."is_admin_or_higher"()))
    WITH CHECK ((("owner_id" = "auth"."uid"()) OR "public"."is_admin_or_higher"()));

DROP POLICY IF EXISTS "User can manage own deals" ON "public"."deals";
CREATE POLICY "User can manage own deals" ON "public"."deals"
    TO "authenticated"
    USING ((("owner_id" = "auth"."uid"()) OR "public"."is_admin_or_higher"()))
    WITH CHECK ((("owner_id" = "auth"."uid"()) OR "public"."is_admin_or_higher"()));

-- ----------------------------------------------------------------------------
-- 3. SEC-VULN-04: Mover URL de ngrok a public.workspace_settings
-- ----------------------------------------------------------------------------
ALTER TABLE "public"."workspace_settings"
    ADD COLUMN IF NOT EXISTS "n8n_webhook_url" "text"
    DEFAULT 'https://a80f-2803-c180-2000-62ae-38d0-18e7-3fd5-78a6.ngrok-free.app/webhook/lead-qualifier'::"text";

CREATE OR REPLACE FUNCTION "public"."invoke_n8n_webhook"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE
  target_url text;
BEGIN
  SELECT n8n_webhook_url INTO target_url FROM public.workspace_settings LIMIT 1;
  IF target_url IS NULL OR target_url = '' THEN
    target_url := 'https://a80f-2803-c180-2000-62ae-38d0-18e7-3fd5-78a6.ngrok-free.app/webhook/lead-qualifier';
  END IF;

  PERFORM net.http_post(
    url := target_url,
    body := jsonb_build_object('record', row_to_json(NEW)),
    headers := '{"Content-Type": "application/json"}'::jsonb
  );
  RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."invoke_n8n_webhook"() OWNER TO "postgres";
