


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."estado_cotizacion" AS ENUM (
    'borrador',
    'enviada',
    'aceptada',
    'rechazada',
    'expirada'
);


ALTER TYPE "public"."estado_cotizacion" OWNER TO "postgres";


CREATE TYPE "public"."estado_oportunidad" AS ENUM (
    'lead',
    'contactado',
    'cotizado',
    'negociacion',
    'ganado',
    'perdido'
);


ALTER TYPE "public"."estado_oportunidad" OWNER TO "postgres";


CREATE TYPE "public"."prioridad_oportunidad" AS ENUM (
    'baja',
    'media',
    'alta'
);


ALTER TYPE "public"."prioridad_oportunidad" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auth_tenant_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$;


ALTER FUNCTION "public"."auth_tenant_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_quote_number"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  current_year TEXT := TO_CHAR(CURRENT_DATE, 'YYYY');
  next_seq INT;
BEGIN
  IF NEW.quote_number IS NULL OR NEW.quote_number = '' THEN
    SELECT COALESCE(MAX(CAST(SPLIT_PART(quote_number, '-', 3) AS INT)), 0) + 1
    INTO next_seq
    FROM public.quotes
    WHERE quote_number LIKE 'COT-' || current_year || '-%';
 
    NEW.quote_number := 'COT-' || current_year || '-' || LPAD(next_seq::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."generate_quote_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.email),
    coalesce(new.raw_user_meta_data->>'role', 'seller')
  );
  RETURN new;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."invoke_n8n_webhook"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$ BEGIN PERFORM net.http_post(url := 'https://a80f-2803-c180-2000-62ae-38d0-18e7-3fd5-78a6.ngrok-free.app/webhook/lead-qualifier', body := jsonb_build_object('record', row_to_json(NEW)), headers := '{Content-Type: application/json}'::jsonb); RETURN NEW; END; $$;


ALTER FUNCTION "public"."invoke_n8n_webhook"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND role = 'admin'
  );
END;
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin_or_higher"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
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


CREATE OR REPLACE FUNCTION "public"."update_deal_stage_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Si la etapa cambió explícitamente, refrescar el timestamp
  IF NEW.stage IS DISTINCT FROM OLD.stage THEN
    NEW.stage_updated_at = CURRENT_TIMESTAMP;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_deal_stage_timestamp"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."activities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type" "text",
    "description" "text",
    "lead_id" "uuid",
    "deal_id" "uuid",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tenant_id" "uuid"
);


ALTER TABLE "public"."activities" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."actividades" WITH ("security_invoker"='true') AS
 SELECT "id",
    "deal_id" AS "oportunidad_id",
    "type" AS "tipo_actividad",
    "description" AS "descripcion",
    "created_at" AS "fecha_actividad",
    NULL::"text" AS "resultado",
    "created_at" AS "fecha_creacion"
   FROM "public"."activities";


ALTER VIEW "public"."actividades" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."automation_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "automation_id" "uuid" NOT NULL,
    "status" "text" NOT NULL,
    "payload" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."automation_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."automations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT false NOT NULL,
    "config" "jsonb",
    "last_run_at" timestamp with time zone,
    "last_run_status" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."automations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."companies" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "industry" "text",
    "website" "text",
    "owner_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."companies" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."clientes" WITH ("security_invoker"='true') AS
 SELECT "id",
    "name" AS "nombre",
    "industry" AS "industria",
    NULL::character varying(100) AS "region",
    NULL::character varying(50) AS "tamano_empresa",
    "created_at" AS "fecha_creacion"
   FROM "public"."companies";


