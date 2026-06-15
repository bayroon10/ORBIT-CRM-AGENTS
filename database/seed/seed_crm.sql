-- ==============================================================================
-- PROYECTO: CRM + Operación + Automatización
-- DESCRIPCIÓN: Datos iniciales (Seed) de prueba para las tablas operativas del CRM
-- ==============================================================================

-- 1. Insertar Empresas de Prueba (Companies)
INSERT INTO public.companies (id, name, industry, website) VALUES
('40000000-0000-0000-0000-000000000001', 'Codelco División Andina', 'Minería', 'https://www.codelco.com'),
('40000000-0000-0000-0000-000000000002', 'Constructora Echeverría Izquierdo', 'Construcción', 'https://www.echeverria-izquierdo.cl'),
('40000000-0000-0000-0000-000000000003', 'Soprole S.A.', 'Alimentos', 'https://www.soprole.cl'),
('40000000-0000-0000-0000-000000000004', 'Forestal Arauco', 'Forestal', 'https://www.arauco.cl')
ON CONFLICT (id) DO NOTHING;

-- Nota: Los perfiles (profiles) se alimentan automáticamente desde auth.users.
-- Sin embargo, insertaremos perfiles semilla ficticios (para desarrollo local/pruebas sin login previo)
-- en caso de que no existan restricciones estrictas con auth.users, o para referencia.
-- Como id referencia a auth.users, si no hay usuarios en auth.users, se omitirán estos perfiles, 
-- pero los definiremos como fallback.
-- Para pruebas rápidas, asumiremos que los leads pueden crearse sin owner inicialmente, u owner_id = null.

-- 2. Insertar Leads (Prospectos)
INSERT INTO public.leads (id, name, email, phone, source, status, company_id) VALUES
('50000000-0000-0000-0000-000000000001', 'Juan Pérez', 'jperez@codelco.cl', '+56 9 1234 5678', 'web', 'nuevo', '40000000-0000-0000-0000-000000000001'),
('50000000-0000-0000-0000-000000000002', 'María González', 'mgonzalez@echeverria.cl', '+56 9 8765 4321', 'webhook', 'nuevo', '40000000-0000-0000-0000-000000000002'),
('50000000-0000-0000-0000-000000000003', 'Andrés Latorre', 'alatorre@soprole.cl', '+56 9 4567 8901', 'manual', 'calificado', '40000000-0000-0000-0000-000000000003'),
('50000000-0000-0000-0000-000000000004', 'Camila Soto', 'csoto@arauco.cl', '+56 9 9876 5432', 'web', 'contactado', '40000000-0000-0000-0000-000000000004')
ON CONFLICT (id) DO NOTHING;

-- 3. Insertar Oportunidades de Venta (Deals)
INSERT INTO public.deals (id, name, amount, status, lead_id) VALUES
('60000000-0000-0000-0000-000000000001', 'Suministro Repuestos Filtros', 8500.00, 'prospecto', '50000000-0000-0000-0000-000000000001'),
('60000000-0000-0000-0000-000000000002', 'Instalación Maquinaria Movimiento Tierra', 145000.00, 'negociando', '50000000-0000-0000-0000-000000000002'),
('60000000-0000-0000-0000-000000000003', 'Renovación Cintas Transportadoras Soprole', 24000.00, 'cotizado', '50000000-0000-0000-0000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- 4. Insertar Tareas (Tasks)
INSERT INTO public.tasks (id, title, description, due_date, status, lead_id) VALUES
('70000000-0000-0000-0000-000000000001', 'Llamar para verificar requerimientos', 'Llamar a Juan para validar las medidas de los filtros requeridos.', CURRENT_DATE + INTERVAL '2 days', 'pendiente', '50000000-0000-0000-0000-000000000001'),
('70000000-0000-0000-0000-000000000002', 'Enviar cotización formal', 'Preparar presupuesto final de instalación y enviar por correo.', CURRENT_DATE + INTERVAL '1 day', 'pendiente', '50000000-0000-0000-0000-000000000002'),
('70000000-0000-0000-0000-000000000003', 'Agendar reunión de cierre', 'Reunirse con Andrés para discutir descuentos adicionales.', CURRENT_DATE + INTERVAL '5 days', 'pendiente', '50000000-0000-0000-0000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- 5. Insertar Historial de Actividades (Activities)
INSERT INTO public.activities (id, type, description, lead_id, task_id) VALUES
('80000000-0000-0000-0000-000000000001', 'webhook_recibido', 'Prospecto ingresado automáticamente desde formulario web.', '50000000-0000-0000-0000-000000000001', null),
('80000000-0000-0000-0000-000000000002', 'webhook_recibido', 'Prospecto ingresado automáticamente vía n8n webhook.', '50000000-0000-0000-0000-000000000002', null),
('80000000-0000-0000-0000-000000000003', 'correo_enviado', 'Enviada información comercial e invitaciones a catálogo.', '50000000-0000-0000-0000-000000000003', null),
('80000000-0000-0000-0000-000000000004', 'tarea_creada', 'Creada tarea de llamada de seguimiento técnico.', '50000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001')
ON CONFLICT (id) DO NOTHING;
