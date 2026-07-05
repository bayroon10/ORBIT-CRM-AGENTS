# RFC-0003 — Modelo de dominio ES/EN (quotes vs cotizaciones/ventas)

> **Estado:** Propuesto · **Fecha:** 2026-07-05 · **Autor:** Principal Engineer (revisión técnica)
> **Tarea:** T-ARC-02 · **Hallazgo:** ARC-03 (P1/Alto), SEC-07 (P2/Medio) · **Nivel de cambio:** N3 (esquema + datos)
> **Modo:** READ ONLY — este RFC es documentación. No se modificó código, BD, ni se crearon migraciones/commits. No se ejecutó ningún DDL/DML.
> **Insumo:** `docs/knowledge/03_DATABASE_MAP.md`, `docs/reports/Technical_Debt.md`, verificación en vivo Supabase MCP (2026-07-05).

---

## 0. Architecture Review Board (auto-desafío previo)

### 0.1 Desafío a la recomendación
La recomendación preliminar es **Opción B1 (canónico EN, deprecar ES)**. El desafío: la UI de OrbitCRM está en español (`es-CL`) y existen 4 vistas SQL que traducen el modelo EN a nombres en español — ¿no sugiere esto que el modelo "correcto" a largo plazo era el español, y que `quotes` es el que está desalineado?

### 0.2 Por qué la opción elegida podría estar equivocada
- Si el negocio (documentación, contratos, reportes a stakeholders) usa terminología en español (`cotización`, `venta`, `oportunidad`), forzar el modelo canónico a inglés puede generar friction de traducción constante entre lo que ve el usuario y lo que existe en la BD.
- Las vistas ES ya invirtieron esfuerzo en mapear `deals→oportunidades`, `activities→actividades`, etc. — sugieren una intención de exponer el dominio en español en algún momento.

### 0.3 Escenarios futuros donde la opción rechazada (B2) sería mejor
- Si OrbitCRM se posiciona como producto para mercado hispanohablante con documentación técnica y contratos en español donde el esquema de datos debe ser auditable por no-técnicos en español.
- Si se descubriera que las vistas ES sí tienen consumidores externos (reportes, BI) — **verificado en este RFC que no es el caso** (§1).

### 0.4 Supuestos
1. El código de servicios/frontend seguirá evolucionando en inglés (nombres de variables, servicios) — evidencia: `deals.service.js`, `quotes` ya es el modelo con el que interactúan `QuoteDetail.vue` y servicios relacionados.
2. Las 3 filas de `cotizaciones` son datos de prueba/QA o reales de baja actividad, no un flujo de producción activo (tabla sin policies = inaccesible desde la app hoy).
3. Nadie fuera del código fuente (reportes externos, BI, exports) consume las vistas ES. **Verificado en este RFC** (§1) dentro del alcance de este repositorio; no se verificó BI externo si existiera fuera del repo.

### 0.5 Incógnitas (unknowns)
- ¿Existe algún consumo de las vistas ES fuera de este repositorio (dashboard externo, Google Sheets conectado, etc.)? **[NO VERIFICADO — fuera del alcance de lectura de código]**
- ¿Las 3 filas de `cotizaciones` tienen valor de negocio real o son datos de prueba? **[NO VERIFICADO — requiere confirmación del Owner antes de migrar/eliminar]**

### 0.6 Deuda técnica introducida por cada opción
- **B1 (canónico EN):** deuda cero de fragmentación; pequeña deuda temporal durante la migración (verificar que nada dependía de `cotizaciones`).
- **B2 (canónico ES):** deuda altísima — reescribir servicios, componentes, RLS y roles para pasar todo el dominio a español; alto riesgo de regresión en un sistema sin tests (Sprint 3 no ejecutado).
- **B3 (mantener ambos):** la deuda que ya existe se perpetúa; `cotizaciones` sigue con 3 filas inaccesibles (0 policies) indefinidamente.

### 0.7 ¿Es reversible esta decisión?
**Media-alta con backup.** La migración de las 3 filas es pequeña y reversible si se respalda antes de cualquier DDL/DML. Eliminar `cotizaciones`/`ventas` **no es reversible sin el backup** — por eso el backup es obligatorio y bloqueante, no opcional.

