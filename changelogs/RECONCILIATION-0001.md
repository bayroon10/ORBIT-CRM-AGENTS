# Reconciliacion Git: Local -> Remote (RECONCILIATION-0001)

**Fecha:** 2026-07-10
**Nivel:** 3 (aprobado por mentor y product owner)
**Estado:** COMPLETADO (rescate de trabajo unico: PENDIENTE de decision)

## Rescate de WIP
- Rama de respaldo: wip/pre-sprint0-local (pusheada a origin)
- Commit de respaldo: f6dd386 (21 archivos, 1818 inserciones)
- Correccion de leak previa: backup_ORBIT-0000/ anadido a .gitignore; verificado con
  git add -A --dry-run que NO se stageo ningun .env, .env.bak, .n8n-data ni database.sqlite.

## Alineacion
- Metodo: fast-forward b1ad698..6b1260d (sin merge commit, sin --force).
- main local ahora == origin/main.
- 6 commits incorporados del remoto:
  - 4ae882f security(T-SEC-01): remove plaintext credential storage from provider_settings
  - f18ba64 feat(auth): migrar fuente de verdad de roles a profiles.role (T-SEC-03)
  - d4d6556 docs: actualizar AGENTS.md y ARCHITECTURE.md post T-SEC-03
  - c538ece docs(rfc): RFC-0002 (multi-tenancy) y RFC-0003 (modelo ES/EN)
  - 080cdda docs(rfc): RFC-0001 (credential storage)
  - 6b1260d chore(db): baseline del esquema vivo con Supabase CLI (T-DB-01)

## Trabajo unico (main vs wip)
- src/services/leads.service.js: ANADE metodo getLeadAiFields(id) (solo lectura de campos
  AI). Unico, sin riesgo. -> Candidato a RESCATE.
- src/views/LeadDetail.vue: reemplaza la llamada directa al webhook n8n (que enviaba
  X-Webhook-Secret desde el frontend) por la Edge Function quick-processor que inyecta el
  secreto en el servidor. Mejora de seguridad. Depende de:
    - Edge Function quick-processor -> EXISTE y ACTIVE (verify_jwt=true) [verificado via MCP]
    - Metodo getLeadAiFields (arriba).
  RIESGO: el fetch del WIP no envia header Authorization y la funcion exige JWT
  (verify_jwt=true) -> probablemente 401 tal como esta. Rescate requiere anadir el token
  de sesion. -> RESCATE CON AJUSTE (pendiente de aprobacion).
- Resto del WIP (ProviderSettingsView.vue, roles.js, whatsapp.service.js): ya cubierto por
  el remoto (superconjunto). -> DESCARTAR (evita regresar T-SEC-01).

## Verificacion de seguridad post-alineacion
- T-SEC-01 (credenciales texto plano en ProviderSettingsView): APLICADO (sin credential_value).
- T-SEC-03 (router sin user_metadata): APLICADO (router usa profiles.role).
- F-SEC-01 (trigger handle_new_user): SIGUE ABIERTO. Toma role de raw_user_meta_data->>'role'
  con fallback 'seller' -> escalada de privilegios en signup. Sin migracion que lo corrija.
- F-SEC-02 (SECURITY DEFINER sin search_path): SIGUE ABIERTO en auth_tenant_id,
  handle_new_user, invoke_n8n_webhook, is_admin_or_higher. Solo is_admin fija search_path.

## Observaciones
- is_admin_or_higher() usa fallback a auth.jwt() -> user_metadata ->> role, user-controllable
  en algunos flujos -> revisar junto con F-SEC-01/T-SEC-03.
- invoke_n8n_webhook() hardcodea una URL ngrok antigua en la BD.
- La rama de respaldo NO se borra (contiene el unico backup del WIP).

## Desviaciones
- A.1 simplificado: rama creada con git checkout -b (el WIP se traslada solo) en vez de
  stash/pop; resultado identico, menor riesgo de conflicto.

---

## Actualizacion (Higiene + PR)

- .gitignore fixeado en main: anadido backup_ORBIT-0000/, *.backup, *.bak.
  Commit b4276af, pusheado a origin/main (6b1260d..b4276af).
- git add -A --dry-run: verificado, ya NO muestra archivos de backup_ORBIT-0000/.
- Rama feat/lead-ai-edge-refresh (commit 7050398) pusheada. Build: PASA (vite ~9s).
- PR: NO se pudo crear por automatizacion (gh no instalado; token MCP GitHub sin
  permiso de escritura). Crear manualmente en:
  https://github.com/bayroon10/ORBIT-CRM-AGENTS/pull/new/feat/lead-ai-edge-refresh
  base=main, head=feat/lead-ai-edge-refresh. NO mergear sin revisar diff de LeadDetail.vue.
