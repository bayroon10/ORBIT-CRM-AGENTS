-- ============================================================================
-- Migration 003: Fix F-SEC-01 (privilege escalation) + F-SEC-02 (search_path)
-- ============================================================================
-- Contexto:
--   F-SEC-01: handle_new_user() asignaba el rol del perfil desde
--   new.raw_user_meta_data->>'role', permitiendo que un usuario que se
--   auto-registra envie role: 'admin' en el signup y obtenga un perfil
--   admin (escalada de privilegios).
--
--   F-SEC-02: 4 de 5 funciones SECURITY DEFINER no fijaban search_path,
--   exponiendolas a "search_path hijacking" (un objeto malicioso creado en
--   otro schema podria resolverse antes que "public").
--
-- Alcance: SOLO CREATE OR REPLACE FUNCTION. Sin DROP/DELETE/TRUNCATE.
-- Cada firma (nombre, parametros, tipo de retorno, LANGUAGE, SECURITY
-- DEFINER) se preserva exactamente igual a la definicion vigente en la
-- base de datos (verificado contra el dump de backup
-- pre-fsec-01-02-20260717_141128.sql).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Fix F-SEC-01: el rol del perfil creado en signup SIEMPRE es 'seller',
-- sin importar lo que el usuario envie en raw_user_meta_data. La promocion
-- a otros roles (admin, superadmin, etc.) debe hacerse exclusivamente via
-- UPDATE directo a profiles, ejecutado por un admin ya autenticado.
-- Fix F-SEC-02: se agrega SET search_path = public, pg_temp (igual que
-- ya tiene is_admin()).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.email),
    'seller' -- Fix F-SEC-01: rol fijo, nunca desde raw_user_meta_data.
  );
  RETURN new;
END;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

-- ----------------------------------------------------------------------------
-- Fix F-SEC-02: agregar search_path fijo. Sin cambios de logica.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "public"."auth_tenant_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$;

ALTER FUNCTION "public"."auth_tenant_id"() OWNER TO "postgres";

-- ----------------------------------------------------------------------------
-- Fix F-SEC-02: agregar search_path fijo. Sin cambios de logica
-- (incluye la misma URL de webhook ngrok que ya estaba en la definicion
-- vigente; no se toca en esta migracion, fuera de alcance de F-SEC-01/02).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "public"."invoke_n8n_webhook"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$ BEGIN PERFORM net.http_post(url := 'https://a80f-2803-c180-2000-62ae-38d0-18e7-3fd5-78a6.ngrok-free.app/webhook/lead-qualifier', body := jsonb_build_object('record', row_to_json(NEW)), headers := '{Content-Type: application/json}'::jsonb); RETURN NEW; END; $$;

ALTER FUNCTION "public"."invoke_n8n_webhook"() OWNER TO "postgres";

-- ----------------------------------------------------------------------------
-- Fix F-SEC-02: agregar search_path fijo. Sin cambios de logica.
-- NOTA (fuera de alcance de esta migracion, reportado por separado): el
-- fallback a auth.jwt() -> 'user_metadata' ->> 'role' sigue siendo
-- user-controllable en signup, igual que F-SEC-01 lo era para profiles.role.
-- No se modifica aqui porque el plan aprobado solo autoriza SET search_path
-- en esta funcion; requiere su propio fix con aprobacion explicita.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "public"."is_admin_or_higher"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT COALESCE(
    -- 1. Intenta validar contra la columna 'role' en la tabla profiles
    (SELECT role IN ('admin', 'superadmin', 'owner') FROM public.profiles WHERE id = auth.uid() LIMIT 1),
    -- 2. Fallback: Revisa los metadatos del JWT asignados en la autenticación
    (auth.jwt() -> 'user_metadata' ->> 'role') IN ('admin', 'superadmin', 'owner'),
    -- 3. Por defecto desautoriza si no encuentra ninguna
    false
  );
$$;

ALTER FUNCTION "public"."is_admin_or_higher"() OWNER TO "postgres";