### 0.8 Nivel de confianza
**Confianza en la recomendación: 90%.** El código fuente ya usa el modelo inglés de forma consistente (`quotes`, `deals`, `leads`) y no hay consumidores verificados de las vistas/tablas ES. El 10% de incertidumbre es la naturaleza real de las 3 filas de `cotizaciones` (§0.5), que debe confirmarse con el Owner antes de ejecutar la migración (no antes de aprobar este RFC).

---

## 1. Contexto

Estado verificado en vivo (Supabase MCP, `kgrfhfwtcanthrymmvkb`, 2026-07-05):

**Filas por tabla:**

| Tabla | Filas |
|---|---|
| `quotes` (EN, activo) | 0 |
| `cotizaciones` (ES, legacy) | **3** |
| `ventas` (ES, legacy) | 0 |

**Policies por tabla:**

| Tabla | Policies | Detalle |
|---|---|---|
| `quotes` | **5** | `Admins manage all quotes` (ALL), `Sellers insert own quotes` (INSERT), `Sellers update own quotes` (UPDATE), `Sellers view own quotes` (SELECT), `Users can manage their own quotes` (ALL) — nótese solapamiento entre "Admins/Sellers" y "Users can manage their own" (deuda ya señalada como SEC-06, fuera de alcance de este RFC) |
| `cotizaciones` | **0** | RLS habilitado sin políticas → inaccesible desde la app (solo `service_role` puede leer/escribir) |
| `ventas` | **0** | Igual que `cotizaciones` |

**Las 3 filas reales de `cotizaciones`** (confirmado, sin modificar nada):

| id | oportunidad_id (→deals) | numero_cotizacion | monto_cotizado | fecha_emision | fecha_validez | estado_cotizacion | fecha_creacion |
|---|---|---|---|---|---|---|---|
| `90000000-...0001` | `60000000-...0001` | COT-CRM-001 | 8500.00 | 2026-05-30 | 2026-06-29 | `enviada` | 2026-06-04 |
| `90000000-...0002` | `60000000-...0002` | COT-CRM-002 | 145000.00 | 2026-05-25 | 2026-06-24 | `borrador` | 2026-06-04 |
| `90000000-...0003` | `60000000-...0003` | COT-CRM-003 | 24000.00 | 2026-06-02 | 2026-07-02 | `aceptada` | 2026-06-04 |

**Integridad referencial verificada:** los 3 `oportunidad_id` existen en `deals` (confirmado con `SELECT id FROM deals WHERE id IN (...)` → 3 de 3 encontrados). No hay filas huérfanas.

**Consumidores de las 4 vistas ES (`vendedores`, `clientes`, `oportunidades`, `actividades`) — verificado por búsqueda en código fuente:**
- `src/services/**/*.js`: **0 referencias** a las vistas como fuente de datos (`.from('vendedores')`, etc.). Las únicas coincidencias de las palabras fueron comentarios JSDoc en español (ej. "Obtiene la actividad reciente (actividades)") — no son llamadas a las vistas.
- `n8n/workflows/**/*.json`: **0 referencias** como nombre de tabla/recurso. La única coincidencia fue texto de un prompt de IA en español dentro de `deal-risk.json` (contenido conversacional, no una referencia a la vista SQL).
- **Conclusión:** las 4 vistas ES no tienen consumidores verificados en este repositorio.

## 2. Problema

El dominio de "cotizaciones/ventas" existe duplicado en dos idiomas: el modelo **EN activo** (`quotes`, consumido por `QuoteDetail.vue` y servicios relacionados, con RLS operativa) y el modelo **ES legacy** (`cotizaciones` con 3 filas reales pero **0 políticas RLS**, por lo que esos datos son hoy **inaccesibles desde la aplicación** — solo alcanzables vía `service_role`). Esto significa que 3 cotizaciones reales existen en la base de datos pero ningún usuario de la app puede verlas, editarlas, ni reportarlas. Además, `ventas` (ES) está vacía y sin políticas, sin equivalente EN operativo claro más allá de lo que ya cubre `deals`.

Mantener esta duplicación fragmenta las métricas de negocio (cotizaciones "reales" existen fuera del alcance de cualquier reporte de la app) y añade superficie de mantenimiento (2 esquemas de cotización a entender).

## 3. Opciones

### Opción B1 — Canónico EN, deprecar ES (recomendada)

