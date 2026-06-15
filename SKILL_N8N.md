# Skill: Integración de n8n con Orbit CRM y Supabase

Este documento recopila las directrices, mejores prácticas y lecciones aprendidas al integrar n8n como motor de automatización con Orbit CRM (Vue 3) y Supabase.

## LECCIONES APRENDIDAS EN PRODUCCIÓN

### LESSON 1 — Gemini 2.5 Flash necesita más tokens
`gemini-2.5-flash` es un modelo "pensante" (thinking model) que emite una sección de pensamientos (`Thoughts`) antes de la respuesta o output real. Debido a esto, los tokens consumidos son considerablemente mayores.
- **Siempre usar `maxOutputTokens: 2000` como mínimo** en el cuerpo de la llamada a la API de Gemini.
- **NUNCA usar 300 tokens** con este modelo, ya que el límite provocará un corte prematuro (`MAX_TOKENS` finish reason) durante la fase de razonamiento.
- **Modelo correcto:** `gemini-2.5-flash` (NO usar `gemini-1.5-flash`, ya que retorna error HTTP 404/no encontrado).

### LESSON 2 — n8n typeVersion en nodo Set
El nodo "Set" en n8n cambia su estructura de payload según su versión (`typeVersion`).
- **`typeVersion: 1`**: Requiere el formato heredado con la clave `values`:
  ```json
  "values": {
    "string": [
      { "name": "campo", "value": "valor" }
    ]
  }
  ```
- **`typeVersion: 3+`**: Utiliza el formato de asignaciones (`assignments`).
- **Importante:** SIEMPRE verificar la versión (`typeVersion`) del nodo Set en el JSON del workflow antes de escribir o manipular programáticamente sus propiedades.

### LESSON 3 — Prefijo = en expresiones n8n
En versiones modernas de n8n, cualquier parámetro de nodo que deba evaluarse como una expresión dinámica de Javascript **DEBE tener el prefijo `=`** al inicio de su valor de texto. De lo contrario, se procesará como un string literal.
- **MALO:** `"url": "https://...?id=eq.{{ $json.id }}"`
- **BUENO:** `"url": "=https://...?id=eq.{{ $json.id }}"`

### LESSON 4 — RLS bloquea PATCH desde anon key
La clave anónima (`anon key`) de Supabase está restringida por políticas RLS (Row Level Security) y generalmente solo sirve para SELECTs públicos. Cualquier intento de hacer operaciones de mutación (`INSERT`, `UPDATE` / `PATCH`, `DELETE`) fallará silenciosamente o retornará error 401/403.
- **SIEMPRE usar la clave `service_role` (Service Role Key)** en los nodos de n8n que interactúan con Supabase para omitir las políticas RLS de forma segura.
- **Headers requeridos para bypass de RLS:**
  ```http
  apikey: SERVICE_ROLE_KEY
  Authorization: Bearer SERVICE_ROLE_KEY
  ```

### LESSON 5 — pg_net para triggers en Supabase
Para disparar webhooks hacia n8n de forma confiable desde la base de datos de Supabase (especialmente en entornos de desarrollo local donde el Supabase Dashboard puede fallar al resolver `localhost` o túneles ngrok cambiantes), se debe utilizar la extensión `pg_net`.
- **Patrón de base de datos recomendado:**
  ```sql
  CREATE EXTENSION IF NOT EXISTS pg_net;
  
  CREATE OR REPLACE FUNCTION public.invoke_n8n_webhook()
  RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
  BEGIN
    PERFORM net.http_post(
      url := 'URL_NGROK/webhook/PATH',
      body := jsonb_build_object('record', row_to_json(NEW)),
      headers := '{"Content-Type": "application/json"}'::jsonb
    );
    RETURN NEW;
  END;
  $$;
  
  CREATE OR REPLACE TRIGGER nombre_trigger
  AFTER INSERT ON public.tabla
  FOR EACH ROW EXECUTE FUNCTION public.invoke_n8n_webhook();
  ```

### LESSON 6 — Workflow ID para updates programáticos
Para realizar actualizaciones del workflow local en n8n mediante scripts sin tener que abrir e importar manualmente desde el navegador, se debe consultar el ID asignado por la API de n8n utilizando el API Key:
```javascript
// update_n8n.cjs — patrón probado
const fs = require('fs');

async function updateWorkflow() {
  const API_KEY = 'TU_N8N_API_KEY';
  const baseUrl = 'http://localhost:5678/api/v1';
  
  // Obtener la lista para ubicar el ID del primer workflow
  const wfs = await fetch(`${baseUrl}/workflows`, {
    headers: { 'X-N8N-API-KEY': API_KEY }
  }).then(r => r.json());
  
  const id = wfs.data[0].id;
  const wf = JSON.parse(fs.readFileSync('workflow.json', 'utf8'));
  
  // Actualizar el workflow en n8n
  await fetch(`${baseUrl}/workflows/${id}`, {
    method: 'PUT',
    headers: { 
      'X-N8N-API-KEY': API_KEY, 
      'Content-Type': 'application/json' 
    },
    body: JSON.stringify(wf)
  });
}
```

### LESSON 7 — Dockerización y Reproducibilidad
Para garantizar un entorno reproducible, consistente y profesional, n8n debe ejecutarse mediante Docker Compose.
- **Fijar Versiones:** En `docker-compose.yml`, siempre usar una versión pineada (ej. `n8nio/n8n:1.45.1`) en lugar de `latest`. Esto previene fallos sorpresivos en el futuro por *breaking changes* en la API o en la estructura de nodos.
- **Variables de Entorno Base:** Se documentan en `.env.n8n.example`. Imprescindibles: `GENERIC_TIMEZONE` (para precisión de nodos *Schedule* o *Cron*) y `WEBHOOK_URL` (crucial para notificar a n8n el túnel ngrok actual).
- **Persistencia y Secretos:** El volumen local `.n8n-data/` persiste los flujos y la base de datos SQLite. Los secretos reales NUNCA van en el `.env`; se ingresan vía la interfaz web de n8n para que se guarden encriptados en ese volumen (el cual debe estar en `.gitignore`).
- **Recuperación de Flujos:** Al levantar un nuevo contenedor, se importa manualmente el archivo `workflow.json` y se reasignan las credenciales.
