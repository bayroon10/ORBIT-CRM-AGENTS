# Orbit CRM — AGENTS.md

## Stack

Vue 3 (Composition API, `<script setup>`), Vue Router 4, Vite 5, Tailwind CSS 3, GSAP 3, Supabase (PostgreSQL + Auth). Plain JS, no TS, no Pinia.

## Commands

```sh
npm run dev      # Vite dev server (port 5173)
npm run build    # Vite production build (requires .env with 4 vars)
npm run preview  # Preview production build
docker-compose up -d   # Start n8n (5678) + ngrok tunnel
```

No lint/format/typecheck. Playwright in deps but no test runner. Ad-hoc QA scripts in `qa-scripts/` (Node .mjs/.cjs, gitignored, local-only).

## Conventions

- `@` alias → `./src`
- UI text **Spanish**, locale `es-CL`
- Components PascalCase, `.vue` SFCs, `defineProps` plain JS
- Supabase: `import { supabase } from '../lib/supabase'`
- Route names match view PascalCase (e.g. `'LeadDetail'`)
- Admin-only routes use `meta: { requiresAdmin: true }` — guard checks `profiles.role` via `AuthService.getUserRole()` (NOT `user_metadata.role`, see T-SEC-03 in `src/services/auth.service.js`)
- Admin-equivalent roles (see `isAdmin()` in `src/constants/roles.js`): `admin`, `superadmin`, `owner`
- 404 catch-all redirect → `{ name: 'Dashboard' }`
- `.env` needs 4 vars: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_N8N_WEBHOOK_URL`, `VITE_N8N_WEBHOOK_SECRET` . Also needs `NGROK_DOMAIN` for the ngrok tunnel
- Docker and frontend **share `.env`** — docker-compose.yml uses `env_file: .env` (not `.env.n8n`)
- `.env.n8n` is a gitignored reference template (timezone, WEBHOOK_URL) for n8n, but docker-compose does not wire it; n8n CORS (`N8N_CORS_ALLOW_ORIGIN`) must be set manually if needed
- GSAP: `nextTick(() => gsap.fromTo(...))` via `watch(loading)` in Dashboard.vue for metric cards + agent sections. Also has directives `v-fade-in` and `v-slide-up` in `src/plugins/animations.plugin.js`
- Tailwind semantic colors: `primary`, `surface`, `text`, `danger`, `success`, `border`, `warning`
- View pattern: `loading` ref → spinner, `error` ref → danger banner, `OrbitEmptyState` when empty, `OrbitPageHeader` with optional `#actions` slot

## Supabase

Project `kgrfhfwtcanthrymmvkb`. Auth: email/password. Tables: `profiles`, `companies`, `leads`, `deals`, `tasks`, `activities`, `quotes`, `whatsapp_conversations`, `provider_settings`, `workspace_settings`, `automations`, `automation_logs`.
RLS: admins see all; sellers manage own leads/deals; tasks scoped to assigned user. Profile auto-created via trigger on `auth.users` insert.

`database/` directory holds schema/policies/seed SQL as **backup only** — the live DB is on remote Supabase. Some tables (e.g. `quotes`, `whatsapp_conversations`) exist only on remote, not in local schema files.

**CRITICAL: Local schema files are stale.** Live Supabase schema has diverged:
- `leads`: live uses `full_name` (not `name`), adds `ai_score`, `ai_category`, `ai_summary`, `ai_next_step`, `ai_analyzed_at`
- `deals`: live uses `title` (not `name`), `value` (not `amount`), `stage` (not `status`), adds `probability`, `expected_close`, `stalled`, `ai_risk_score`, `ai_risk_factors`, `ai_analyzed_at`
- Always trust queries in `src/services/*.service.js` or the live DB over local SQL files.

Deals service uses explicit join delimiters (`companies!company_id(name)`) to avoid PGRST201 errors.

Realtime subscriptions (3):
1. `Activity.vue`: `postgres_changes` on `activities` (prepend feed + GSAP animation). Requires `ALTER TABLE activities REPLICA IDENTITY FULL;` and `ALTER PUBLICATION supabase_realtime ADD TABLE activities;`
2. `useRealtimeAlerts` composable: `postgres_changes` on `leads` INSERT, `ai_score >= 70` → toast via `OrbitToastContainer`
3. `whatsapp.service.js`: `postgres_changes` on `whatsapp_conversations` INSERT → callback

## n8n

- Docker Compose (`docker-compose up -d`), image `n8nio/n8n:1.72.0`, port 5678. Also starts `orbit_ngrok` (ngrok tunnel sibling)
- `.env.n8n` from `.env.n8n.example`. CORS configured for `http://localhost:5173` (set manually in n8n UI or via `N8N_CORS_ALLOW_ORIGIN` env var)
- Secrets (Gemini API Key, Supabase Service Role Key) go in n8n UI Credentials, never in `.env.n8n`
- **Read `SKILL_N8N.md` before modifying workflows** — critical: `maxOutputTokens: 2000` for Gemini 2.5 Flash, `service_role` for Supabase mutations, `=` prefix for expressions, `typeVersion` differences on Set nodes
- LeadDetail.vue auto-falls back from `/webhook/` to `/webhook-test/` when production endpoint fails
- Workflow JSON files live in `n8n/workflows/`; import via `docker cp` JSON → container, then `n8n import:workflow`

## Reference

- `ARCHITECTURE.md` — system overview, data model, AI lead scoring pipeline, design system details
- `SKILL_N8N.md` — n8n workflow creation rules and production lessons
- `database/` — stale schema backup only; trust service files or live DB
- `database/migrations/` — sequential SQL migration files; apply manually via Supabase SQL Editor

## Project

Portfolio project (CONTRIBUTING.md) — expected flow is fork → customize → deploy. No collaborative workflow.

## CI/CD

`.github/workflows/ci.yml` — `npm ci` + `npm run build` on push/PR to `main`. Placeholder env vars. No deploy step.