**Descripción:** `quotes` es el modelo oficial. Migrar las 3 filas de `cotizaciones` a `quotes` con mapeo de columnas y traducción del enum ES→EN. Eliminar `cotizaciones` y `ventas` tras backup y verificación. Decidir el destino de las 4 vistas ES por separado (ver §5.6).

**Pros:**
- Alineado con el código real: servicios y componentes ya operan sobre `quotes`.
- Recupera las 3 cotizaciones reales para que sean visibles/gestionables desde la app (hoy están "perdidas" por falta de políticas).
- Una sola fuente de métricas de cotizaciones.

**Contras:**
- Requiere migración de datos (acotada: 3 filas) con mapeo de enum y backup obligatorio.
- Debe verificarse el destino de las vistas ES antes de decidir su eliminación (hecho en este RFC: sin consumidores).

**Esfuerzo:** Medio (por el cuidado en la migración, no por el volumen). **Riesgo:** Medio (mitigado con backup + verificación post-migración).

### Opción B2 — Canónico ES

**Descripción:** migrar todo hacia `cotizaciones`/`ventas`; reescribir servicios y componentes del frontend para operar en español.

**Pros:**
- Coherente con la UI en español y el locale `es-CL`.

**Contras:**
- Esfuerzo enorme: reescribir `quotes.service.js` (o equivalente), `QuoteDetail.vue`, políticas RLS completas, y cualquier referencia cruzada.
- Alto riesgo de regresión sin suite de tests (Sprint 3 no ejecutado).
- Contradice directamente el código ya escrito y probado en Sprint 1.

**Esfuerzo:** Alto. **Riesgo:** Alto.

### Opción B3 — Mantener ambos modelos

**Descripción:** no decidir; dejar `quotes` y `cotizaciones`/`ventas` coexistiendo.

**Pros:**
- Cero esfuerzo inmediato.

**Contras:**
- Perpetúa la deuda: `cotizaciones` sigue con 3 filas reales inaccesibles indefinidamente (dato de negocio "atrapado").
- Confusión futura para cualquier persona que audite el esquema.
- No resuelve `SEC-07` (RLS habilitado sin políticas es en sí mismo un hallazgo de seguridad, más allá del problema de duplicación).

**Esfuerzo:** Ninguno. **Riesgo:** Alto por acumulación (deuda que crece, no que se mantiene estable).

## 4. Decisión

**Opción aprobada: B1 — Canónico EN, deprecar ES.**

**Aprobado por:** Project Owner (usuario), sesión Sprint 2 Fase 0.

**Justificación técnica:**

1. **El código fuente ya usa el modelo inglés de forma consistente** — no hay evidencia de que el frontend/servicios vayan a migrar a español; B2 significaría ir contra la dirección ya tomada por el propio proyecto.
2. **Las 3 filas de `cotizaciones` son datos reales huérfanos de acceso** (0 policies): migrarlas a `quotes` es la única forma de que vuelvan a ser útiles para el negocio.
3. **Sin consumidores verificados de las vistas ES** (§1): eliminarlas o mantenerlas como capa de presentación no rompe ningún flujo conocido hoy.
4. **B3 no es neutral**: mantener `cotizaciones` con RLS sin políticas es en sí mismo el hallazgo `SEC-07`; no decidir perpetúa un hallazgo de seguridad, no solo una preferencia de nomenclatura.

## 5. Plan de implementación de B1

> Ninguno de estos pasos se ejecuta en este RFC. Se documentan en el orden exacto en que deben aprobarse y ejecutarse, como migración versionada (dependencia: T-DB-01), con aprobación explícita adicional antes de cualquier DDL/DML real.

### 5.1 Backup obligatorio previo (bloqueante, antes de cualquier DDL/DML)

```sql
-- Backup lógico de las 3 filas antes de tocar nada
CREATE TABLE IF NOT EXISTS public._backup_cotizaciones_20260705 AS
  SELECT * FROM public.cotizaciones;

CREATE TABLE IF NOT EXISTS public._backup_ventas_20260705 AS
  SELECT * FROM public.ventas;

-- Verificar que el backup capturó las 3 filas esperadas
SELECT count(*) FROM public._backup_cotizaciones_20260705; -- debe ser 3
```

> Adicionalmente, se recomienda un backup a nivel de proyecto Supabase (snapshot/point-in-time) antes de ejecutar, independiente del backup lógico de tabla.

