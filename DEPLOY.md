# Guía de Despliegue en Producción — OrbitCRM (Vercel + Supabase)

> **Documentación Técnica de Infraestructura y DevOps**  
> Preparado para despliegue público en Vercel conectado a Supabase Producción (`kgrfhfwtcanthrymmvkb`).

---

## 1. Arquitectura de Despliegue

OrbitCRM es una aplicación Web SPA (Single Page Application) desacoplada:

```
┌─────────────────────────────────────────────────────────────┐
│                    Navegador del Usuario                    │
└──────────────┬──────────────────────────────┬───────────────┘
               │ (1) Carga SPA (HTML/JS/CSS)  │ (2) HTTPS REST / Realtime (anon key)
               ▼                              ▼
┌──────────────────────────────┐ ┌─────────────────────────────┐
│         Vercel CDN           │ │     Supabase Producción     │
│   (Hosting Frontend / Vite)  │ │   (PostgreSQL + Auth + RLS) │
└──────────────────────────────┘ └──────────────┬──────────────┘
                                                │ (3) Webhooks (Service Role Key / DB Trigger)
                                                ▼
                                 ┌─────────────────────────────┐
                                 │   n8n Automation Cloud      │
                                 │ (AI Lead Scoring / Risk)    │
                                 └─────────────────────────────┘
```

1. **Frontend (Vercel CDN):** Servidor estático global. Compilado con Vite (`npm run build`), genera assets optimizados en `/dist`.
2. **Backend / Base de Datos (Supabase Cloud):** Gestiona Autenticación (JWT), Base de Datos PostgreSQL y Reglas de Seguridad a Nivel de Fila (RLS).
3. **Automatizaciones (n8n):** Orquestador de flujos IA (Gemini). Se comunica mediante Service Role Key desde el backend seguro de n8n, nunca desde el navegador.

---

## 2. Variables de Entorno Requeridas en Vercel

En Vite, solo las variables que comienzan con el prefijo `VITE_` son embebidas en el código JavaScript final que descarga el usuario.

### Configuración en Vercel Dashboard (`Settings` -> `Environment Variables`):

| Variable | Descripción / Valor | Alcance en Producción |
|---|---|---|
| `VITE_SUPABASE_URL` | `https://kgrfhfwtcanthrymmvkb.supabase.co` | Production, Preview |
| `VITE_SUPABASE_ANON_KEY` | *(Anon Key pública de tu proyecto Supabase)* | Production, Preview |
| `VITE_N8N_WEBHOOK_URL` | `https://tu-instancia-n8n.com/webhook/lead-qualifier` | Production, Preview |
| `VITE_N8N_WEBHOOK_SECRET` | *(Secret para firma/autenticación de webhooks)* | Production, Preview |

> ⚠️ **DIRECTIVA DE SEGURIDAD CRÍTICA:**  
> **NUNCA** agregues `SUPABASE_SERVICE_ROLE_KEY` ni `VITE_SUPABASE_SERVICE_ROLE_KEY` en Vercel. La Service Role Key omite por completo todas las políticas RLS de Supabase. Si esa clave llega al navegador, cualquier usuario podría leer o borrar toda la base de datos.

---

## 3. Configuración de Enrutamiento SPA (`vercel.json`)

Vue Router utiliza `history mode` para proporcionar URLs limpias (ej. `/leads`, `/deals`, `/settings`). 

Cuando un usuario entra a `https://orbit-crm.vercel.app/` y navega, el navegador no refresca la página. Pero si el usuario recarga la ventana estando en `/deals`, Vercel buscará un archivo físico `/deals` y devolverá un error `404 Not Found`.

Para resolver esto, el repositorio incluye un archivo [`vercel.json`](file:///c:/dev/orbit-crm/vercel.json) en la raíz:

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```
*Explicación DevOps:* Esta regla instruye a Vercel a redirigir internamente todas las peticiones de rutas al `index.html`, permitiendo que Vue Router capture la URL en el cliente y renderice la vista adecuada.

---

## 4. Aplicación de Migraciones Pendientes en Supabase Producción

El estado de migraciones fue verificado contra la CLI de Supabase:
- Migraciones `20260705054055` a `20260722115547`: **Aplicadas en Producción**.
- Migración `20260727000000_security_fixes_sec_vuln_01_02_04.sql` (Fixes RLS de automatizaciones, reasignación admin en leads/deals y webhook en workspace_settings): **Pendiente en Producción**.

### Pasos para aplicar en Producción:
1. Abre tu **Supabase Dashboard** (`https://supabase.com/dashboard/project/kgrfhfwtcanthrymmvkb`).
2. Ve a **SQL Editor** -> **New Query**.
3. Copia y pega el contenido completo del archivo [`supabase/migrations/20260727000000_security_fixes_sec_vuln_01_02_04.sql`](file:///c:/dev/orbit-crm/supabase/migrations/20260727000000_security_fixes_sec_vuln_01_02_04.sql).
4. Haz clic en **Run**.

---

## 5. Guía Paso a Paso para Despliegue en la UI de Vercel

### Paso 1: Iniciar Sesión en Vercel
1. Ingresa a [https://vercel.com](https://vercel.com) e inicia sesión con tu cuenta de **GitHub**.

### Paso 2: Importar el Repositorio
1. En el Dashboard de Vercel, haz clic en el botón **"Add New..."** -> **"Project"**.
2. Selecciona tu repositorio de GitHub: `bayroon10/ORBIT-CRM-AGENTS`.
3. Haz clic en **"Import"**.

### Paso 3: Configurar el Proyecto (Configure Project)
1. **Project Name:** `orbit-crm` (o el nombre que prefieras).
2. **Framework Preset:** Selecciona **Vite** (Vercel lo detectará automáticamente).
3. **Root Directory:** `./` (dejar por defecto).
4. **Build and Output Settings:** Dejar por defecto:
   - Build Command: `npm run build`
   - Output Directory: `dist`
   - Install Command: `npm install`

### Paso 4: Cargar Variables de Entorno (Environment Variables)
Despliega la sección **Environment Variables** e ingresa las siguientes llaves:

1. `VITE_SUPABASE_URL` = `https://kgrfhfwtcanthrymmvkb.supabase.co`
2. `VITE_SUPABASE_ANON_KEY` = `<TU_SUPABASE_ANON_KEY_DE_PRODUCCION>`
3. `VITE_N8N_WEBHOOK_URL` = `<TU_URL_DE_WEBHOOK_N8N_O_NGROK>`
4. `VITE_N8N_WEBHOOK_SECRET` = `<TU_SECRET_DE_N8N>`

### Paso 5: Desplegar
1. Haz clic en el botón **"Deploy"**.
2. Vercel clonará el repositorio, ejecutará `npm install`, compilará con `npm run build` e instalará los assets en su CDN global.
3. En menos de 1 minuto obtendrás la URL pública oficial (ej. `https://orbit-crm.vercel.app`).

---

## 6. Lista de Verificación Post-Despliegue (QA Smoke Test)

Una vez completado el despliegue, verifica los siguientes puntos en la URL de producción:

- [ ] **Auth Check:** Ingresa a `/login` e inicia sesión con un usuario de prueba de producción.
- [ ] **SPA Router Check:** Navega a `/leads`, luego presiona `F5` (Refresh) en el navegador. Verifica que la página cargue directamente sin dar error 404.
- [ ] **RLS Check:** Verifica que un vendedor solo vea sus leads y que las vistas respeten los permisos.
- [ ] **HTTPS Certificate:** Confirma que el dominio entregado por Vercel posea un certificado SSL/TLS válido.
