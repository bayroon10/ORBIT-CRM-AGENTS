-- Migración 001: Función RPC get_masked_credential
-- Fecha: 2026-06-27
-- Autor: Hermes Agent (por Bairo)
-- Descripción: Crea la función RPC que el frontend usa para enmascarar credenciales.

-- Crear la función RPC que el frontend espera
CREATE OR REPLACE FUNCTION public.get_masked_credential(setting_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_credential_value text;
BEGIN
  -- Obtener el valor real de forma segura
  SELECT credential_value INTO v_credential_value
  FROM public.provider_settings
  WHERE id = setting_id;

  -- Aplicar la lógica de enmascaramiento
  IF v_credential_value IS NULL THEN
    RETURN '— No disponible —';
  ELSIF length(v_credential_value) <= 4 THEN
    RETURN '****';
  ELSE
    RETURN '••••••••••••' || right(v_credential_value, 4);
  END IF;
END;
$$;

-- Otorgar permiso de ejecución al rol authenticated
GRANT EXECUTE ON FUNCTION public.get_masked_credential(uuid) TO authenticated;