### 5.2 Mapeo columna a columna — `cotizaciones` → `quotes`

| Columna origen (`cotizaciones`) | Tipo origen | Columna destino (`quotes`) | Tipo destino | Transformación |
|---|---|---|---|---|
| `id` | `uuid` | *(nuevo `id`)* | `uuid` | **Generar nuevo `id`** con `gen_random_uuid()` — no reutilizar el `id` legacy, para evitar colisión conceptual entre esquemas distintos. |
| `oportunidad_id` | `uuid` | `deal_id` | `uuid` (`NOT NULL`, FK a `deals`) | Copia directa — ya verificado que los 3 valores existen en `deals` (§1). |
| `numero_cotizacion` | `varchar` | `quote_number` | `varchar` (`UNIQUE`, `NOT NULL`) | Copia directa (`COT-CRM-001` etc.) — **verificar antes de migrar que no colisiona con ningún `quote_number` existente en `quotes`** (hoy `quotes` tiene 0 filas, así que no hay colisión posible en este momento). |
| `monto_cotizado` | `numeric` | `amount` | `numeric` (`NOT NULL`, default `0.00`) | Copia directa. |
| `fecha_emision` | `date` | `issue_date` | `date` (`NOT NULL`, default `CURRENT_DATE`) | Copia directa. |
| `fecha_validez` | `date` | `valid_until` | `date` (nullable) | Copia directa. |
| `estado_cotizacion` | `enum estado_cotizacion` | `status` | `varchar` (`CHECK IN` `draft/sent/accepted/rejected/expired`) | **Traducción de enum** (ver tabla §5.2.1). |
| `fecha_creacion` | `timestamptz` | `created_at` | `timestamptz` (default `CURRENT_TIMESTAMP`) | Copia directa. |
| *(no existe)* | — | `owner_id` | `uuid` (FK a `profiles`, nullable) | **No hay columna origen equivalente.** `cotizaciones` no registra un vendedor propio. Se debe **heredar de `deals.owner_id`** vía `JOIN` en el momento de la migración (ver §5.3). |

#### 5.2.1 Traducción de enum `estado_cotizacion` → `status`

| Valor ES (`estado_cotizacion`) | Valor EN (`status` en `quotes`) |
|---|---|
| `borrador` | `draft` |
| `enviada` | `sent` |
| `aceptada` | `accepted` |
| `rechazada` | `rejected` |
| `expirada` | `expired` |

> Verificado: los 5 valores del enum ES (`pg_enum`) mapean 1:1 y sin ambigüedad a los 5 valores permitidos por el `CHECK` de `quotes.status` (verificado con `pg_get_constraintdef` sobre `quotes_status_check`). No hay valores huérfanos que requieran una regla por defecto.

### 5.3 Migración de las 3 filas (INSERT desde SELECT, con JOIN para heredar `owner_id`)

```sql
INSERT INTO public.quotes (id, deal_id, quote_number, amount, issue_date, valid_until, status, owner_id, created_at)
SELECT
  gen_random_uuid(),
  c.oportunidad_id,
  c.numero_cotizacion,
  c.monto_cotizado,
  c.fecha_emision,
  c.fecha_validez,
  CASE c.estado_cotizacion
    WHEN 'borrador'  THEN 'draft'
    WHEN 'enviada'   THEN 'sent'
    WHEN 'aceptada'  THEN 'accepted'
    WHEN 'rechazada' THEN 'rejected'
    WHEN 'expirada'  THEN 'expired'
  END,
  d.owner_id,
  c.fecha_creacion
FROM public.cotizaciones c
JOIN public.deals d ON d.id = c.oportunidad_id;
```

### 5.4 Verificación post-migración (antes de eliminar nada)

```sql
-- Debe devolver 3
SELECT count(*) FROM public.quotes
WHERE quote_number IN ('COT-CRM-001','COT-CRM-002','COT-CRM-003');

-- Verificar que los montos y estados coinciden con el backup fila a fila
SELECT q.quote_number, q.amount, q.status, b.monto_cotizado, b.estado_cotizacion
FROM public.quotes q
JOIN public._backup_cotizaciones_20260705 b ON b.numero_cotizacion = q.quote_number;
```

Criterio de aceptación: 3 filas migradas, montos idénticos, estados traducidos correctamente según §5.2.1, `deal_id`/`owner_id` no nulos.