ALTER VIEW "public"."clientes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cotizaciones" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "oportunidad_id" "uuid" NOT NULL,
    "numero_cotizacion" character varying(50) NOT NULL,
    "monto_cotizado" numeric(12,2) NOT NULL,
    "fecha_emision" "date" NOT NULL,
    "fecha_validez" "date",
    "estado_cotizacion" "public"."estado_cotizacion" DEFAULT 'borrador'::"public"."estado_cotizacion",
    "fecha_creacion" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."cotizaciones" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."deals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "value" numeric DEFAULT 0,
    "stage" "text" DEFAULT 'prospecto'::"text",
    "probability" smallint DEFAULT 0,
    "expected_close" "date",
    "lead_id" "uuid",
    "company_id" "uuid",
    "owner_id" "uuid",
    "stalled" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "ai_risk_score" smallint,
    "ai_risk_factors" "text",
    "ai_analyzed_at" timestamp with time zone,
    "stage_updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "ai_risk_level" character varying(50),
    "ai_recommended_action" "text",
    "tenant_id" "uuid",
    CONSTRAINT "deals_ai_risk_score_check" CHECK ((("ai_risk_score" >= 0) AND ("ai_risk_score" <= 100))),
    CONSTRAINT "deals_ai_risk_score_range" CHECK ((("ai_risk_score" >= 0) AND ("ai_risk_score" <= 100))),
    CONSTRAINT "deals_probability_check" CHECK ((("probability" >= 0) AND ("probability" <= 100)))
);


ALTER TABLE "public"."deals" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."leads" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "full_name" "text" NOT NULL,
    "email" "text",
    "phone" "text",
    "source" "text" DEFAULT 'manual'::"text",
    "status" "text" DEFAULT 'nuevo'::"text",
    "owner_id" "uuid",
    "company_id" "uuid",
    "last_activity_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "ai_score" integer,
    "ai_category" character varying(10),
    "ai_summary" "text",
    "ai_next_step" "text",
    "ai_analyzed_at" timestamp with time zone,
    "company" "text",
    "notes" "text",
    "tenant_id" "uuid"
);


ALTER TABLE "public"."leads" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."oportunidades" WITH ("security_invoker"='true') AS
 SELECT "id",
    "company_id" AS "cliente_id",
    "owner_id" AS "vendedor_id",
    "title" AS "nombre_oportunidad",
        CASE
            WHEN ("stage" = 'prospecto'::"text") THEN 'lead'::"public"."estado_oportunidad"
            WHEN ("stage" = 'cotizado'::"text") THEN 'cotizado'::"public"."estado_oportunidad"
            WHEN ("stage" = 'negociando'::"text") THEN 'negociacion'::"public"."estado_oportunidad"
            WHEN ("stage" = 'ganado'::"text") THEN 'ganado'::"public"."estado_oportunidad"
            WHEN ("stage" = 'perdido'::"text") THEN 'perdido'::"public"."estado_oportunidad"
            ELSE 'lead'::"public"."estado_oportunidad"
        END AS "estado",
    "value" AS "monto_estimado",
    "probability" AS "probabilidad_cierre",
    "created_at" AS "fecha_creacion",
    "expected_close" AS "fecha_cierre_estimada",
        CASE
            WHEN ("stage" = ANY (ARRAY['ganado'::"text", 'perdido'::"text"])) THEN ("updated_at")::"date"
            ELSE NULL::"date"
        END AS "fecha_cierre_real",
    (EXTRACT(day FROM ("now"() - "updated_at")))::integer AS "dias_sin_actividad",
    'media'::"public"."prioridad_oportunidad" AS "prioridad"
   FROM "public"."deals";


ALTER VIEW "public"."oportunidades" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "full_name" "text",
    "role" "text" DEFAULT 'seller'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "tenant_id" "uuid",
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['admin'::"text", 'seller'::"text", 'support'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."provider_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "provider" "text" NOT NULL,
    "label" "text",
    "credential_type" "text" DEFAULT 'api_key'::"text" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "last_used_at" timestamp with time zone
);


ALTER TABLE "public"."provider_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."quotes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "deal_id" "uuid" NOT NULL,
    "quote_number" character varying(50) DEFAULT ''::character varying NOT NULL,
    "amount" numeric(12,2) DEFAULT 0.00 NOT NULL,
    "issue_date" "date" DEFAULT CURRENT_DATE NOT NULL,
    "valid_until" "date",
    "status" character varying(50) DEFAULT 'draft'::character varying,
    "owner_id" "uuid",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "quotes_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['draft'::character varying, 'sent'::character varying, 'accepted'::character varying, 'rejected'::character varying, 'expired'::character varying])::"text"[])))
);


