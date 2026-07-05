# RFC-0002 — Multi-tenancy en OrbitCRM

> **Estado:** Propuesto · **Fecha:** 2026-07-05 · **Autor:** Principal Engineer (revisión técnica)
> **Tarea:** T-ARC-01 · **Hallazgo:** ARC-02 (P1/Alto) · **Nivel de cambio:** N3 (arquitectura + RLS)
> **Modo:** READ ONLY — este RFC es documentación. No se modificó código, BD, ni se crearon migraciones/commits.
> **Insumo:** `docs/knowledge/03_DATABASE_MAP.md`, `docs/knowledge/11_ENGINEERING_DECISIONS.md`, `docs/reports/Technical_Debt.md`, verificación en vivo Supabase MCP (2026-07-05).

---

## 0. Architecture Review Board (auto-desafío previo)

### 0.1 Desafío a la recomendación
La recomendación preliminar es **Opción A3 (congelar y diferir)**. El desafío obvio: OrbitCRM ya tiene columnas `tenant_id` y una función `auth_tenant_id()` — ¿no sería más barato "terminar" el trabajo (Opción A2) que desmontarlo parcialmente (A3)? La respuesta depende de si ese andamiaje refleja una necesidad de negocio real hoy o es código especulativo sin RLS completo detrás.

### 0.2 Por qué la opción elegida podría estar equivocada
- **A3 "retrocede" trabajo ya escrito** (2 policies de tenant). Si en 2 meses se firma un cliente que exige aislamiento estricto, se vuelve a construir desde cero.
- **A3 no resuelve el propósito original** de `tenant_id`: si alguien lo agregó pensando en SaaS multi-cliente, diferirlo es una decisión de producto, no solo técnica.

### 0.3 Escenarios futuros donde la opción rechazada (A2) sería mejor
- Si OrbitCRM pasa de "un CRM interno" a venderse como SaaS a múltiples empresas clientas en el corto plazo, A2 evita una migración de datos y RLS bajo presión de negocio.
- Si ya existen datos de más de una organización en producción (verificado: no es el caso — ver §1).

### 0.4 Supuestos
1. OrbitCRM opera hoy para **una sola organización** (no hay evidencia de multi-cliente en los datos).
2. El aislamiento por tenant, si se necesita, puede reconstruirse desde una base RLS coherente sin gran esfuerzo si se documenta bien el estado "diferido".
3. No hay compromiso comercial firmado que exija multi-tenancy inmediato. **[NO VERIFICADO — supuesto de negocio, confirmar con Project Owner]**.

### 0.5 Incógnitas (unknowns)
- Roadmap comercial: ¿existe intención a corto plazo de vender OrbitCRM a múltiples clientes aislados? **[NO VERIFICADO]**
- ¿Alguna fila real usa `tenant_id` hoy con intención productiva, o es todo `NULL`? **[Verificado parcialmente: columna nullable en 5 tablas, no se auditó el contenido fila por fila — fuera de alcance de este RFC por ser solo lectura de metadatos, no de datos de negocio]**

### 0.6 Deuda técnica introducida por cada opción
- **A1 (single-tenant explícito, eliminar todo):** deuda cero hacia adelante, pero pierde el trabajo ya hecho (columnas, función) si se activa multi-tenant después.
- **A2 (multi-tenant completo ahora):** alto riesgo de RLS mal probada (sin suite de tests — Sprint 3 aún no ejecutado) → posible fuga de datos entre tenants no detectada.
- **A3 (congelar y diferir):** deuda documentada y acotada (una columna latente + un ADR); riesgo de que alguien reactive el andamiaje sin releer el ADR. Mitigable con comentarios en el propio esquema.

### 0.7 ¿Es reversible esta decisión?
**Sí, alta reversibilidad.** A3 no elimina la columna `tenant_id` ni la función `auth_tenant_id()` — solo retira las 2 policies inconsistentes. Revertir a A2 en el futuro es re-agregar policies de tenant sobre una columna que ya existe, no una migración de esquema desde cero.

### 0.8 Nivel de confianza
**Confianza en la recomendación: 85%.** Alta, porque la evidencia muestra un andamiaje real pero incompleto (2 de 6 tablas con aislamiento, función sin `search_path`, sin tests que lo validen) — mantenerlo a medias es más peligroso que documentarlo como diferido. El 15% de incertidumbre viene del supuesto de negocio no verificado (§0.4.3).

---

## 1. Contexto

Estado verificado en vivo (Supabase MCP, `kgrfhfwtcanthrymmvkb`, 2026-07-05):

