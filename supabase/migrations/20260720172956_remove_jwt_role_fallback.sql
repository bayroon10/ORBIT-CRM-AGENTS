-- F-SEC-03: profiles.role is the only authorization source.
-- User-controlled JWT user_metadata must never grant elevated privileges.
CREATE OR REPLACE FUNCTION "public"."is_admin_or_higher"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  SELECT COALESCE(
    (SELECT role IN ('admin', 'superadmin', 'owner')
     FROM public.profiles
     WHERE id = auth.uid()
     LIMIT 1),
    false
  );
$$;

ALTER FUNCTION "public"."is_admin_or_higher"() OWNER TO "postgres";