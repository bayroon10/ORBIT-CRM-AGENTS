# DATA_CONTRACTS.md — Orbit CRM

> **Propósito:** Documento de referencia normativa para las tablas `leads` y `deals`.
> Todo cambio de schema, renombrado de columna o nuevo campo **debe quedar registrado aquí primero**.
> Esto previene re-introducir los mismos bugs que costaron horas en sesiones anteriores.
>
> **Fuente de verdad:** Los queries en `src/services/*.service.js` y el Supabase remoto.
> Los archivos en `database/schema/` son **backup estático y están desactualizados** — no confiar.
>
> Última verificación: **2026-07-31** (revisión manual de services + views)
> Última actualización: **2026-07-31** — migration 003 aplicada, HALLAZGO-01 y HALLAZGO-02 resueltos.

---

## Tabla: `leads`

> Schema real verificado contra `LeadsService` y `DashboardService`. Las columnas del archivo
> `database/schema/schema_crm.sql` están marcadas como `[STALE]` donde divergen.

### Columnas

| Columna | Tipo (inferido) | Nullable | Default | Notas |
|---|---|---|---|---|
| `id` | `uuid` | NO | `gen_random_uuid()` | PK |
| `full_name` | `varchar(255)` | NO | — | Schema SQL local dice `name` — **STALE** |
| `email` | `varchar(255)` | SÍ | — | |
| `phone` | `varchar(50)` | SÍ | — | |
| `source` | `varchar(100)` | SÍ | `'web'` | Valores: `web`, `manual`, `webhook` |
| `status` | `varchar(50)` | SÍ | `'nuevo'` | Valores: `nuevo`, `contactado`, `calificado` |
| `owner_id` | `uuid` | SÍ | — | FK → `profiles.id` ON DELETE SET NULL |
| `company_id` | `uuid` | SÍ | — | FK → `companies.id` ON DELETE SET NULL |
| `created_at` | `timestamptz` | SÍ | `CURRENT_TIMESTAMP` | |
| `ai_score` | `integer` | SÍ | `null` | Score 0–100. `null` = no analizado aún. Ausente en schema SQL local |
| `ai_category` | `varchar` | SÍ | `null` | Valores: `Hot`, `Warm`, `Cold`. Ausente en schema SQL local |
| `ai_summary` | `text` | SÍ | `null` | Resumen generado por Gemini. Ausente en schema SQL local |
| `ai_next_step` | `text` | SÍ | `null` | Acción recomendada por Gemini. Ausente en schema SQL local |
| `ai_analyzed_at` | `timestamptz` | SÍ | `null` | Fecha del último análisis IA. Ausente en schema SQL local |
| `notes` | `text` | SÍ | `null` | Notas libres del formulario. **Agregada vía migration 003 (2026-07-31)**. Ausente en schema SQL local |

### Columnas que existen en schema SQL local pero NO en remoto

Ninguna detectada. El schema local simplemente tiene menos columnas (versión anterior).

### Relaciones (joins válidos en PostgREST)

| Join | Sintaxis PostgREST | Uso en frontend |
|---|---|---|
| Empresa del lead | `companies!company_id(name)` | `leads.service.js → getLeads()`, `getLeadById()` |
| Actividades del lead | tabla `activities` con `.eq('lead_id', id)` | `leads.service.js → getLeadActivities()` |
| Negocios del lead | tabla `deals` con `.eq('lead_id', id)` | `leads.service.js → getLeadDeals()` |

> **IMPORTANTE:** Usar siempre el delimitador explícito `companies!company_id` para evitar PGRST201.

---

### Consumidores del frontend — `leads`