**Columna `tenant_id` — presente y `nullable` en 5 tablas** (no 6; `companies` no tiene esta columna):

| Tabla | Columna | `is_nullable` |
|---|---|---|
| `activities` | `tenant_id` | `YES` |
| `deals` | `tenant_id` | `YES` |
| `leads` | `tenant_id` | `YES` |
| `profiles` | `tenant_id` | `YES` |
| `tasks` | `tenant_id` | `YES` |

> **Corrección respecto al backlog:** `docs/knowledge/03_DATABASE_MAP.md` y sesiones previas mencionan "6 tablas" con `tenant_id`. Verificado ahora: son **5**. `companies` no la tiene, lo cual es una inconsistencia adicional (si una empresa no tiene tenant, ¿cómo se aísla su cartera de leads/deals asociados?).

**Policies de aislamiento por tenant — solo en 2 de las 5 tablas:**

| Tabla | Policy | `cmd` | Condición (`qual`) |
|---|---|---|---|
| `activities` | `Activities tenant isolation` | `ALL` | `(tenant_id = auth_tenant_id()) OR is_admin_or_higher()` |
| `deals` | `Deals tenant isolation` | `ALL` | `(tenant_id = auth_tenant_id()) OR is_admin_or_higher()` |

`leads`, `profiles`, `tasks` tienen la columna `tenant_id` pero **ninguna policy que la use** — su RLS se basa únicamente en `owner_id = auth.uid() OR is_admin()`.

**Función `auth_tenant_id()`:** `SECURITY DEFINER`, lenguaje `sql`, **sin `search_path` fijado** (`proconfig = null`), con `EXECUTE` otorgado a `anon` y `authenticated`. Esto se cruza directamente con **T-SEC-08** (hardening de funciones `SECURITY DEFINER`).

**Consumidor en frontend:** `useRealtimeAlerts` (composable) filtra notificaciones de leads calientes por `tenant_id`. Si `tenant_id` es `NULL` (caso actual, sin evidencia de población), el comportamiento de ese filtro es indefinido/inconsistente — no verificado exhaustivamente en este RFC porque implica auditar datos de negocio fila por fila, fuera del alcance de lectura de metadatos.

**Resumen del estado:** existe un andamiaje de multi-tenancy **parcial e inconsistente** — 5 de 14 tablas con la columna, 2 de esas 5 con policy activa, 0 tablas con la columna `NOT NULL`, y una función crítica sin `search_path`.

## 2. Problema

El sistema tiene comportamiento de aislamiento por tenant **indefinido**: dos tablas (`deals`, `activities`) restringen por `tenant_id`, pero las tablas relacionadas (`leads`, `tasks`, `profiles`) no. Esto significa que un usuario podría ver un `lead` completo (sin restricción de tenant) pero no los `deals`/`activities` asociados a ese mismo lead si pertenecen a otro tenant — o viceversa, dependiendo de cómo se puebla `tenant_id`. Es un modelo de seguridad **no verificable como correcto ni como incorrecto**, porque no hay una definición formal de qué es un "tenant" en OrbitCRM ni una decisión documentada.

Mantener este estado sin decidir es peor que decidir explícitamente en cualquier dirección, porque:
- Da una falsa sensación de aislamiento (dos tablas "protegidas") sin protección real del conjunto.
- Bloquea razonar con confianza sobre T-SEC-08 (¿se debe endurecer `auth_tenant_id()` tal como está, o redefinirla?).
- No hay tests (Sprint 3 no ejecutado) que detecten una fuga si el aislamiento parcial falla.

## 3. Opciones

### Opción A1 — Single-tenant explícito (eliminar todo el andamiaje)

**Descripción:** eliminar `tenant_id` de las 5 tablas, eliminar `auth_tenant_id()`, eliminar las 2 policies de tenant. Declarar formalmente que OrbitCRM es de una sola organización.

**Pros:**
- Cero ambigüedad; RLS más simple y fácil de auditar (solo `owner_id`/`is_admin()`).
- Elimina de raíz la función sin `search_path` (resuelve una parte de T-SEC-08 por eliminación).

**Contras:**
- Descarta trabajo ya escrito; si se necesita multi-tenant en el futuro, se reconstruye desde cero (esquema + RLS).
- Es la opción más "destructiva" de las tres (DROP COLUMN es difícil de revertir una vez hecho).

**Esfuerzo:** Bajo. **Riesgo:** Bajo técnico, pero **irreversible** una vez aplicado (a diferencia de A3).

### Opción A2 — Multi-tenant completo