ALTER TABLE "public"."quotes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" NOT NULL,
    "due_date" timestamp with time zone,
    "status" "text" DEFAULT 'pendiente'::"text",
    "lead_id" "uuid",
    "deal_id" "uuid",
    "assigned_to" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "priority" character varying(50),
    "description" "text",
    "tenant_id" "uuid",
    CONSTRAINT "check_priority" CHECK ((("priority")::"text" = ANY ((ARRAY['Alta'::character varying, 'Media'::character varying, 'Baja'::character varying])::"text"[])))
);


ALTER TABLE "public"."tasks" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vendedores" WITH ("security_invoker"='true') AS
 SELECT "id",
    "full_name" AS "nombre",
    NULL::character varying(255) AS "email",
    NULL::character varying(100) AS "zona",
    ("created_at")::"date" AS "fecha_ingreso",
    "created_at" AS "fecha_creacion"
   FROM "public"."profiles";


ALTER VIEW "public"."vendedores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ventas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "oportunidad_id" "uuid" NOT NULL,
    "cliente_id" "uuid" NOT NULL,
    "vendedor_id" "uuid" NOT NULL,
    "monto_venta" numeric(12,2) NOT NULL,
    "fecha_venta" "date" NOT NULL,
    "canal_venta" character varying(100),
    "fecha_creacion" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."ventas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."whatsapp_conversations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "lead_id" "uuid",
    "phone" "text" NOT NULL,
    "direction" "text" NOT NULL,
    "message" "text" NOT NULL,
    "wa_message_id" "text",
    "ai_generated" boolean DEFAULT false,
    "read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "owner_id" "uuid",
    CONSTRAINT "whatsapp_conversations_direction_check" CHECK (("direction" = ANY (ARRAY['inbound'::"text", 'outbound'::"text"])))
);

ALTER TABLE ONLY "public"."whatsapp_conversations" REPLICA IDENTITY FULL;


ALTER TABLE "public"."whatsapp_conversations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workspace_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "system_name" "text" DEFAULT 'Orbit CRM'::"text" NOT NULL,
    "timezone" "text" DEFAULT 'America/Santiago'::"text" NOT NULL,
    "locale" "text" DEFAULT 'es-CL'::"text" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."workspace_settings" OWNER TO "postgres";


ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."automation_logs"
    ADD CONSTRAINT "automation_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."automations"
    ADD CONSTRAINT "automations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cotizaciones"
    ADD CONSTRAINT "cotizaciones_numero_cotizacion_key" UNIQUE ("numero_cotizacion");



ALTER TABLE ONLY "public"."cotizaciones"
    ADD CONSTRAINT "cotizaciones_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."leads"
    ADD CONSTRAINT "leads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."provider_settings"
    ADD CONSTRAINT "provider_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_quote_number_key" UNIQUE ("quote_number");



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ventas"
    ADD CONSTRAINT "ventas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."whatsapp_conversations"
    ADD CONSTRAINT "whatsapp_conversations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workspace_settings"
    ADD CONSTRAINT "workspace_settings_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_activities_created_by" ON "public"."activities" USING "btree" ("created_by");



CREATE INDEX "idx_activities_deal" ON "public"."activities" USING "btree" ("deal_id");



CREATE INDEX "idx_activities_lead" ON "public"."activities" USING "btree" ("lead_id");



CREATE INDEX "idx_automation_logs_lookup" ON "public"."automation_logs" USING "btree" ("automation_id", "created_at" DESC);



CREATE INDEX "idx_companies_owner" ON "public"."companies" USING "btree" ("owner_id");



CREATE INDEX "idx_cotizaciones_oportunidad_id" ON "public"."cotizaciones" USING "btree" ("oportunidad_id");



CREATE INDEX "idx_deals_company" ON "public"."deals" USING "btree" ("company_id");



CREATE INDEX "idx_deals_lead" ON "public"."deals" USING "btree" ("lead_id");