| Archivo | Columnas accedidas | Operación |
|---|---|---|
| `src/services/leads.service.js → getLeads()` | `id, full_name, email, phone, status, created_at, ai_score, ai_category` + join `companies!company_id(name)` | SELECT |
| `src/services/leads.service.js → getLeadById()` | `id, full_name, email, phone, status, source, created_at, company_id, ai_score, ai_category, ai_summary, ai_next_step, ai_analyzed_at` + join | SELECT |
| `src/services/leads.service.js → getLeadAiFields()` | `ai_score, ai_category, ai_summary, ai_next_step, ai_analyzed_at` | SELECT (partial refresh) |
| `src/services/leads.service.js → createLead()` | `full_name, email, phone, status, owner_id, company_id, source, notes` | INSERT |
| `src/services/leads.service.js → deleteLead()` | `id` | DELETE |
| `src/services/dashboard.service.js → getDashboardMetrics()` | `id, full_name, ai_score, ai_category` | SELECT |
| `src/views/Leads.vue` | `full_name, email, phone, status, companies?.name, ai_score, created_at` | Display + CREATE form (company_id vía select) |
| `src/views/LeadDetail.vue` | `full_name, email, phone, status, source, companies?.name, created_at, ai_score, ai_category, ai_summary, ai_next_step, ai_analyzed_at` | Display |
| `src/views/Dashboard.vue` | Recibe datos via `DashboardService` | Display (read-only) |
| `src/views/Sales.vue` | Via `SalesService` — join desde `deals → leads(full_name)` | Display (read-only) |

---

## Tabla: `deals`

> Schema real verificado contra `DealsService` y `SalesService`.
> El schema SQL local `schema_crm.sql` usa nombres completamente distintos — todos STALE.

### Columnas

| Columna | Tipo (inferido) | Nullable | Default | Notas |
|---|---|---|---|---|
| `id` | `uuid` | NO | `gen_random_uuid()` | PK |
| `title` | `varchar(255)` | NO | — | Schema SQL local dice `name` — **STALE** |
| `value` | `decimal(12,2)` | SÍ | `0.00` | Schema SQL local dice `amount` — **STALE** |
| `stage` | `varchar(50)` | SÍ | `'prospecto'` | Schema SQL local dice `status` — **STALE**. Valores: `prospecto`, `cotizado`, `negociando`, `ganado`, `perdido` |
| `probability` | `integer` | SÍ | `null` | Porcentaje 0–100. Ausente en schema SQL local |
| `expected_close` | `date` | SÍ | `null` | Ausente en schema SQL local |
| `stalled` | `boolean` | SÍ | `null` | Flag de deal estancado. Ausente en schema SQL local |
| `lead_id` | `uuid` | SÍ | — | FK → `leads.id` ON DELETE CASCADE |
| `company_id` | `uuid` | SÍ | — | FK → `companies.id`. Ausente en schema SQL local |
| `owner_id` | `uuid` | SÍ | — | FK → `profiles.id` ON DELETE SET NULL |
| `created_at` | `timestamptz` | SÍ | `CURRENT_TIMESTAMP` | |
| `updated_at` | `timestamptz` | SÍ | — | Actualizado automáticamente (trigger o app). Ausente en schema SQL local |
| `ai_risk_score` | `integer` | SÍ | `null` | Score de riesgo 0–100. Ausente en schema SQL local |
| `ai_risk_factors` | `text` | SÍ | `null` | Factores de riesgo generados por IA. Ausente en schema SQL local |
| `ai_analyzed_at` | `timestamptz` | SÍ | `null` | Fecha del último análisis IA. Ausente en schema SQL local |

### Columnas del schema SQL local que NO existen en remoto

| Columna stale | Reemplazada por |
|---|---|
| `name` | `title` |
| `amount` | `value` |
| `status` | `stage` |

### Relaciones (joins válidos en PostgREST)

| Join | Sintaxis PostgREST | Uso en frontend |
|---|---|---|
| Lead del deal | `leads(full_name)` | `deals.service.js → getDeals()`, `getDealById()` |
| Empresa del deal | `companies!company_id(name)` | `deals.service.js → getDeals()`, `getDealById()` |
| Actividades del deal | tabla `activities` con `.eq('deal_id', id)` | `deals.service.js → getDealActivities()` |
| Tareas del deal | tabla `tasks` con `.eq('deal_id', id)` | `deals.service.js → getDealTasks()` |

> **IMPORTANTE:** Usar siempre `companies!company_id` para deals. El join `leads` no necesita delimitador (FK unívoca).

---

### Consumidores del frontend — `deals`

