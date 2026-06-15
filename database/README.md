# Estructura de Base de Datos y Workflows (Local)

> [!NOTE]
> **Base de Datos Viva:** La base de datos operativa y real de este proyecto se encuentra desplegada y gestionada en el entorno remoto de Supabase (proyecto `kgrfhfwtcanthrymmvkb`). 
> Todos los archivos contenidos en este directorio son estrictamente para fines de **respaldo y documentación técnica** del modelo original.

## Contenido del Directorio

Esta carpeta organiza los scripts SQL fundacionales y los flujos de automatización que sirven de respaldo para el entorno de Supabase y n8n:

*   **`schema/`**: Contiene la definición estructural (DDL) de las tablas y vistas.
    *   `schema_crm.sql`: Tablas operativas del CRM (Perfiles, Empresas, Leads, Negocios, Tareas, Actividades) en inglés.
    *   `schema_mvp.sql`: Vistas y tablas analíticas del modelo inicial en español.
*   **`seed/`**: Contiene los datos de muestra iniciales (DML).
    *   `seed_crm.sql`: Registros de prueba para la operación del CRM.
    *   `seed_mvp.sql`: Datos de prueba del modelo analítico.
*   **`policies/`**: Contiene las definiciones de seguridad.
    *   `rls_policies.sql`: Políticas de Row-Level Security para asegurar que los usuarios solo vean y modifiquen los registros que les pertenecen o han creado.
*   **`workflows/`**: Contiene respaldos de flujos de automatización externos.
    *   `n8n_lead_workflow.json`: Exportación del flujo JSON de n8n que automatiza la creación de tareas cuando ingresa un nuevo Lead.

---
*Este directorio no es requerido para que la aplicación Vue / Vite compile ni se ejecute.*
