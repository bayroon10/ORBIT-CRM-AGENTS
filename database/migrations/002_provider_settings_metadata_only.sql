-- Migración 002: provider_settings metadata-only (RFC-0001, Opción B)
-- Fecha: 2026-06-29
-- Tarea: T-SEC-01 (hallazgo SEC-01) — eliminar almacenamiento de credenciales en texto plano.
-- Decisión (RFC-0001 aprobado): el secreto se gestiona en n8n Credentials.
--   provider_settings pasa a guardar SOLO metadata del proveedor.
-- Reversible: la tabla está vacía (rows: 0) al momento del diseño. Reversión al final.
-- Aplicación: mediante el proceso de migración del proyecto (Supabase SQL Editor / CLI).
--   NOTA: este archivo NO fue ejecutado automáticamente; requiere aplicación explícita
--   y debe desplegarse en el mismo release que los cambios de frontend asociados
--   (credential_value es NOT NULL: sin esta migración, los INSERT del frontend fallarían).

BEGIN;

-- 1) Eliminar la función de enmascarado: ya no existe secreto que enmascarar.
DROP FUNCTION IF EXISTS public.get_masked_credential(uuid);

-- 2) Eliminar la columna de secreto en texto plano (raíz de SEC-01).
ALTER TABLE public.provider_settings DROP COLUMN IF EXISTS credential_value;

COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK (manual; solo si fuese necesario y mientras la tabla siga vacía):
--   ALTER TABLE public.provider_settings
--     ADD COLUMN credential_value text NOT NULL DEFAULT '';
--   ALTER TABLE public.provider_settings
--     ALTER COLUMN credential_value DROP DEFAULT;
--   -- Recrear get_masked_credential desde 001_add_get_masked_credential.sql
-- ─────────────────────────────────────────────────────────────────────────────
