# Orbit CRM — Architecture

## System Overview

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

## Why `service_role` only in n8n?

The `service_role` key bypasses Row Level Security (RLS) entirely. It is never exposed to the frontend because if it were, any user inspecting the browser's network requests could retrieve the key and read or mutate the entire database. Instead, the frontend uses the `anon` key, which is restricted by RLS policies so users only access their own data. n8n safely runs in a secured backend environment (Docker) and handles administrative operations using the `service_role` key securely.

## Data Model

| Table | Description | RLS Policy Summary |
|-------|-------------|--------------------|
| `profiles` | User profiles associated with Auth accounts. | Admins see all; users see and edit their own. |
| `companies` | Companies and organizations records. | Users access companies associated with their deals. |
| `leads` | Individual contacts and prospects. | Sellers read and manage only their assigned leads. |
| `deals` | Sales opportunities linked to companies/leads. | Sellers read and manage only their assigned deals. |
| `tasks` | Action items tied to leads or deals. | Tasks are scoped and visible only to the assigned user. |
| `activities` | Global and entity-specific audit trail feed. | Read-only for sellers; Admins can manage. |
| `provider_settings` | Configurations for external integrations. | Read-only for sellers; Admins can edit. |
| `automations` | Workflow configuration and rules logic. | Read-only for sellers; Admins can edit. |
| `automation_logs` | Execution history of n8n automations. | Insert-only via `service_role` in n8n. |

## AI Lead Scoring Pipeline

1. **Trigger:** User clicks "Re-analizar" in `LeadDetailView`.
2. **Request:** Frontend sends a POST request to the n8n webhook with an `Authorization` header.
3. **Data Retrieval:** n8n retrieves the lead's data from Supabase (bypassing RLS via `service_role`).
4. **AI Processing:** n8n constructs a prompt and calls the Gemini 2.5 Flash API.
5. **Data Update:** n8n updates the `leads` table with the results (`ai_score`, `ai_category`, `ai_summary`, `ai_next_step`, `ai_analyzed_at`).
6. **Audit Trail:** n8n writes an execution log to the `automation_logs` table.
7. **Frontend Update:** Frontend UI reads the updated lead record via a standard SELECT query.

## Design System

- **`OrbitModal`**: Core modal component utilizing `Teleport` and `Transition`.
- **`OrbitPageHeader`**: Standardized header layout with title, breadcrumbs, and actions.
- **`OrbitEmptyState`**: UI component for displaying "No data" feedback.
- **`BaseBadge`**: Reusable primitive for colored tag indicators.
- **`BaseCard`**: Generic container component with consistent shadow and padding.

## n8n Workflows

- **Lead Qualifier**: Triggered via a webhook. It fetches lead data, evaluates the quality using Gemini 2.5 Flash, assigns an AI score, and logs the execution.
- **Follow-up Agent**: Runs on a schedule to assess deal risk. Analyzes the activity timeline and alerts assigned sellers if action is required.

## Database Migrations

To ensure the database schema evolves in a controlled and versioned manner, we use a migration system.

- **Location**: `database/migrations/`
- **Structure**: Each migration is a `.sql` file named with a sequential number and a descriptive title (e.g., `001_add_get_masked_credential.sql`).
- **Application**: Migrations are applied manually via the Supabase SQL Editor.
- **Documentation**: A `README.md` inside the `migrations` folder provides detailed instructions and best practices.

This approach provides a clear audit trail of schema changes and ensures consistency across development and potential future production environments.
