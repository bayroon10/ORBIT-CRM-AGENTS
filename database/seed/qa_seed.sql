-- ==============================================================================
-- PROYECTO: Orbit CRM
-- DESCRIPCIÓN: Datos semilla (Seed) de QA para pruebas de RLS, Autenticación y Dashboard
-- ARCHIVO: database/seed/qa_seed.sql
-- ==============================================================================

-- 1. Habilitar extensión pgcrypto para cifrado bcrypt nativo
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Limpieza de usuarios de prueba previos (la eliminación en cascada borrará perfiles y dependencias)
DELETE FROM auth.users WHERE email IN (
  'superadmin@orbitcrm.test',
  'admin@orbitcrm.test',
  'seller1@orbitcrm.test',
  'seller2@orbitcrm.test'
);

-- 3. Insertar Usuarios de Prueba en auth.users de Supabase
-- Nota: La contraseña para todos es 'QA_pass_2026!' cifrada con bcrypt nativo
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  aud,
  role,
  created_at,
  updated_at
) VALUES
-- superadmin
(
  '10000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'superadmin@orbitcrm.test',
  crypt('QA_pass_2026!', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "Super Administrador", "role": "admin"}',
  'authenticated',
  'authenticated',
  now(),
  now()
),
-- admin
(
  '10000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000000',
  'admin@orbitcrm.test',
  crypt('QA_pass_2026!', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "Administrador General", "role": "admin"}',
  'authenticated',
  'authenticated',
  now(),
  now()
),
-- seller1
(
  '10000000-0000-0000-0000-000000000003',
  '00000000-0000-0000-0000-000000000000',
  'seller1@orbitcrm.test',
  crypt('QA_pass_2026!', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "Vendedor Estrella 1", "role": "seller"}',
  'authenticated',
  'authenticated',
  now(),
  now()
),
-- seller2
(
  '10000000-0000-0000-0000-000000000004',
  '00000000-0000-0000-0000-000000000000',
  'seller2@orbitcrm.test',
  crypt('QA_pass_2026!', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "Vendedor Estrella 2", "role": "seller"}',
  'authenticated',
  'authenticated',
  now(),
  now()
);

-- 4. Forzar/Asegurar inserción en public.profiles
-- En sistemas normales el trigger 'on_auth_user_created' maneja esto, pero se inyecta de forma defensiva
INSERT INTO public.profiles (id, full_name, role) VALUES
('10000000-0000-0000-0000-000000000001', 'Super Administrador', 'admin'),
('10000000-0000-0000-0000-000000000002', 'Administrador General', 'admin'),
('10000000-0000-0000-0000-000000000003', 'Vendedor Estrella 1', 'seller'),
('10000000-0000-0000-0000-000000000004', 'Vendedor Estrella 2', 'seller')
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role;


-- 5. Limpiar datos transaccionales asociados a las llaves de prueba
DELETE FROM public.activities WHERE id::text LIKE '9400%';
DELETE FROM public.tasks WHERE id::text LIKE '9300%';
DELETE FROM public.deals WHERE id::text LIKE '9200%';
DELETE FROM public.leads WHERE id::text LIKE '9100%';
DELETE FROM public.companies WHERE id::text LIKE '9000%';

-- 6. Insertar Empresas de Prueba (Companies)
INSERT INTO public.companies (id, name, industry, website) VALUES
('90000000-0000-0000-0000-000000000001', 'QA Tech Solutions', 'Tecnología', 'https://qa-tech.test'),
('90000000-0000-0000-0000-000000000002', 'QA Build & Construct', 'Construcción', 'https://qa-build.test'),
('90000000-0000-0000-0000-000000000003', 'QA Food & Dairy', 'Alimentos', 'https://qa-food.test');

