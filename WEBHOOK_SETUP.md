# Configuración del Webhook de Supabase

Sigue estos pasos para activar el **Lead Qualifier Agent** configurando un Webhook en Supabase que se dispare cada vez que se cree un nuevo lead.

## Pasos

1. Ve a tu [Supabase Dashboard](https://supabase.com/dashboard/project/kgrfhfwtcanthrymmvkb/database/hooks) en la sección Database > Webhooks.
2. Haz clic en **Create a new hook** (Crear nuevo hook).
3. Configúralo exactamente con los siguientes parámetros:
   - **Hook name:** `lead_qualifier_trigger`
   - **Table:** `public.leads`
   - **Events:** `INSERT` ✅ (Asegúrate de marcar solo Insert)
   - **Type:** `HTTP Request`
   - **Method:** `POST`
   - **URL:** `http://localhost:5678/webhook/lead-qualifier`
     > [!NOTE]
     > Para producción, necesitarás usar Ngrok o la URL donde hayas desplegado tu instancia de n8n.
4. Haz clic en **Save** o **Confirm** para guardar el webhook.

## ¿Qué sucede después?

Una vez activado, cada vez que registres un nuevo lead en Orbit CRM, Supabase enviará una solicitud al webhook de n8n. n8n recogerá los datos del lead, los enviará a Gemini 2.0 Flash para su análisis, y luego actualizará automáticamente el lead en Supabase con la calificación (`ai_score`), categoría (`ai_category`), resumen ejecutivo y el próximo paso sugerido.

![Screenshot de Webhooks](https://placehold.co/800x400/0f172a/ffffff?text=Supabase+Webhooks+Dashboard)
