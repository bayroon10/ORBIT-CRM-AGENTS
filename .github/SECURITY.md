# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 1.0.x   | ✅        |

## Reporting a Vulnerability

Please report vulnerabilities privately. Do NOT open a public issue.
You can reach out via email to: `bairon@orbitcrm.dev` (placeholder email, update before production).
Expected response time: 48 hours.

## Security Model

- **RLS on every table**: all Supabase tables have Row Level Security enabled. Authenticated users only see their own data, preventing unauthorized access.
- **`service_role` key**: only used in n8n automation workflows. This key is never exposed to the frontend or browser under any circumstances.
- **Webhook authentication**: n8n webhook requires an `Authorization` header (Bearer token scheme) to be accessed. An HMAC-SHA256 upgrade path is documented in ARCHITECTURE.md.
- **Frontend**: reads and writes to Supabase only via the `anon` key + RLS. The frontend cannot write to sensitive tables like `automation_logs` (`service_role` only).