| Archivo | Columnas accedidas | Operación |
|---|---|---|
| `src/services/deals.service.js → getDeals()` | `id, title, value, stage, probability, expected_close, stalled, ai_risk_score, ai_risk_factors, ai_analyzed_at, created_at, lead_id, company_id` + joins | SELECT |
| `src/services/deals.service.js → getDealById()` | `id, title, value, stage, probability, expected_close, stalled, ai_risk_score, ai_risk_factors, ai_analyzed_at, created_at, updated_at, lead_id, company_id` + joins | SELECT |
| `src/services/deals.service.js → createDeal()` | `title, value, stage, expected_close (opcional), owner_id` | INSERT |
| `src/services/deals.service.js → updateDealStage()` | `stage` | UPDATE |
| `src/services/leads.service.js → getLeadDeals()` | `id, title, value, stage, expected_close` | SELECT (desde contexto de lead) |
| `src/services/sales.service.js → getWonDeals()` | `*` + joins `leads(full_name)`, `profiles(full_name)` | SELECT |
| `src/services/dashboard.service.js → getDashboardMetrics()` | `value` (stage `ganado`); count en stages activos | SELECT (count + aggregate) |
| `src/views/Deals.vue` | `id, title, value, stage, ai_risk_score, companies?.name, leads?.full_name, expected_close` | Display (Kanban) + CREATE form |
| `src/views/DealDetail.vue` | `title, stage, value, probability, expected_close, ai_risk_score, ai_risk_factors, ai_analyzed_at, created_at, updated_at, leads?.full_name, companies?.name` | Display |
| `src/views/LeadDetail.vue` | `title, value, stage, expected_close` | Display (lista de deals del lead) |

---

## Hallazgos: columnas que no coinciden con el schema real

Los siguientes son **bugs documentados, aún sin corregir**. Requieren tarea explícita para arreglar.

---

### ~~HALLAZGO-01~~ — `company` como campo de INSERT en `leads` ✅ RESUELTO (2026-07-31)

**Columna usada en código:** `company` (string de texto libre)  
**Columna real en BD:** No existe. El campo correcto es `company_id` (UUID FK → `companies`).

**Archivos corregidos:**

| Archivo | Cambio |
|---|---|
| `src/services/leads.service.js` | Eliminada `company` del SELECT de `getLeads()` |
| `src/views/Leads.vue` | Reemplazado `<input>` libre por `<select>` que lista empresas reales desde `CompaniesService.getCompanies()` y guarda `company_id` en el payload |
| `src/views/Leads.vue` | Eliminado fallback `lead.company` del display y del filtro de búsqueda |

**Fix aplicado:** `src/views/Leads.vue` carga las empresas vía `CompaniesService.getCompanies()` al abrir el modal, presenta un `<select>` nativo con las opciones reales, y envía `company_id: form.company_id || null` al INSERT.

---

### ~~HALLAZGO-02~~ — `notes` como campo de INSERT en `leads` ✅ RESUELTO (2026-07-31)

**Columna usada en código:** `notes` (text libre)  
**Columna real en BD:** No existía. **Agregada vía migration 003 el 2026-07-31.**

**Archivos corregidos:**

| Archivo | Cambio |
|---|---|
| `database/migrations/003_leads_add_notes.sql` | Migration nueva: `ALTER TABLE public.leads ADD COLUMN IF NOT EXISTS notes TEXT NULL` |
| `src/views/Leads.vue` | El campo `notes` del formulario ahora persiste correctamente (columna existente, payload sin cambios) |

**Fix aplicado:** Opción A — se agregó la columna `notes TEXT NULL` a la tabla `leads`. El payload `notes: form.notes.trim() || null` funciona correctamente luego de aplicar la migration.

> **IMPORTANTE:** La migration `003_leads_add_notes.sql` debe aplicarse manualmente en el Supabase SQL Editor antes de usar el formulario de creación de leads en producción. Ver instrucciones en el archivo de migration.

---

### HALLAZGO-03 — Schema SQL local `schema_crm.sql` completamente desactualizado [SEVERIDAD MEDIA]

**Archivo:** `database/schema/schema_crm.sql`

