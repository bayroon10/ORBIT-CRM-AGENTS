# ORBIT-0000: Migración de Workspace

**Fecha:** 2026-07-10
**Nivel:** 3 (aprobación explícita concedida por Bairon)
**Estado:** COMPLETADO
**Ruta origen:** C:\Users\bairo\OneDrive\Escritorio\automotizado
**Ruta destino:** C:\Dev\orbit-crm
**Método:** robocopy /E /COPY:DAT /DCOPY:T /R:1 /W:1 /XJ /A-:SH
**Alternativa:** B (preservar .git)

## Motivo

El proyecto residía dentro de OneDrive, lo que sincronizaba a la nube secretos
(.env, .env.n8n) y el store cifrado de n8n (.n8n-data/, incluida su encryptionKey).
Se migra fuera de OneDrive para eliminar esa exposición.

## Fase 0 - Pre-copia

- 0.1 Reparse points OneDrive: 0 archivos online-only (todo hidratado). Verificado.
- 0.2 Procesos node: 8 procesos activos, TODOS servidores MCP (filesystem, n8n-mcp,
  supabase, github, playwright). Ninguno era vite dev ni escribia en el origen.
  DESVIACION justificada: NO se detuvieron (matarlos rompe las herramientas MCP y
  podria abortar la sesion). El origen ya estaba en reposo (contenedores detenidos).
- 0.3 Backup: creado backup_ORBIT-0000/ en el origen con .env.bak, .env.n8n.bak,
  n8n-data.bak/, docker-compose.bak.yml.

## Copia

robocopy: 1058 dirs / 5825 archivos / 190.78 MB copiados, 0 errores, 0 no coincidencias.
Log: C:\Dev\orbit-crm-migration.log

## Validaciones (7 checks)

- [Check 1] git status / git log: PASS - HEAD b1ad698, ahead 6, mismos 6 commits,
  mismos 7 archivos modificados y untracked identicos.
- [Check 2] Hash .env origen vs destino:
  0F310C784EAE05EADA4977D004FBAACB5F1FDC5DF79DAD40D78298EF9D562DCD -> MATCH.
- [Check 3] Tamano .n8n-data: origen=46224473 bytes, destino=46224473 bytes -> MATCH.
- [Check 4] Archivos sensibles: .env, .env.n8n, .n8n-data/database.sqlite,
  .git/HEAD -> todos presentes.
- [Check 5] Rutas absolutas viejas: ninguna en docker-compose.yml (bind mount relativo
  ./.n8n-data). .env es byte-identico al origen (hash MATCH), sin drift de rutas.
- [Check 6] n8n: HTTP 200 {"status":"ok"} en localhost:5678. Mount confirmado en
  C:\Dev\orbit-crm\.n8n-data. 4 workflows cargados: Deal Risk Agent, Weekly Summary
  Agent, Lead Qualifier Agent, Deal Risk Agent v2.
- [Check 7] ngrok: contenedor orbit_ngrok Running, RestartCount=0, ExitCode=0.
  Estabilidad prolongada confirma tunel establecido (ngrok sale al instante ante
  authtoken/dominio invalidos). Prueba HTTP publica end-to-end no ejecutada para no
  leer el valor de NGROK_DOMAIN (secreto).

## Desviaciones respecto al plan

1. Procesos node NO detenidos (Paso 0.2): eran todos MCP; detenerlos era daninos e
   innecesario. Origen igualmente en reposo.
2. Contenedores viejos removidos: los contenedores orbit_n8n/orbit_ngrok (nombres fijos)
   impedian levantar desde la nueva ruta. Se detuvieron, se re-sincronizo .n8n-data (sin
   divergencia, tamanos iguales), se removieron con docker rm y se recrearon desde
   C:\Dev\orbit-crm. Reversible: docker compose up -d desde la ruta antigua.

## Notas

- Directorio origen en OneDrive NO borrado (se conserva como backup).
- No se ejecuto git push, git reset, git rebase.
- .env NO modificado (solo copiado; hash identico).
- NO se ejecuto npm install.
- Bind mounts de Docker son relativos: no requirieron edicion.

## Reversion

1. docker compose down desde C:\Dev\orbit-crm
2. docker compose up -d desde C:\Users\bairo\OneDrive\Escritorio\automotizado
3. (Opcional) borrar C:\Dev\orbit-crm
