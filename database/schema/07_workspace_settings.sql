-- Migration: Workspace Settings
-- Crea la tabla para almacenar la configuración general del CRM.

-- 1. Tabla base
CREATE TABLE public.workspace_settings (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    system_name text NOT NULL DEFAULT 'Orbit CRM',
    timezone text NOT NULL DEFAULT 'America/Santiago',
    locale text NOT NULL DEFAULT 'es-CL',
    updated_at timestamp with time zone DEFAULT now()
);

-- 2. Insertar fila por defecto (Solo habrá 1 fila)
INSERT INTO public.workspace_settings (system_name, timezone, locale)
VALUES ('Orbit CRM', 'America/Santiago', 'es-CL');

-- 3. Habilitar RLS
ALTER TABLE public.workspace_settings ENABLE ROW LEVEL SECURITY;

-- 4. Políticas de RLS
-- Permitir lectura a cualquier usuario autenticado
CREATE POLICY "Anyone authenticated can view workspace settings"
  ON public.workspace_settings FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permitir actualización sólo a usuarios con rol 'admin' (usando la misma función que en otros lados o comprobación de profiles)
-- Suponiendo que auth.users u otras políticas verifican si es admin, o si se puede buscar en profiles.
-- Se recomienda usar el ID o rol en jwt.
CREATE POLICY "Admins can update workspace settings"
  ON public.workspace_settings FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- No se permite INSERT o DELETE
CREATE POLICY "Admins cannot insert settings"
  ON public.workspace_settings FOR INSERT
  WITH CHECK (false);

CREATE POLICY "Admins cannot delete settings"
  ON public.workspace_settings FOR DELETE
  USING (false);

-- Permisos de tabla
GRANT SELECT, UPDATE ON public.workspace_settings TO authenticated;
