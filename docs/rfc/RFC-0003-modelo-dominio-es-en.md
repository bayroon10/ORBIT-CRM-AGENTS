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

> **Nota histórica (2026-07-05):** aquí terminaba la versión inicial del RFC. No se ejecutó DDL/DML. El inventario y plan vigentes continúan en §8, que sustituye las secciones indicadas en caso de conflicto.

## 8. Actualización de inventario y plan ejecutable (2026-07-21)

> **Alcance de esta actualización:** inventario y planificación solamente. Evidencia obtenida con consultas `SELECT`/catálogo contra `kgrfhfwtcanthrymmvkb` y lectura del repositorio. No se ejecutó DDL/DML, no se modificó `src/` y no se realizaron operaciones Git de escritura.
>
> **Precedencia:** esta sección sustituye §§5.1–5.5 y §6 donde exista conflicto. La decisión B1 (modelo canónico EN) se mantiene; se corrigen la estrategia de IDs, el supuesto de `owner_id` y el orden de retiro de las tablas legacy.

### 8.1 Estado vivo confirmado

| Tabla | Existe físicamente | Filas exactas (`COUNT(*)`) | RLS | Policies | Publicación Realtime |
|---|---:|---:|---:|---:|---:|
| `public.cotizaciones` | Sí | **3** | Sí | 0 | No |
| `public.ventas` | Sí | **0** | Sí | 0 | No |
| `public.quotes` | Sí | **0** | Sí | 5 | No |

`quotes` no es una referencia huérfana de una policy: es una tabla física con PK, dos FKs, índices, `CHECK` de estado, trigger de numeración y cinco políticas RLS.

Precondiciones observadas:

- Las 3 `cotizaciones.oportunidad_id` apuntan a `deals` existentes: **0 huérfanas**.
- Colisiones actuales por `quote_number`: **0**.
- Colisiones actuales por `id`: **0**.
- Estados presentes: `aceptada` (1), `borrador` (1), `enviada` (1).
- Los 3 `deals.owner_id` asociados son `NULL`.
- No existe fallback de propietario: 0 candidatos en `leads.owner_id`, 0 en `companies.owner_id`; las 3 filas carecen de candidato verificable.
- El tipo `public.estado_cotizacion` solo es usado por `public.cotizaciones.estado_cotizacion`.

### 8.2 Decisión de estrategia

#### Alternativa A — renombrar tabla y columnas

**Descartada.** `quotes` ya existe y es el contrato activo del frontend. Renombrar `cotizaciones` a `quotes` colisionaría con la tabla existente y obligaría a reconstruir políticas, trigger, constraints, grants e índices. El cambio sería más grande y menos reversible.

#### Alternativa B — copiar a `quotes` y eliminar legacy en el mismo despliegue

**No recomendada.** Es técnicamente posible dentro de una transacción, pero combina recuperación de datos y destrucción del origen sin período de observación. Sin tests automatizados, eleva innecesariamente el costo del rollback.

#### Alternativa C — consolidación en dos migraciones (recomendada)

1. **Migración A:** copiar `cotizaciones` a la tabla `quotes` existente, sin eliminar tablas legacy.
2. Validar RLS, UI y métricas; observar durante al menos un ciclo de release acordado.
3. **Migración B:** solo después de aceptación, eliminar `cotizaciones`, `ventas` y el enum ya sin uso.

Esta estrategia es la más segura porque el código ya consume `quotes`: no requiere un rename atómico ni un cambio simultáneo de contrato. Durante la observación, el origen permanece disponible para comparación y rollback.

### 8.3 Mapeo exacto: `cotizaciones` → `quotes`

