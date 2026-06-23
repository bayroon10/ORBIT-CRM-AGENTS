# Orbit CRM — AGENTS.md

## Stack

Vue 3 (Composition API, `<script setup>`), Vue Router 4, Vite 5, Tailwind CSS 3, GSAP 3, Supabase (PostgreSQL + Auth). Plain JS, no TS, no Pinia.

## Commands

```sh
npm run dev      # Vite dev server (port 5173)
npm run build    # Vite production build (requires .env with 4 vars)
npm run preview  # Preview production build
```

No lint/format/typecheck. Playwright in devDependencies but no test runner config — ad-hoc QA scripts in `qa-scripts/` (Node .mjs/.cjs files hitting Supabase directly).

## Conventions

- `@` alias → `./src`
- UI text **Spanish**, locale `es-CL`
- Components PascalCase, `.vue` SFCs, `defineProps` with plain JS
- Supabase: `import { supabase } from '../lib/supabase'`
- Route names match view PascalCase (e.g. `'LeadDetail'`)
- Admin-only routes use `meta: { requiresAdmin: true }` — RBAC checks `user_metadata.role` in guard. Checking both `'admin'` and `'superadmin'`.
- 404 catch-all → `{ name: 'Dashboard' }`
- `.env` requires 4 vars: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_N8N_WEBHOOK_URL`, `VITE_N8N_WEBHOOK_SECRET`
- GSAP: `await nextTick()` before `gsap.fromTo` after reactive DOM inserts (feed rows in Activity.vue, metric counters). Also has GSAP custom directives: `v-fade-in` and `v-slide-up` in `src/plugins/animations.plugin.js`
- Tailwind semantic colors: `primary`, `surface`, `text`, `danger`, `success`, `border`, `warning`
- View pattern: `loading` ref → spinner, `error` ref → danger banner, `OrbitEmptyState` when empty, `OrbitPageHeader` with optional `#actions` slot

## Supabase

Project `kgrfhfwtcanthrymmvkb`. Auth: email/password. Tables: `profiles`, `companies`, `leads`, `deals`, `tasks`, `activities`, `quotes`, `provider_settings`, `workspace_settings`, `automations`, `automation_logs`.
RLS: admins see all; sellers manage own leads/deals; tasks scoped to assigned user. Profile auto-created via trigger on `auth.users` insert.

`database/` directory holds schema/policies/seed SQL as **backup only** — the live DB is on remote Supabase. Some tables (e.g. `quotes`) exist only on the remote instance, not in local schema files.

**CRITICAL: Local schema files are stale.** The live Supabase schema has diverged. Key column differences:
- `leads`: live uses `full_name` (not `name`), adds `ai_score`, `ai_category`, `ai_summary`, `ai_next_step`, `ai_analyzed_at`
- `deals`: live uses `title` (not `name`), `value` (not `amount`), `stage` (not `status`), adds `probability`, `expected_close`, `stalled`, `ai_risk_score`, `ai_risk_factors`, `ai_analyzed_at`
- Always trust queries in `src/services/*.service.js` or the live DB over local SQL files.

Realtime subscriptions (2):
1. `Activity.vue`: `postgres_changes` on `activities` (feed prepend + GSAP animation). Requires `ALTER TABLE activities REPLICA IDENTITY FULL;` and `ALTER PUBLICATION supabase_realtime ADD TABLE activities;`
2. `useRealtimeAlerts` composable: `postgres_changes` on `leads` (INSERT, `ai_score >= 70` → toast via `OrbitToastContainer`)

## n8n

- Docker Compose (`docker-compose up -d`), image `n8nio/n8n:1.72.0`, port 5678
- `.env.n8n` from `.env.n8n.example`. CORS configured for `http://localhost:5173` (Vite dev server)
- Secrets (Gemini API Key, Supabase Service Role Key) go in n8n UI Credentials, never in `.env.n8n`
- **Read `SKILL_N8N.md` before modifying workflows** — critical rules: `maxOutputTokens: 2000` for Gemini 2.5 Flash, `service_role` key for Supabase mutations (anon blocked by RLS), `=` prefix for n8n expressions, `typeVersion` differences on Set nodes

## Reference

- `ARCHITECTURE.md` — system overview, data model, AI lead scoring pipeline, design system details
- `SKILL_N8N.md` — n8n workflow creation rules and production lessons

## CI/CD

`.github/workflows/ci.yml` — `npm ci` + `npm run build` on push/PR to `main`. Placeholder env vars. No deploy step.
