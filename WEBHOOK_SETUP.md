# 🚀 Arquitectura de Automatización: Lead Qualifier Webhook

Este documento expone la topología de la integración y el flujo de datos para el ecosistema de automatización basado en n8n v1.72.0, ngrok y Supabase. Esta pieza de ingeniería establece un pipeline reactivo y en tiempo real para la calificación inteligente de prospectos comerciales mediante Inteligencia Artificial.

## 1. Arquitectura del Sistema

El pipeline de procesamiento opera mediante una arquitectura orientada a eventos impulsada por Webhooks nativos de base de datos. El ciclo de vida de la información sigue este flujo inmutable:

1. **Supabase Insert**: La creación de un nuevo registro en la tabla `leads` gatilla instantáneamente el webhook de base de datos.
2. **ngrok Tunnel**: El payload viaja de forma segura hacia el túnel estático de ngrok, el cual enlaza el entorno público con el stack local de Docker de manera persistente.
3. **n8n Lead Qualifier Agent**: El nodo de entrada (Webhook Node) del contenedor de n8n intercepta el flujo e inicializa la secuencia de automatización.
4. **Gemini AI**: Un nodo de inteligencia artificial orquesta una consulta a Google Gemini, suministrándole el contexto del prospecto para analizar su intención y calcular un *AI Score* estandarizado.
5. **Supabase PATCH**: Finalmente, n8n emite una petición HTTP PATCH de vuelta hacia la API REST de Supabase, actualizando el registro original con la puntuación y comentarios enriquecidos generados por la IA.

---

## 2. Ficha Técnica de Red

A continuación se detallan los parámetros operativos y de seguridad del entorno productivo:

- **Dominio Estático ngrok**: `alfalfa-excusably-zestfully.ngrok-free.dev`
- **Endpoint de Producción n8n**: `https://alfalfa-excusably-zestfully.ngrok-free.dev/webhook/lead-qualifier`
- **Protocolo de Seguridad**: Basado en modelo **Zero Trust**. Las claves de ngrok, los secretos webhooks y las credenciales críticas están estrictamente aisladas mediante variables de entorno en el archivo `.env` consolidado. No existe exposición de credenciales en texto plano dentro de la topología del orquestador.

---

## 3. Pasos de Réplica (Configuración en Supabase)

Para restaurar o replicar este disparador de datos directamente desde la interfaz de Supabase, ejecute el siguiente procedimiento estándar:

1. **Acceso**: Ingrese al panel administrativo del proyecto en Supabase y navegue hacia la sección **Database** > **Webhooks**.
2. **Creación**: Presione **Create a new Webhook** y defina los parámetros base:
   - **Name**: (ej. `Trigger AI Lead Qualifier`).
   - **Table**: Seleccione la tabla `leads`.
   - **Events**: Marque exclusivamente la casilla **Insert**.
3. **Configuración del Destino (HTTP Request)**:
   - **Method**: Defina el verbo `POST`.
   - **URL**: Ingrese la ruta de producción exacta (`https://alfalfa-excusably-zestfully.ngrok-free.dev/webhook/lead-qualifier`).
4. **Cabeceras HTTP (Headers)**:
   - Asegúrese de incluir el header `Content-Type: application/json`.
   - Incluya los parámetros de autenticación extra (`Authorization: Bearer <WEBHOOK_SECRET>`) si su workflow de n8n los valida explícitamente en el primer nodo.
5. **Despliegue**: Presione **Save webhook** para activar la transmisión en tiempo real hacia n8n.