| Origen | Tipo/constraint origen | Destino | Tipo/constraint destino | Regla |
|---|---|---|---|---|
| `id` | `uuid NOT NULL`, PK, default `gen_random_uuid()` | `id` | `uuid NOT NULL`, PK | **Preservar el UUID legacy**, previa comprobación de colisión. Mejora trazabilidad y compatibilidad con consumidores externos desconocidos. Sustituye la recomendación anterior de generar un UUID nuevo. |
| `oportunidad_id` | `uuid NOT NULL`, FK `deals(id) ON DELETE CASCADE` | `deal_id` | `uuid NOT NULL`, FK `deals(id) ON DELETE CASCADE` | Copia directa. Guard obligatorio: 0 referencias huérfanas. |
| `numero_cotizacion` | `varchar(50) NOT NULL UNIQUE` | `quote_number` | `varchar(50) NOT NULL UNIQUE`, default `''` | Copia directa. Guard obligatorio: 0 colisiones por número. El trigger no reemplaza valores no vacíos. |
| `monto_cotizado` | `numeric(12,2) NOT NULL` | `amount` | `numeric(12,2) NOT NULL`, default `0.00` | Copia directa, sin redondeo ni conversión. |
| `fecha_emision` | `date NOT NULL` | `issue_date` | `date NOT NULL`, default `CURRENT_DATE` | Copia directa. |
| `fecha_validez` | `date NULL` | `valid_until` | `date NULL` | Copia directa. |
| `estado_cotizacion` | enum `estado_cotizacion`, nullable, default `borrador` | `status` | `varchar(50)`, `CHECK`, default `draft` | Traducir con CASE explícito; ningún `ELSE` silencioso. Un valor desconocido debe abortar la migración. |
| `fecha_creacion` | `timestamptz NULL`, default `CURRENT_TIMESTAMP` | `created_at` | `timestamptz NULL`, default `CURRENT_TIMESTAMP` | Copia directa para preservar auditoría temporal. |
| — | No existe | `owner_id` | `uuid NULL`, FK `profiles(id) ON DELETE SET NULL` | **Bloqueante:** no inferir. Los tres deals/leads/companies carecen de owner. Bairon debe aprobar un `profile.id` válido por cotización o aceptar explícitamente acceso solo administrativo con `NULL`. |

Traducción de estado:

| ES | EN |
|---|---|
| `borrador` | `draft` |
| `enviada` | `sent` |
| `aceptada` | `accepted` |
| `rechazada` | `rejected` |
| `expirada` | `expired` |

**Cambio respecto del plan anterior:** no se permite heredar `d.owner_id`, porque la evidencia viva demuestra que es `NULL` en los tres casos. Migrar con `owner_id = NULL` mantendría los registros fuera del alcance de vendedores: las policies de seller requieren `quotes.owner_id = auth.uid()` y la policy basada en deal requiere `deals.owner_id = auth.uid()`.

### 8.4 Tratamiento de `ventas`

`ventas` no representa cotizaciones y no debe copiarse a `quotes`. La aplicación modela una venta cerrada mediante `deals.stage = 'ganado'`; `SalesService` consulta `deals`, no `ventas`.

| Columna legacy | Relación conceptual canónica | Decisión |
|---|---|---|
| `id uuid` | No existe entidad `sale` separada | No migrar mientras la tabla siga vacía. |
| `oportunidad_id uuid` | `deals.id` | Identifica el deal ya existente; no crear otra entidad. |
| `cliente_id uuid` | `deals.company_id` | Dato redundante; si aparecieran filas, exigir consistencia antes de decidir. |
| `vendedor_id uuid` | `deals.owner_id` | Dato redundante; no inferir ni sobrescribir ownership. |
| `monto_venta numeric(12,2)` | `deals.value` | Semánticamente cercano, pero no se debe sobrescribir sin reconciliación fila a fila. |
| `fecha_venta date` | Sin equivalente exacto | `stage_updated_at` no es un sustituto garantizado; requeriría diseño de `closed_at` si hubiera datos. |
| `canal_venta varchar(100)` | Sin equivalente | Requeriría extensión del modelo si hubiera datos. |
| `fecha_creacion timestamptz` | Sin equivalente exacto | No copiar automáticamente a `deals.created_at`. |

**Guard de ejecución:** `SELECT count(*) FROM public.ventas` debe seguir devolviendo 0. Si devuelve más de 0, detener T-ARC-02 y abrir una decisión de modelo separada; no hacer `DROP` ni forzar esas filas dentro de `quotes` o `deals`.

### 8.5 Inventario completo de dependencias de BD

#### `cotizaciones`

- PK: `cotizaciones_pkey (id)`.
- UNIQUE: `cotizaciones_numero_cotizacion_key (numero_cotizacion)`.
- FK: `oportunidad_id → deals.id ON DELETE CASCADE`.
- Índice: `idx_cotizaciones_oportunidad_id`.
- RLS habilitado, **0 policies**.
- Triggers: ninguno.
- Funciones/vistas que la referencien: ninguna detectada.
- Grants: `anon`, `authenticated`, `postgres` y `service_role`; RLS sigue denegando a clientes al no existir policies.

#### `ventas`

