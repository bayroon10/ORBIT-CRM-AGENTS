-- Migration: Provider Settings
-- Crea la tabla para almacenar tokens y credenciales de APIs de terceros (Gemini, OpenAI, n8n, etc.)
-- Implementa el fallback de seguridad: revoca acceso a la key real y crea una funcion para devolver el valor enmascarado.

-- 1. Tabla base
CREATE TABLE public.provider_settings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  provider text NOT NULL,
  label text,
  credential_type text,
  credential_value text NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  last_used_at timestamp with time zone
);

-- Index para acelerar consultas por usuario
CREATE INDEX idx_provider_settings_user_id ON public.provider_settings(user_id);

-- 2. Seguridad de Columna: Revocar lectura del credential_value al frontend (authenticated)
-- Primero nos aseguramos que authenticated pueda leer el resto de la tabla
GRANT SELECT, INSERT, UPDATE, DELETE ON public.provider_settings TO authenticated;
-- Luego revocamos select específicamente sobre credential_value
REVOKE SELECT (credential_value) ON public.provider_settings FROM authenticated;

-- 3. Función Computada para devolver la clave enmascarada
-- Se usará SECURITY DEFINER para poder leer el valor real interno (ya que se revocó el permiso al rol que llama).
-- Además, se usa SET search_path = public, pg_temp por seguridad.
CREATE OR REPLACE FUNCTION public.masked_credential(settings public.provider_settings)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF length(settings.credential_value) <= 4 THEN
    RETURN '****';
  ELSE
    RETURN '••••••••••••' || right(settings.credential_value, 4);
  END IF;
END;
$$;

-- Otorgar permiso de ejecución al rol authenticated
GRANT EXECUTE ON FUNCTION public.masked_credential(public.provider_settings) TO authenticated;

-- 4. Habilitar RLS
ALTER TABLE public.provider_settings ENABLE ROW LEVEL SECURITY;

-- 5. Políticas de RLS
CREATE POLICY "Users can insert their own provider settings"
  ON public.provider_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own provider settings"
  ON public.provider_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own provider settings"
  ON public.provider_settings FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own provider settings"
  ON public.provider_settings FOR DELETE
  USING (auth.uid() = user_id);
