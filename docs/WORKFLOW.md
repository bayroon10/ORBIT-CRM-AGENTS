# Workflow de desarrollo — OrbitCRM

> Cómo se construye este proyecto: un ciclo de trabajo multi-agente con
> verificación por evidencia en cada paso, no por confianza.

## Por qué existe este documento

OrbitCRM no se construye con un solo asistente escribiendo código a ciegas.
Se construye con **tres roles separados, cada uno con una responsabilidad
distinta**, y una regla no negociable: ningún paso se da por bueno hasta que
hay evidencia real (output de comando, SQL ejecutado, screenshot, diff) que
lo confirme. "Debería funcionar" no es un estado válido en este proyecto.

Este documento describe el proceso para que sea repetible, auditable, y
entendible por cualquiera que revise el repo — incluido un recruiter
evaluando cómo se trabajó, no solo qué se construyó.

## Los roles

| Rol | Herramienta | Responsabilidad |
|---|---|---|
| **Arquitecto** | Claude | Diseña la tarea, define restricciones, revisa evidencia, enseña el razonamiento detrás de cada decisión |
| **Ejecutor** | Antigravity (Kiro) | Ejecuta cambios de código, filesystem, git, terminal — bajo instrucciones estructuradas y límites explícitos |
| **QA** | Comet | Verifica en un navegador real que lo que se construyó funciona de punta a punta |

Ninguno de los tres confía en el reporte de otro sin evidencia verificable.

## El ciclo (loop)

```
1. DETECCIÓN
   Un bug, hallazgo o tarea nueva se identifica (manualmente o vía auditoría)
   y se documenta — nunca se arregla "de paso" sin registrarlo primero.
        │
        ▼
2. DISEÑO DEL PROMPT (Arquitecto)
   Se redacta un prompt estructurado en 5 partes obligatorias:
     - Contexto explícito (qué se sabe, qué se verificó, qué NO se sabe)
     - Objetivo medible (una tarea concreta, no un objetivo vago)
     - Restricciones explícitas (qué archivos/tablas NO tocar)
     - Verificación obligatoria (build / browser / SQL — no "revisar visualmente")
     - Formato de retorno estructurado (qué debe reportar el ejecutor)
        │
        ▼
3. EJECUCIÓN (Antigravity)
   Ejecuta la tarea. Si encuentra algo fuera de lo esperado (permisos
   faltantes, un archivo ignorado por git, un supuesto que no se cumple),
   PARA y reporta — no improvisa un atajo por su cuenta.
        │
        ▼
4. VERIFICACIÓN POR EVIDENCIA (Arquitecto + Bairon)
   Se revisa el output real: diffs línea por línea, resultados de SQL,
   logs de build. No se acepta un resumen narrado como prueba de que algo
   funciona.
        │
        ▼
5. GATE DE APROBACIÓN (Bairon) — solo si es Nivel 3
   Cambios que tocan: git push a main, base de datos viva, .env, RLS,
   funciones SECURITY DEFINER → requieren un "APROBADO" explícito antes de
   ejecutarse. Sin excepciones, sin importar cuán simple parezca el cambio.
        │
        ▼
6. QA EN NAVEGADOR REAL (Comet)
   Una vez desplegado, se verifica el comportamiento real en el entorno que
   corresponde (nunca asumir que local == producción). Se confirma con
   screenshots y texto de página, no con "parece que anduvo".
        │
        ▼
7. CIERRE
   Si todo lo anterior pasa: se documenta como resuelto (con fecha) en el
   archivo de referencia correspondiente (ej. DATA_CONTRACTS.md) y se
   vuelve al paso 1 con la siguiente tarea.

   Si algo falla en cualquier paso: se vuelve al paso 2 con la información
   nueva — nunca se "parchea rápido" saltándose el ciclo.
```

## Reglas no negociables (aprendidas de incidentes reales del proyecto)

Estas reglas existen porque cada una vino de un error real que costó tiempo:

1. **Nunca confiar en un reporte narrado sin evidencia cruda.** Pedir siempre
   el output real del comando, no el resumen. (Origen: reportes de éxito que
   no coincidían con el estado real del deploy.)

2. **Local ≠ producción, siempre verificar cuál se está probando.** Un QA
   contra el entorno equivocado da falsos negativos. (Origen: Comet probó
   contra un deploy viejo porque el código nunca había hecho push.)

3. **Cambios Nivel 3 requieren aprobación humana explícita, sin excepción.**
   Ni siquiera si el cambio "es obviamente seguro". (Origen: regla
   preventiva tras el manejo de credenciales sensibles.)

4. **Si falta un permiso o algo no se puede verificar, se para y se avisa —
   nunca se busca un atajo alternativo no autorizado** (ej. usar una
   service_role_key en un script suelto en vez de esperar el MCP correcto).
   (Origen: incidente de credencial expuesta en script temporal.)

5. **Todo hallazgo se documenta antes de arreglarse**, en un archivo de
   referencia versionado (`docs/DATA_CONTRACTS.md` para datos, RFCs para
   decisiones de arquitectura). El código cambia; el porqué de una decisión
   se pierde si no queda escrito.

6. **Ningún commit mezcla cambios de tareas distintas.** Se usa `git add`
   selectivo (o `git add -p`) para que cada commit cuente una sola historia
   coherente.

---

## Checklist operativo — para usar en cada tarea nueva

Copiar y completar antes de escribir el prompt para Antigravity:

```
[ ] ¿La tarea está definida como UN objetivo medible, no varios mezclados?
[ ] ¿Restricciones explícitas: qué archivos/tablas NO se tocan?
[ ] ¿Es Nivel 3 (push a main / DB viva / .env / RLS / SECURITY DEFINER)?
    → Si sí: el prompt debe pedir que PARE antes de ejecutar esa parte.
[ ] ¿El prompt pide verificación con evidencia cruda (output real), no resumen?
[ ] ¿El prompt especifica el formato de retorno esperado?

Después de la ejecución:
[ ] ¿Revisé el diff/output real, no solo el resumen narrado?
[ ] ¿Coincide lo reportado con la evidencia mostrada?
[ ] Si es Nivel 3: ¿di el "APROBADO" explícito antes del paso crítico?
[ ] ¿Actualicé el documento de referencia correspondiente con el hallazgo
    resuelto y la fecha?

Antes de cerrar la tarea:
[ ] ¿Se verificó en el entorno correcto (local vs. producción)?
[ ] ¿Hay evidencia visual o de datos (screenshot, SQL result) del resultado
    final, no solo "el build pasó"?
```

---

*Este documento se actualiza cada vez que un incidente nuevo revela una regla
que faltaba. Última actualización: 2026-07-31.*