- PK: `ventas_pkey (id)`.
- FKs: `cliente_id → companies.id ON DELETE RESTRICT`, `oportunidad_id → deals.id ON DELETE RESTRICT`, `vendedor_id → profiles.id ON DELETE RESTRICT`.
- Índices: `idx_ventas_cliente_id`, `idx_ventas_fecha_venta`, `idx_ventas_oportunidad_id`, `idx_ventas_vendedor_id`.
- RLS habilitado, **0 policies**.
- Triggers: ninguno.
- Funciones/vistas que la referencien: ninguna detectada.
- Grants: mismos cuatro roles.

#### `quotes`

- PK: `quotes_pkey (id)`.
- UNIQUE: `quotes_quote_number_key (quote_number)`.
- CHECK: `status ∈ {draft, sent, accepted, rejected, expired}`.
- FKs: `deal_id → deals.id ON DELETE CASCADE`; `owner_id → profiles.id ON DELETE SET NULL`.
- Índices: `idx_quotes_deal`, `idx_quotes_owner`.
- Trigger: `trg_generate_quote_number BEFORE INSERT`.
- Función: `generate_quote_number()`; solo genera número cuando `NEW.quote_number` es `NULL` o vacío.
- Policies: `Admins manage all quotes`, `Sellers insert own quotes`, `Sellers update own quotes`, `Sellers view own quotes`, `Users can manage their own quotes`.
- Vistas dependientes: ninguna detectada.
- Publicación Realtime: ninguna de las tres tablas está publicada.

La única migración local que define estos objetos es `supabase/migrations/20260705054055_remote_schema.sql`. Es un baseline histórico y **no debe editarse**; la consolidación debe agregarse como migraciones nuevas.

### 8.6 Inventario de código

#### Cambios obligatorios para coherencia funcional

| Archivo | Cambio futuro | Por qué |
|---|---|---|
| `src/services/dashboard.service.js` | Cambiar `cotizacionesEnviadas` para contar `quotes.status = 'sent'` en vez de `deals.stage = 'cotizado'`, o renombrar explícitamente la métrica si el negocio quiere medir deals cotizados. | Hoy la métrica se llama “cotizaciones enviadas” pero no consulta `quotes`; las filas migradas no aparecerían en el dashboard. Requiere decisión semántica del Owner. |

#### Sin cambio de esquema requerido; validar en regresión

- `src/services/quotes.service.js`: único acceso directo a `.from('quotes')`; cubre listar, detalle, crear, actualizar y borrar.
- `src/views/Quotes.vue`: creación/listado; el payload no envía `owner_id` ni `issue_date` y depende de defaults/policies.
- `src/views/QuoteDetail.vue`: lectura/edición/borrado de `deal_id`, `amount`, `status` y `valid_until`.
- `src/services/sales.service.js`: confirma que ventas canónicas son `deals` con `stage = 'ganado'`.
- `src/views/Sales.vue`: presenta los deals ganados; no consulta `ventas`.
- `src/views/Dashboard.vue`: consume las métricas y debe validar el resultado de la decisión anterior.
- `src/router/index.js`: rutas `/quotes`, `/quotes/:id` y `/sales`; no requieren rename.
- `src/components/OrbitHeader.vue` y `src/components/OrbitSidebar.vue`: etiquetas españolas de presentación; no son referencias al esquema y no deben traducirse.

#### Coincidencias textuales sin dependencia de tabla

- `src/views/Deals.vue`: “pipeline de ventas”.
- `src/views/QuoteDetail.vue`, `src/views/Quotes.vue`, `src/views/Sales.vue`, `src/views/Dashboard.vue`, `src/components/OrbitHeader.vue`, `src/components/OrbitSidebar.vue`: texto de UI y nombres de variables en español.
- Los workflows n8n solo contienen la palabra “ventas” en prompts de IA; no referencian `cotizaciones`, `ventas` ni `quotes` como recurso de BD.

**Conclusión de impacto:** no hay código en `src/` que consulte las tablas legacy. La migración de datos es compatible con el contrato actual. Solo `dashboard.service.js` requiere una decisión/corrección para que la métrica represente realmente el modelo canónico.

### 8.7 Orden propuesto para la ejecución real (Nivel 3 separado)

#### Puerta 0 — decisiones y aprobación

1. Bairon clasifica las 3 filas como negocio real o QA.
2. Bairon define un propietario válido por fila, o acepta por escrito que queden administrativas con `owner_id = NULL`.
3. Bairon decide si “Cotizaciones enviadas” significa `quotes.status = 'sent'` o `deals.stage = 'cotizado'`.
4. Aprobar ventana, responsables, rollback y retención del respaldo.