CREATE INDEX "idx_deals_owner" ON "public"."deals" USING "btree" ("owner_id");



CREATE INDEX "idx_leads_company" ON "public"."leads" USING "btree" ("company_id");



CREATE INDEX "idx_leads_owner" ON "public"."leads" USING "btree" ("owner_id");



CREATE INDEX "idx_quotes_deal" ON "public"."quotes" USING "btree" ("deal_id");



CREATE INDEX "idx_quotes_owner" ON "public"."quotes" USING "btree" ("owner_id");



CREATE INDEX "idx_tasks_assigned" ON "public"."tasks" USING "btree" ("assigned_to");



CREATE INDEX "idx_tasks_deal" ON "public"."tasks" USING "btree" ("deal_id");



CREATE INDEX "idx_tasks_lead" ON "public"."tasks" USING "btree" ("lead_id");



CREATE INDEX "idx_ventas_cliente_id" ON "public"."ventas" USING "btree" ("cliente_id");



CREATE INDEX "idx_ventas_fecha_venta" ON "public"."ventas" USING "btree" ("fecha_venta");



CREATE INDEX "idx_ventas_oportunidad_id" ON "public"."ventas" USING "btree" ("oportunidad_id");



CREATE INDEX "idx_ventas_vendedor_id" ON "public"."ventas" USING "btree" ("vendedor_id");



CREATE OR REPLACE TRIGGER "trg_generate_quote_number" BEFORE INSERT ON "public"."quotes" FOR EACH ROW EXECUTE FUNCTION "public"."generate_quote_number"();



CREATE OR REPLACE TRIGGER "trigger_deal_stage_timestamp" BEFORE UPDATE ON "public"."deals" FOR EACH ROW EXECUTE FUNCTION "public"."update_deal_stage_timestamp"();



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "public"."deals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."automation_logs"
    ADD CONSTRAINT "automation_logs_automation_id_fkey" FOREIGN KEY ("automation_id") REFERENCES "public"."automations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."cotizaciones"
    ADD CONSTRAINT "cotizaciones_oportunidad_id_fkey" FOREIGN KEY ("oportunidad_id") REFERENCES "public"."deals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."deals"
    ADD CONSTRAINT "deals_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."leads"
    ADD CONSTRAINT "leads_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."leads"
    ADD CONSTRAINT "leads_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."leads"
    ADD CONSTRAINT "leads_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."companies"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."provider_settings"
    ADD CONSTRAINT "provider_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "public"."deals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_deal_id_fkey" FOREIGN KEY ("deal_id") REFERENCES "public"."deals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ventas"
    ADD CONSTRAINT "ventas_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "public"."companies"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."ventas"
    ADD CONSTRAINT "ventas_oportunidad_id_fkey" FOREIGN KEY ("oportunidad_id") REFERENCES "public"."deals"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."ventas"
    ADD CONSTRAINT "ventas_vendedor_id_fkey" FOREIGN KEY ("vendedor_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."whatsapp_conversations"
    ADD CONSTRAINT "whatsapp_conversations_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."whatsapp_conversations"
    ADD CONSTRAINT "whatsapp_conversations_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



CREATE POLICY "Activities tenant isolation" ON "public"."activities" USING ((("tenant_id" = "public"."auth_tenant_id"()) OR "public"."is_admin_or_higher"()));



CREATE POLICY "Admins can insert workspace settings" ON "public"."workspace_settings" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can update workspace settings" ON "public"."workspace_settings" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Admins full access whatsapp_conversations" ON "public"."whatsapp_conversations" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = ANY (ARRAY['admin'::"text", 'superadmin'::"text"]))))));



CREATE POLICY "Admins manage all quotes" ON "public"."quotes" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Allow authenticated read automation_logs" ON "public"."automation_logs" FOR SELECT TO "authenticated" USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Allow authenticated read automations" ON "public"."automations" FOR SELECT TO "authenticated" USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Allow authenticated update automations" ON "public"."automations" FOR UPDATE TO "authenticated" USING (("auth"."uid"() IS NOT NULL)) WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Anyone authenticated can view workspace settings" ON "public"."workspace_settings" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Automations admin only" ON "public"."automations" USING ("public"."is_admin_or_higher"());



