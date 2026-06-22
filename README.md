# Orbit CRM

> AI-powered CRM for sales teams — lead scoring with Gemini 2.5 Flash, real-time activity feed, no-code automations via n8n. Built for LATAM.

![CI](https://github.com/placeholder-repo/workflows/CI/badge.svg) ![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg) ![Vue 3](https://img.shields.io/badge/Vue-3-success) ![Supabase](https://img.shields.io/badge/Supabase-Realtime-green)

## What makes Orbit different

- 🤖 **AI Lead Scoring** — Gemini 2.5 Flash scores every lead 1-10 with category (Hot/Warm/Cold) and recommended next action
- ⚡ **Real-time activity feed** — Supabase Realtime, zero polling
- 🔄 **No-code automations** — n8n visual workflow builder, pre-built Lead Qualifier and Follow-up Agent
- 🔒 **RLS on every table** — row-level security, `service_role` only in n8n (never in the frontend)
- 🎨 **Custom design system** — GSAP animations, Orbit components, dark theme

## Stack

Vue 3 · Vite · Tailwind CSS · Supabase (Postgres + Auth + RLS) · n8n · Google Gemini API · GSAP

## Quick Start

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/orbit-crm.git
   cd orbit-crm
   ```
2. Install dependencies:
   ```sh
   npm install
   ```
3. Set up environment variables:
   ```sh
   cp .env.example .env
   # Edit .env with your Supabase and n8n credentials
   ```
4. Start n8n automation via Docker:
   ```sh
   docker-compose up -d
   ```
5. Run the Vite development server:
   ```sh
   npm run dev
   ```

## Architecture

```text
  Browser (Vue 3 + Vite)
       │  anon key + RLS
       ▼
  Supabase (Postgres + Auth + Realtime)
       │  service_role key (ONLY in n8n)
       ▼
  n8n (Docker) ──► Gemini 2.5 Flash API
       │
       ▼
  automation_logs (Supabase)
```

## Environment Variables

| Variable | Description | Public/Secret |
|----------|-------------|---------------|
| `VITE_SUPABASE_URL` | The URL to your Supabase project | Public |
| `VITE_SUPABASE_ANON_KEY` | Supabase Anon Key for the frontend | Public |
| `VITE_N8N_WEBHOOK_URL` | URL for the n8n webhook (e.g., http://localhost:5678/webhook/lead-qualifier) | Public |
| `VITE_N8N_WEBHOOK_SECRET` | Secret token used to authenticate n8n requests | Secret |

## License

MIT