Sin estas decisiones no se crea ni aplica la migración.

#### Fase 1 — preparación sin tocar producción

1. Crear una migración nueva; no editar `20260705054055_remote_schema.sql`.
2. Preparar backup fuera del repositorio público y un snapshot/PITR administrado. No crear backups con datos dentro de `docs/`, `database/backups/` versionable ni el esquema `public` como solución permanente.
3. Preparar SELECTs de preflight y post-validación.
4. Preparar el ajuste separado de `dashboard.service.js` si Bairon confirma la métrica canónica.
5. Revisar SQL y probarlo en una rama/entorno no productivo restaurado desde esquema equivalente.

#### Fase 2 — Migración A: consolidar sin eliminar

Dentro de una única transacción supervisada:

1. Revalidar conteos y drift: `cotizaciones = 3`, `ventas = 0`, 0 huérfanas, 0 colisiones de ID/número y solo estados mapeados.
2. Verificar que la matriz de `owner_id` aprobada referencia perfiles existentes.
3. Insertar las 3 filas en `quotes`, preservando `id`, fechas, monto y número; traducir estado con CASE exhaustivo.
4. Verificar igualdad fila a fila entre origen y destino, incluida traducción de estado.
5. Probar acceso con rol admin y con los sellers aprobados; comprobar que ningún seller ve quotes ajenas.
6. Si cualquier aserción falla, provocar rollback completo. No continuar ni “corregir” datos ad hoc.

No eliminar `cotizaciones`, `ventas` ni `estado_cotizacion` en esta fase.

#### Fase 3 — despliegue y observación

1. Desplegar el ajuste de métrica solo si fue aprobado.
2. Smoke tests manuales: lista `/quotes`, detalle, edición, filtros, creación, dashboard y `/sales`.
3. Comparar conteos y montos con el respaldo.
4. Observar al menos el período acordado y confirmar que no existen consumidores externos ni escrituras nuevas en legacy.

#### Fase 4 — Migración B: retiro definitivo

Solo tras aceptación explícita adicional:

1. Revalidar que `ventas` sigue vacía y que `cotizaciones` no recibió nuevas filas.
2. Revalidar que no aparecieron views, funciones, FKs, triggers o consumers externos.
3. Eliminar `cotizaciones` y `ventas` en una migración versionada.
4. Eliminar `estado_cotizacion` únicamente después de confirmar que no tiene otros usos.
5. Ejecutar validaciones de catálogo, RLS y aplicación.
6. Retener el respaldo según política acordada; su eliminación es otra decisión destructiva.

### 8.8 Criterios de aceptación

- Cada fila legacy aparece exactamente una vez en `quotes` con el mismo `id`, deal, número, monto y fechas.
- La traducción de estado es exacta y no existen valores fuera del `CHECK`.
- No hay colisiones ni filas huérfanas.
- La visibilidad RLS coincide con la matriz de owners aprobada.
- Admin puede gestionar las tres; un seller solo puede gestionar las asignadas.
- `/quotes`, `/quotes/:id`, creación/edición, dashboard y `/sales` pasan smoke test.
- Tras Migración B no existen `cotizaciones`, `ventas` ni `estado_cotizacion`, y no quedan dependencias inválidas.
- El historial de migraciones local/remoto queda alineado.

### 8.9 Riesgos y controles

| Riesgo | Impacto | Control |
|---|---|---|
| Ownership inexistente | Alto: datos migrados invisibles para sellers o asignados al usuario incorrecto | Decisión explícita por fila; prohibido inferir. Pruebas RLS con usuarios reales. |
| Métrica engañosa del dashboard | Medio: negocio cree medir quotes pero cuenta deals | Resolver semántica y cambiar `dashboard.service.js` por separado. |
| Drift entre planificación y ejecución | Alto | Repetir todos los guards inmediatamente antes de insertar y antes de retirar legacy. |
| `ventas` recibe filas nuevas | Alto: pérdida de datos si se elimina | Guard `count(*) = 0`; si falla, detener y rediseñar entidad de venta. |
| Colisión de UUID o número | Alto | Checks previos; abortar transacción, nunca regenerar/sobrescribir silenciosamente. |
| Policies solapadas en `quotes` | Medio | Probar acceso efectivo; tratar SEC-06 por separado, sin mezclarlo silenciosamente con T-ARC-02. |
| Consumidor externo no visible en repo | Alto | Confirmación del Owner y período de observación antes del DROP. |
| Ausencia de tests automatizados | Alto | Entorno de ensayo, smoke tests manuales documentados y migración en dos fases. |
| Backup expuesto en repo público | Alto | Snapshot administrado + export seguro fuera del repo; verificar `.gitignore` antes de cualquier artefacto local. |
| Frontend y BD desplegados fuera de orden | Bajo en este caso: frontend ya usa `quotes` | Mantener contrato `quotes`; desplegar solo la corrección de métrica de forma coordinada. |