CREATE POLICY "Deals tenant isolation" ON "public"."deals" USING ((("tenant_id" = "public"."auth_tenant_id"()) OR "public"."is_admin_or_higher"()));



CREATE POLICY "No one can delete workspace settings" ON "public"."workspace_settings" FOR DELETE USING (false);



CREATE POLICY "Sellers insert own quotes" ON "public"."quotes" FOR INSERT WITH CHECK (("owner_id" = "auth"."uid"()));



CREATE POLICY "Sellers see own lead conversations" ON "public"."whatsapp_conversations" FOR SELECT TO "authenticated" USING (("lead_id" IN ( SELECT "leads"."id"
   FROM "public"."leads"
  WHERE ("leads"."owner_id" = "auth"."uid"()))));



CREATE POLICY "Sellers update own quotes" ON "public"."quotes" FOR UPDATE USING (("owner_id" = "auth"."uid"()));



CREATE POLICY "Sellers view own quotes" ON "public"."quotes" FOR SELECT USING (("owner_id" = "auth"."uid"()));



CREATE POLICY "User can delete own activities" ON "public"."activities" FOR DELETE TO "authenticated" USING (("created_by" = "auth"."uid"()));



CREATE POLICY "User can insert own activities" ON "public"."activities" FOR INSERT TO "authenticated" WITH CHECK (("created_by" = "auth"."uid"()));



CREATE POLICY "User can manage assigned tasks" ON "public"."tasks" TO "authenticated" USING ((("assigned_to" = "auth"."uid"()) OR "public"."is_admin"())) WITH CHECK (("assigned_to" = "auth"."uid"()));



CREATE POLICY "User can manage own activities" ON "public"."activities" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));



CREATE POLICY "User can manage own companies" ON "public"."companies" TO "authenticated" USING (("owner_id" = "auth"."uid"())) WITH CHECK (("owner_id" = "auth"."uid"()));



CREATE POLICY "User can manage own deals" ON "public"."deals" TO "authenticated" USING ((("owner_id" = "auth"."uid"()) OR "public"."is_admin"())) WITH CHECK (("owner_id" = "auth"."uid"()));



CREATE POLICY "User can manage own leads" ON "public"."leads" TO "authenticated" USING ((("owner_id" = "auth"."uid"()) OR "public"."is_admin"())) WITH CHECK (("owner_id" = "auth"."uid"()));



CREATE POLICY "User can update own profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "User can view own or related activities" ON "public"."activities" FOR SELECT TO "authenticated" USING ((("created_by" = "auth"."uid"()) OR (("lead_id" IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."leads"
  WHERE (("leads"."id" = "activities"."lead_id") AND ("leads"."owner_id" = "auth"."uid"()))))) OR (("deal_id" IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."deals"
  WHERE (("deals"."id" = "activities"."deal_id") AND ("deals"."owner_id" = "auth"."uid"())))))));



CREATE POLICY "User can view own profile" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can manage their own provider settings" ON "public"."provider_settings" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can manage their own quotes" ON "public"."quotes" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."deals"
  WHERE (("deals"."id" = "quotes"."deal_id") AND ("deals"."owner_id" = "auth"."uid"())))));



ALTER TABLE "public"."activities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."automation_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."automations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cotizaciones" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."deals" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "delete_own_provider_settings" ON "public"."provider_settings" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "insert_own_provider_settings" ON "public"."provider_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."leads" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."provider_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."quotes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "select_own_provider_settings" ON "public"."provider_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."tasks" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "update_own_provider_settings" ON "public"."provider_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."ventas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."whatsapp_conversations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."workspace_settings" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."whatsapp_conversations";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."auth_tenant_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."auth_tenant_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auth_tenant_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_quote_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_quote_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_quote_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."invoke_n8n_webhook"() TO "anon";
GRANT ALL ON FUNCTION "public"."invoke_n8n_webhook"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."invoke_n8n_webhook"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin_or_higher"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin_or_higher"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin_or_higher"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_deal_stage_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_deal_stage_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_deal_stage_timestamp"() TO "service_role";


















