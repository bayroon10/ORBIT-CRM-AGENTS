# Orbit CRM — AGENTS.md

## Stack

Vue 3 (Composition API, `<script setup>`), Vue Router 4, Vite 5, Tailwind CSS 3, GSAP 3, Supabase (PostgreSQL + Auth). Plain JS, no TS, no Pinia.

## Commands

```sh
npm run dev      # Vite dev server
npm run build    # Vite production build
npm run preview  # Preview production build
```

No lint, format, typecheck, or test commands exist.

## Project structure

```
src/
  main.js            # Entry: createApp + router
  lib/supabase.js    # Supabase client (reads VITE_SUPABASE_* from .env)
  router/index.js    # Routes + auth guard (supabase.auth.getSession)
  layouts/           # AppLayout (sidebar + header + router-view), AuthLayout (centered)
  views/             # 14 pages (Login, Dashboard, Leads, LeadDetail, Deals, DealDetail,
                     # Companies, Tasks, Quotes, QuoteForm, Sales, Activity, Settings, SettingsUsers)
  components/        # OrbitSidebar, OrbitHeader, OrbitPageHeader, OrbitMetricCard, OrbitEmptyState, OrbitModal
  styles/index.css   # @tailwind base/components/utilities
database/            # SQL backups (schema/, seed/, policies/, workflows/) — live DB is on Supabase
orbit-design-system/ # Design assets from Stitch (HTML mockups, screenshots, audit)
```

## Key conventions

- `@` alias → `./src` (configured in vite.config.js)
- UI text is **Spanish**. `index.html` has `lang="es"`
- Format locale: `es-CL` (Chile) — used in `Intl.DateTimeFormat` and `Intl.NumberFormat`
- Components prefixed `Orbit*`, PascalCase, single-file `.vue`
- Props via `defineProps` (no TS, no prop type imports)
- Import supabase as `import { supabase } from '../lib/supabase'` per-view (no composable wrapper)
- All routes under `AppLayout` have `meta: { requiresAuth: true }`
- Login uses `supabase.auth.signInWithPassword`, with open-redirect sanitization on `redirect` param
- Logout calls `supabase.auth.signOut()` then `router.push({ name: 'Login' })`
- Route names match view PascalCase: `'Login'`, `'Dashboard'`, `'Leads'`, `'LeadDetail'`, etc.
- Sidebar uses `<router-link>` with `active-class` for active nav state
- GSAP used for page transitions (`AppLayout` `<Transition>` with `gsap.fromTo`) and dashboard metric counter animations
- `OrbitModal`: `v-model` controlled, uses `Teleport` + `Transition` for backdrop/modal
- 404 catch-all (`/:pathMatch(.*)*`) redirects to `{ name: 'Dashboard' }`
- Tailwind colors defined in `tailwind.config.js`: `primary`, `surface`, `text`, `danger`, `success`, `border`

## View state patterns

Every view follows: `loading → error → empty → data`:
- `loading` ref → skeleton/spinner shown while fetching
- `error` ref → danger banner above content
- `OrbitEmptyState` component when data is empty
- `OrbitPageHeader` component with optional `#actions` slot for buttons

## Supabase

- Project: `kgrfhfwtcanthrymmvkb`
- Auth: email/password only
- Tables: `profiles`, `companies`, `leads`, `deals`, `tasks`, `activities`
- RLS: admins see all; sellers manage own leads/deals; tasks scoped to assigned user
- Profile auto-created via trigger on `auth.users` insert
- `.env` requires `VITE_SUPABASE_URL` + `VITE_SUPABASE_ANON_KEY`
- `database/` is local SQL backups only (schema, seed, RLS policies); schema/seed/policy changes go against live Supabase
- `database/workflows/` contains an n8n workflow export (external automation, not part of the Vue app)