### 5.5 Eliminación de `cotizaciones` y `ventas`

Solo tras confirmar §5.4 exitoso y con el backup de §5.1 conservado:

```sql
DROP TABLE public.cotizaciones;
DROP TABLE public.ventas;
```

### 5.6 Decisión sobre las 4 vistas ES (`vendedores`, `clientes`, `oportunidades`, `actividades`)

**Verificado en §1: sin consumidores en código ni en n8n.** Dos caminos razonables, a decidir por el Owner en el momento de ejecución (no bloqueante para aprobar este RFC):

- **Mantener** como capa de compatibilidad de solo lectura (documentadas como "vista de presentación en español, no fuente de verdad") — bajo costo de mantenimiento, útil si algún reporte manual las usa fuera del repo.
- **Eliminar** si se confirma que tampoco hay uso externo (BI, exports) — reduce superficie de esquema.

**Recomendación de este RFC:** mantenerlas por ahora (costo de mantenimiento bajo, reversible eliminarlas después), y revisitar en Sprint 5 (limpieza de documentación/esquema) una vez confirmado con el Owner si hay consumo externo al repositorio.

## 6. Rollback

- **Antes de §5.5 (DROP TABLE):** el rollback es trivial — no se ha borrado nada; basta con no continuar y, si se detecta un problema en la verificación (§5.4), eliminar las filas insertadas erróneamente en `quotes` (`DELETE FROM quotes WHERE quote_number IN (...)`) y revisar el mapeo.
- **Después de §5.5 (post eliminación):** restaurar desde el backup lógico:
  ```sql
  INSERT INTO public.cotizaciones SELECT * FROM public._backup_cotizaciones_20260705;
  INSERT INTO public.ventas SELECT * FROM public._backup_ventas_20260705;
  -- Nota: si ya se hizo DROP TABLE, primero hay que recrear la estructura de cotizaciones/ventas
  -- (columnas, tipos, enum estado_cotizacion) antes de este INSERT, usando este RFC §1 como referencia de esquema.
  ```
- Las tablas de backup (`_backup_cotizaciones_20260705`, `_backup_ventas_20260705`) **no se eliminan** como parte de esta migración; quedan como respaldo hasta que se confirme estabilidad en producción (sugerido: mínimo 1 sprint completo, luego evaluar su limpieza en Sprint 5).
- **Nota de riesgo:** todo lo anterior es **DDL/DML real sobre datos de producción** (aunque sean solo 3 filas). Requiere aprobación explícita adicional en el momento de ejecución (más allá de la aprobación de este RFC) y ejecución supervisada paso a paso, igual que T-SEC-01 en Sprint 1.

## 7. Referencias cruzadas

- **T-DB-01** (migraciones versionadas): estos pasos deben quedar como migración versionada trazable, no ejecutarse ad-hoc.
- **SEC-06** (policies solapadas en `quotes`): las 5 policies de `quotes` ya tienen deuda propia (solapamiento `Admins/Sellers` vs `Users can manage their own`) — fuera de alcance de este RFC, pero relevante antes de considerar cerrado el modelo canónico.
- **SEC-07**: hallazgo original de `cotizaciones`/`ventas` con RLS sin políticas, resuelto por esta decisión (eliminación tras migración).
- **`docs/knowledge/03_DATABASE_MAP.md`**: estado documentado previo del esquema.
- **Sprint 5**: revisión final de las vistas ES (§5.6) una vez confirmado uso externo o no.

---

### Referencias
- Verificación en vivo Supabase MCP (2026-07-05): conteo de filas, `pg_policies`, `information_schema.columns`, `pg_enum`, `pg_get_constraintdef`, integridad referencial `oportunidad_id`→`deals`.
- Búsqueda de consumidores: `grep` sobre `src/services/**/*.js` y `n8n/workflows/**/*.json` (0 referencias reales a las vistas ES como fuente de datos).
- `docs/reports/Technical_Debt.md` (TD-P1-08 / ARC-03, TD-P2-01 / SEC-07).
- RFC-0001 (formato replicado).

> **STOP.** RFC generado. No se ejecutó ningún DDL ni DML. A la espera de que el Project Owner commitee este documento y de una aprobación explícita adicional en el momento de ejecutar la migración real de datos (§5).
