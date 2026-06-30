import { supabase } from '../lib/supabase'

/**
 * AuthService — fuente única de verdad para el rol del usuario.
 *
 * T-SEC-03: todos los consumidores de rol deben usar este servicio.
 * La fuente autoritativa es profiles.role (alineada con RLS de la BD),
 * NO user_metadata.role (que puede estar desincronizado).
 *
 * Roles válidos (alineados con is_admin_or_higher() en producción):
 *   'admin', 'superadmin', 'owner', 'seller', 'support'
 */
export const AuthService = {
  /**
   * Obtiene el rol del usuario autenticado desde profiles.role.
   * Devuelve 'seller' como valor seguro por defecto.
   *
   * @param {string} [userId] - ID del usuario ya conocido (evita el round-trip a getUser)
   * @returns {Promise<string>} rol del usuario
   */
  async getUserRole(userId) {
    let uid = userId

    if (!uid) {
      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) return 'seller'
      uid = user.id
    }

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', uid)
      .single()

    if (profileError || !profile) return 'seller'
    return profile.role || 'seller'
  }
}
