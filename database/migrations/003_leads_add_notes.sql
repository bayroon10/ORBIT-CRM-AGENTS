-- Migración 003: leads — agregar columna notes
-- Fecha: 2026-07-31
-- Tarea: HALLAZGO-02 (docs/DATA_CONTRACTS.md) — el formulario de creación de leads
--   enviaba `notes` en el payload pero la columna no existía en la tabla, resultando
--   en persistencia silenciosa (Supabase descartaba el campo sin error).
-- Decisión: agregar TEXT NULL para preservar backward-compat con leads existentes.
-- Reversible: ver sección ROLLBACK al final.
-- Aplicación: Supabase SQL Editor o CLI (`supabase db push`).

BEGIN;

ALTER TABLE public.leads
  ADD COLUMN IF NOT EXISTS notes TEXT NULL;

COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- ROLLBACK (solo si ningún lead tiene notas aún):
--   ALTER TABLE public.leads DROP COLUMN IF EXISTS notes;
-- ─────────────────────────────────────────────────────────────────────────────