### 8.10 Estado de salida de esta fase

El inventario está completo para el alcance del repositorio y catálogo PostgreSQL. La ejecución permanece **bloqueada como Nivel 3** hasta resolver ownership, semántica de la métrica, backup y aprobación explícita. Esta actualización no autoriza aplicar migraciones ni modificar código.

## 9. Decisiones del Owner (resolviendo bloqueos de §8)

> **Aprobado por:** Bairon (Project Owner). **Fecha:** 2026-07-22. Esta sección resuelve las dos incógnitas bloqueantes identificadas en §8 (ownership y semántica de métrica). No se ejecutó ningún DDL/DML como parte de esta actualización; es documentación de la decisión, previa a la ejecución real (Nivel 3, separada).

### 9.1 Ownership de las 3 cotizaciones legacy (COT-CRM-001/002/003)

**Decisión:** las 3 cotizaciones se asignarán a `profiles.id = '83c12ae6-0d10-4392-b3fc-cda014dd8a64'` (Administrador General, `admin@orbitcrm.test`).

**Justificación:**
- Son datos seed/demo: UUIDs secuenciales (`90000000-...0001/2/3` sobre deals `60000000-...0001/2/3`) y mismo timestamp de creación en lote (`fecha_creacion` idéntico en las 3 filas), consistente con una carga por script, no con una captura orgánica fila por fila.
- No hay owner recuperable por ninguna vía verificada: `deals.owner_id`, `leads.owner_id` y `companies.owner_id` son `NULL` en los 3 casos (§8.1).
- El otro candidato admin (`qa-admin@orbitcrm.test`) fue descartado: es una cuenta de QA creada el 2026-06-30, 26 días después de que las cotizaciones fueron emitidas (2026-05-25 a 2026-06-02) y posterior también a su `fecha_creacion` en BD (2026-06-04) — no puede haber sido la autora de datos que ya existían antes de que la cuenta existiera.

**Efecto sobre el mapeo de §8.3:** la fila `owner_id` del mapeo `cotizaciones → quotes` queda resuelta: las 3 filas migradas deben insertarse con `owner_id = '83c12ae6-0d10-4392-b3fc-cda014dd8a64'`, no `NULL` y no heredado de `deals.owner_id`.

### 9.2 Métrica `dashboard.service.js` — `cotizacionesEnviadas`

**Decisión:** corregir la métrica para consultar `quotes.status = 'sent'`, en lugar de `deals.stage = 'cotizado'`.

**Justificación:** el nombre de la métrica debe coincidir con lo que realmente mide. La query actual mide una cosa distinta a lo que su nombre indica (etapa de negociación del deal, no estado de una cotización formal).

**Efecto sobre §8.6:** el cambio en `src/services/dashboard.service.js` queda confirmado como obligatorio (ya no condicional a una decisión pendiente). El resto de §8.6 (archivos a validar en regresión, coincidencias textuales sin dependencia) no cambia.

### 9.3 Estado de los bloqueos de §8

| Bloqueo (§8) | Estado | Resolución |
|---|---|---|
| Ownership de las 3 cotizaciones | **Resuelto** | §9.1 — `owner_id = '83c12ae6-0d10-4392-b3fc-cda014dd8a64'` |
| Semántica de `cotizacionesEnviadas` | **Resuelto** | §9.2 — migrar la query a `quotes.status = 'sent'` |
| Backup fuera del repositorio público | Pendiente | Sin cambios; sigue siendo condición de Fase 1 (§8.7) |
| Período de observación y aprobación de ejecución | Pendiente | Sin cambios; sigue siendo condición de Puerta 0 / Fase 3 (§8.7) |

La ejecución real de la migración (Fases 1–4 de §8.7) sigue clasificada como **Nivel 3** y requiere aprobación explícita adicional en el momento de ejecutar. Esta sección únicamente cierra las dos decisiones de negocio que bloqueaban la planificación.