**Descripción:** definir formalmente qué es un tenant (¿`companies`? ¿nueva tabla `organizations`?), poblar `tenant_id` `NOT NULL` en las 5 tablas (+ agregarla a `companies`), aplicar policies de aislamiento consistentes en las 14 tablas relevantes, endurecer `auth_tenant_id()`.

**Pros:**
- Aislamiento real y consistente; prepara el sistema para ser SaaS multi-organización.
- Cierra la deuda ARC-02 de forma definitiva, no diferida.

**Contras:**
- Esfuerzo alto: backfill de datos existentes (requiere decidir a qué tenant pertenece cada fila histórica, con riesgo de mapeo incorrecto).
- **Sin suite de tests de RLS todavía** (Sprint 3 no se ha ejecutado) — cualquier error en una policy de aislamiento puede abrir datos entre tenants (fuga) o cerrar acceso legítimo, y no hay forma automatizada de detectarlo antes de producción.
- Mayor superficie de RLS para mantener y razonar en cada cambio futuro de esquema.

**Esfuerzo:** Alto. **Riesgo:** Alto (el más alto de las tres, precisamente por la falta de red de pruebas).

### Opción A3 — Congelar y diferir (recomendada)

**Descripción:** quitar las 2 policies de tenant inconsistentes (`Deals tenant isolation`, `Activities tenant isolation`), dejando el aislamiento de `deals`/`activities` únicamente en `owner_id`/`is_admin()` (igual que las demás tablas). Conservar las columnas `tenant_id` y la función `auth_tenant_id()` como **artefactos latentes documentados** (no se eliminan por si se reactiva la decisión, pero no participan en ninguna policy activa). Registrar la decisión en ADR como "diferido, no descartado".

**Pros:**
- Coherencia inmediata: todas las tablas usan el mismo criterio de acceso (`owner_id`/`is_admin()`), sin excepciones sin sentido.
- No es destructivo: no se pierde el trabajo previo (columnas y función siguen existiendo), a diferencia de A1.
- No exige backfill de datos ni RLS nueva bajo presión, a diferencia de A2.
- Alineado con el principio "diseñar para el cambio probable, no el imaginario": si aparece la necesidad real de multi-tenant, se retoma con una base de tests ya construida (Sprint 3).

**Contras:**
- Requiere una migración pequeña (DROP POLICY x2) — no es "no hacer nada", es un cambio de esquema acotado.
- Deja código latente (`tenant_id`, `auth_tenant_id()`) que alguien podría reactivar sin pasar por este RFC/ADR si no está bien señalizado — mitigable con comentarios SQL explícitos.

**Esfuerzo:** Bajo. **Riesgo:** Medio-bajo (la única acción sobre RLS viva es *remover* restricciones, no añadir — reduce el riesgo de "cerrar acceso por error"; el riesgo real es cambiar el comportamiento de acceso de `deals`/`activities`, que hay que comunicar y validar).

## 4. Decisión

**Opción aprobada: A3 — Congelar y diferir.**

**Aprobado por:** Project Owner (usuario), sesión Sprint 2 Fase 0.

**Justificación técnica:**

1. **Evidencia de que el aislamiento actual ya es inconsistente, no solo incompleto.** No es que falte añadir tenant a 3 tablas más — es que dos tablas (`deals`, `activities`) tienen una regla de acceso que las demás no tienen, sin justificación documentada de por qué esas dos sí y las otras no.
2. **No hay red de pruebas para validar RLS de aislamiento (Sprint 3 pendiente).** Activar multi-tenancy completo (A2) sin tests automatizados que verifiquen la ausencia de fuga entre tenants es exactamente el escenario de riesgo que la gobernanza del proyecto exige evitar antes de tocar seguridad de datos.
3. **No hay evidencia de necesidad de negocio inmediata.** OrbitCRM opera hoy como un CRM de una sola organización; no hay evidencia verificada de clientes múltiples que requieran aislamiento estricto ahora.
4. **A3 preserva opcionalidad sin pagar el costo de A2 hoy.** A diferencia de A1, no se destruye la columna ni la función — quedan disponibles para cuando haya tests y necesidad real.
5. **Reduce superficie de auditoría de seguridad inmediatamente**, sin esperar a T-SEC-08: al quitar las 2 policies que dependen de `auth_tenant_id()` sin `search_path`, se reduce el impacto de esa función mientras se decide su endurecimiento.

## 5. Plan de implementación de A3

> Ninguno de estos pasos se ejecuta en este RFC. Se documentan para su aprobación y ejecución posterior como migración versionada (dependencia: T-DB-01).