El archivo define columnas que ya no existen en la BD remota:

| Columna en SQL local | Columna real en remoto | Tabla |
|---|---|---|
| `leads.name` | `leads.full_name` | `leads` |
| `deals.name` | `deals.title` | `deals` |
| `deals.amount` | `deals.value` | `deals` |
| `deals.status` | `deals.stage` | `deals` |

Además, faltan todas las columnas `ai_*` y `probability`, `expected_close`, `stalled`, `company_id` (deals), `updated_at` (deals).

**Fix sugerido:** Actualizar el archivo o agregar al inicio del archivo un banner explícito:
```sql
-- AVISO: Este archivo está DESACTUALIZADO. Ver docs/DATA_CONTRACTS.md para el schema real.
-- No ejecutar contra el Supabase remoto sin revisar DATA_CONTRACTS.md primero.
```

---

### HALLAZGO-04 — Workflow n8n archivado usa `name` para INSERT en `leads` [SEVERIDAD MEDIA]

**Archivo:** `database/workflows/n8n_lead_workflow.json` (L24)

```json
{ "fieldId": "name", "fieldValue": "={{ $json.body.name }}" }
```

La columna real es `full_name`. Si este workflow se reimporta y activa, todos los leads creados via webhook tendrán `full_name = null` (campo NOT NULL), causando errores de INSERT.

**Fix sugerido:** Actualizar `fieldId` de `"name"` a `"full_name"` antes de cualquier reimportación.

---

### HALLAZGO-05 — Seeds de desarrollo usan columnas stale [SEVERIDAD BAJA]

**Archivos:** `database/seed/seed_crm.sql`, `database/seed/qa_seed.sql`

- `seed_crm.sql` L22: `INSERT INTO public.leads (id, name, ...)` → debería ser `full_name`
- `seed_crm.sql` L30: `INSERT INTO public.deals (id, name, amount, status, ...)` → debería ser `title, value, stage`
- `qa_seed.sql` L117, L122, L127: `INSERT INTO public.leads (id, name, ...)` → debería ser `full_name`

**Comportamiento actual:** Ejecutar estos seeds contra el Supabase remoto falla con error de columna inexistente.

**Fix sugerido:** Actualizar seeds con nombres de columna correctos si se planea usarlos en el futuro.

---

### HALLAZGO-06 — Campo `notes` no se muestra en `LeadDetail.vue` [SEVERIDAD BAJA]

**Columna real en BD:** `notes` (`text`, nullable) — existe y se guarda correctamente (verificado con SQL y QA de browser el 2026-07-31).  
**Problema:** `LeadDetail.vue` no incluye `notes` en las columnas que consume ni lo despliega en ningún lugar de la UI. El dato se pierde visualmente aunque esté persistido en la base de datos.  
**Archivo afectado:** `src/views/LeadDetail.vue`  
**Fix sugerido:** Agregar una sección "Notas" en el detalle del lead, mostrando el valor de `notes` si existe (o un estado vacío tipo "Sin notas" si es `null`).  
**Estado:** Pendiente, sin arreglar.

---

## Reglas de uso de este documento

1. **Antes de hacer un SELECT/INSERT/UPDATE** sobre `leads` o `deals`, verificar aquí que las columnas existen.
2. **Ante cualquier duda**, la fuente más confiable es el query en `src/services/leads.service.js` o `src/services/deals.service.js` — seguida del Supabase remoto.
3. **Al agregar una nueva columna** vía migration: actualizar este documento en el mismo commit.
4. **El MCP de Supabase** puede usarse para verificar el schema real cuando esté configurado:
   ```sql
   SELECT column_name, data_type, is_nullable, column_default
   FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name IN ('leads', 'deals')
   ORDER BY table_name, ordinal_position;
   ```
5. **No confiar** en `database/schema/schema_crm.sql` ni `database/seed/seed_crm.sql` como referencia de columnas.
6. **No confiar** en comentarios en `AGENTS.md` como única fuente — siempre cruzar con este documento.

---

*Generado el 2026-07-31. Próxima revisión recomendada: al aplicar cualquier migration.*