-- 7. Insertar Leads (Prospectos)
-- Leads para seller1:
INSERT INTO public.leads (id, name, email, phone, source, status, owner_id, company_id) VALUES
('91000000-0000-0000-0000-000000000001', 'Juan Pérez (S1)', 'jperez@qa-tech.test', '+56 9 1111 2222', 'web', 'nuevo', '10000000-0000-0000-0000-000000000003', '90000000-0000-0000-0000-000000000001'),
('91000000-0000-0000-0000-000000000002', 'Ana María Latorre (S1)', 'amlatorre@qa-tech.test', '+56 9 1111 3333', 'manual', 'calificado', '10000000-0000-0000-0000-000000000003', '90000000-0000-0000-0000-000000000001');

-- Leads para seller2:
INSERT INTO public.leads (id, name, email, phone, source, status, owner_id, company_id) VALUES
('91000000-0000-0000-0000-000000000003', 'Carlos Gómez (S2)', 'cgomez@qa-build.test', '+56 9 2222 4444', 'webhook', 'contactado', '10000000-0000-0000-0000-000000000004', '90000000-0000-0000-0000-000000000002'),
('91000000-0000-0000-0000-000000000004', 'Sofía Aravena (S2)', 'saravena@qa-build.test', '+56 9 2222 5555', 'web', 'nuevo', '10000000-0000-0000-0000-000000000004', '90000000-0000-0000-0000-000000000002');

-- Lead sin asignar (huérfano, visible solo para admins/superadmins):
INSERT INTO public.leads (id, name, email, phone, source, status, owner_id, company_id) VALUES
('91000000-0000-0000-0000-000000000005', 'Prospecto Entrante', 'info@qa-food.test', '+56 9 3333 6666', 'web', 'nuevo', null, '90000000-0000-0000-0000-000000000003');


-- 8. Insertar Oportunidades (Deals)
-- Oportunidades para seller1:
INSERT INTO public.deals (id, name, amount, status, lead_id, owner_id) VALUES
('92000000-0000-0000-0000-000000000001', 'Compra Servidores Cloud', 15000.00, 'prospecto', '91000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003'),
('92000000-0000-0000-0000-000000000002', 'Licencias Orbit Pro', 5000.00, 'cotizado', '91000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003'),
('92000000-0000-0000-0000-000000000003', 'Consultoría Especializada (Ganada)', 25000.00, 'ganado', '91000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003');

-- Oportunidades para seller2:
INSERT INTO public.deals (id, name, amount, status, lead_id, owner_id) VALUES
('92000000-0000-0000-0000-000000000004', 'Instalación Estructura Metálica', 350000.00, 'negociando', '91000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000004'),
('92000000-0000-0000-0000-000000000005', 'Reparación Andamios (Perdida)', 12000.00, 'perdido', '91000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004');


-- 9. Insertar Tareas (Tasks)
INSERT INTO public.tasks (id, title, description, due_date, status, lead_id, assigned_to) VALUES
('93000000-0000-0000-0000-000000000001', 'Llamar a Juan Pérez', 'Validar requerimientos del rack de servidores.', current_date + 2, 'pendiente', '91000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003'),
('93000000-0000-0000-0000-000000000002', 'Enviar cotización formal', 'Preparar propuesta final con 20% descuento.', current_date + 1, 'pendiente', '91000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003'),
('93000000-0000-0000-0000-000000000003', 'Inspección en Terreno', 'Visita de seguridad con la constructora.', current_date + 3, 'pendiente', '91000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000004');


-- 10. Insertar Historial de Actividades (Activities)
INSERT INTO public.activities (id, type, description, lead_id, task_id, created_at) VALUES
('94000000-0000-0000-0000-000000000001', 'webhook_recibido', 'Prospecto Juan Pérez ingresado de formulario web.', '91000000-0000-0000-0000-000000000001', null, now() - interval '2 hours'),
('94000000-0000-0000-0000-000000000002', 'correo_enviado', 'Correo de seguimiento y presentación enviado a Ana María.', '91000000-0000-0000-0000-000000000002', null, now() - interval '1 hour'),
('94000000-0000-0000-0000-000000000003', 'llamada_realizada', 'Llamada comercial inicial para coordinar inspección con Carlos.', '91000000-0000-0000-0000-000000000003', null, now() - interval '30 minutes');