1. **Quitar las 2 policies de tenant inconsistentes:**
   ```sql
   DROP POLICY IF EXISTS "Deals tenant isolation" ON public.deals;
   DROP POLICY IF EXISTS "Activities tenant isolation" ON public.activities;
   ```
   Efecto: `deals` y `activities` quedan con el mismo criterio de acceso que `leads`/`tasks` (`owner_id = auth.uid() OR is_admin()`), eliminando la excepción.

2. **Documentar `tenant_id` como columna latente** (comentario SQL explícito en cada tabla, para que quede visible en `\d+` y en cualquier introspección futura):
   ```sql
   COMMENT ON COLUMN public.deals.tenant_id IS
     'LATENTE (RFC-0002/ADR pendiente): multi-tenancy diferido. No usar en RLS sin revisar RFC-0002.';
   -- repetir en activities, leads, profiles, tasks
   ```

3. **No tocar la función `auth_tenant_id()` en este RFC** — su endurecimiento (o eventual eliminación si se confirma A1 en el futuro) es alcance de **T-SEC-08**, no de este RFC. Se deja explícitamente para no mezclar contextos (multi-tenancy vs. hardening de funciones).

4. **Registrar el ADR de diferimiento** (T-DOC-02, al final del sprint): `ADR-000X-multi-tenancy-diferido.md`, con referencia a este RFC.

5. **Prerequisitos para activar multi-tenancy en el futuro (Opción A2 revisitada):**
   - Suite de tests de RLS operativa (Sprint 3, T-TST-01) que incluya casos específicos de fuga entre tenants (crear 2 tenants de prueba, verificar aislamiento cruzado en cada tabla).
   - Definición formal de qué entidad es "el tenant" (¿`companies`? ¿tabla nueva `organizations`?) — hoy no está definido.
   - `auth_tenant_id()` endurecida (T-SEC-08: `search_path` fijo, `REVOKE` de `anon`).
   - `tenant_id` agregada también a `companies` (hoy ausente) si el tenant se modela sobre esa tabla.
   - Plan de backfill de datos existentes con reglas claras de asignación.

## 6. Rollback

- **Si se necesita revertir el retiro de las 2 policies** (volver al estado actual "a medias"): re-crear las policies exactamente como están hoy, verificado en este RFC:
  ```sql
  CREATE POLICY "Deals tenant isolation" ON public.deals
    FOR ALL USING (tenant_id = auth_tenant_id() OR is_admin_or_higher());
  CREATE POLICY "Activities tenant isolation" ON public.activities
    FOR ALL USING (tenant_id = auth_tenant_id() OR is_admin_or_higher());
  ```
- **Reversibilidad: Alta.** No se elimina ninguna columna ni función; el rollback es exclusivamente restaurar 2 policies con la definición ya documentada arriba (verificada, no supuesta).
- **Validación previa recomendada:** aplicar en un branch de Supabase antes de producción, y confirmar que ningún flujo de la UI dependía silenciosamente del filtro de tenant en `deals`/`activities` (ej. `useRealtimeAlerts` — revisar si asume `tenant_id` no nulo en algún filtro de `deals`).

## 7. Referencias cruzadas

- **T-SEC-08** (hardening de `auth_tenant_id()`, `is_admin_or_higher()` y otras `SECURITY DEFINER`): decide si `auth_tenant_id()` se endurece tal cual o se marca como candidata a eliminación futura si A1 se retoma.
- **T-DB-01** (migraciones versionadas): los cambios de §5 deben aplicarse como migración versionada, no ad-hoc, una vez exista el baseline.
- **Sprint 3 (T-TST-01):** prerequisito explícito para cualquier futura reactivación de multi-tenancy (§5.5).
- **`docs/knowledge/03_DATABASE_MAP.md`**: contiene el estado documentado previo (con la imprecisión de "6 tablas" corregida a 5 en este RFC).
- **`docs/reports/Technical_Debt.md`** (`TD-P1-07`, `ARC-02`): hallazgo original que origina esta decisión.

---

### Referencias
- Verificación en vivo Supabase MCP (2026-07-05): `information_schema.columns`, `pg_policies`, `pg_proc`.
- `docs/knowledge/03_DATABASE_MAP.md`, `docs/knowledge/11_ENGINEERING_DECISIONS.md`.
- `docs/reports/Technical_Debt.md` (TD-P1-07 / ARC-02).
- RFC-0001 (formato replicado).

> **STOP.** RFC generado. No se implementó nada, no se ejecutó DDL. A la espera de que el Project Owner commitee este documento y de la ejecución posterior vía migración versionada (T-DB-01) tras nueva aprobación explícita de los pasos del §5.