GRANT ALL ON TABLE "public"."activities" TO "anon";
GRANT ALL ON TABLE "public"."activities" TO "authenticated";
GRANT ALL ON TABLE "public"."activities" TO "service_role";



GRANT ALL ON TABLE "public"."actividades" TO "anon";
GRANT ALL ON TABLE "public"."actividades" TO "authenticated";
GRANT ALL ON TABLE "public"."actividades" TO "service_role";



GRANT ALL ON TABLE "public"."automation_logs" TO "anon";
GRANT ALL ON TABLE "public"."automation_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."automation_logs" TO "service_role";



GRANT ALL ON TABLE "public"."automations" TO "anon";
GRANT ALL ON TABLE "public"."automations" TO "authenticated";
GRANT ALL ON TABLE "public"."automations" TO "service_role";



GRANT UPDATE("is_active") ON TABLE "public"."automations" TO "authenticated";



GRANT UPDATE("config") ON TABLE "public"."automations" TO "authenticated";



GRANT ALL ON TABLE "public"."companies" TO "anon";
GRANT ALL ON TABLE "public"."companies" TO "authenticated";
GRANT ALL ON TABLE "public"."companies" TO "service_role";



GRANT ALL ON TABLE "public"."clientes" TO "anon";
GRANT ALL ON TABLE "public"."clientes" TO "authenticated";
GRANT ALL ON TABLE "public"."clientes" TO "service_role";



GRANT ALL ON TABLE "public"."cotizaciones" TO "anon";
GRANT ALL ON TABLE "public"."cotizaciones" TO "authenticated";
GRANT ALL ON TABLE "public"."cotizaciones" TO "service_role";



GRANT ALL ON TABLE "public"."deals" TO "anon";
GRANT ALL ON TABLE "public"."deals" TO "authenticated";
GRANT ALL ON TABLE "public"."deals" TO "service_role";



GRANT ALL ON TABLE "public"."leads" TO "anon";
GRANT ALL ON TABLE "public"."leads" TO "authenticated";
GRANT ALL ON TABLE "public"."leads" TO "service_role";



GRANT ALL ON TABLE "public"."oportunidades" TO "anon";
GRANT ALL ON TABLE "public"."oportunidades" TO "authenticated";
GRANT ALL ON TABLE "public"."oportunidades" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "public"."provider_settings" TO "anon";
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "public"."provider_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."provider_settings" TO "service_role";



GRANT SELECT("id") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("user_id") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("provider") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("label") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("credential_type") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("is_active") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("created_at") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT SELECT("last_used_at") ON TABLE "public"."provider_settings" TO "authenticated";



GRANT ALL ON TABLE "public"."quotes" TO "anon";
GRANT ALL ON TABLE "public"."quotes" TO "authenticated";
GRANT ALL ON TABLE "public"."quotes" TO "service_role";



GRANT ALL ON TABLE "public"."tasks" TO "anon";
GRANT ALL ON TABLE "public"."tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."tasks" TO "service_role";



GRANT ALL ON TABLE "public"."vendedores" TO "anon";
GRANT ALL ON TABLE "public"."vendedores" TO "authenticated";
GRANT ALL ON TABLE "public"."vendedores" TO "service_role";



GRANT ALL ON TABLE "public"."ventas" TO "anon";
GRANT ALL ON TABLE "public"."ventas" TO "authenticated";
GRANT ALL ON TABLE "public"."ventas" TO "service_role";



GRANT ALL ON TABLE "public"."whatsapp_conversations" TO "anon";
GRANT ALL ON TABLE "public"."whatsapp_conversations" TO "authenticated";
GRANT ALL ON TABLE "public"."whatsapp_conversations" TO "service_role";



GRANT ALL ON TABLE "public"."workspace_settings" TO "anon";
GRANT ALL ON TABLE "public"."workspace_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."workspace_settings" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































