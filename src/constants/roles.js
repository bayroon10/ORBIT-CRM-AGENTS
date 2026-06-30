// Catálogo canónico de roles — T-SEC-03 (fuente única de verdad).
// Alineado con profiles.role check en BD e is_admin_or_higher() en RLS.
export const ROLES = {
  ADMIN:      'admin',
  SUPERADMIN: 'superadmin',
  OWNER:      'owner',
  SELLER:     'seller',
  SUPPORT:    'support'
}

/**
 * Devuelve true para roles con privilegios de administración.
 * Alineado con is_admin_or_higher() de la BD:
 *   role IN ('admin', 'superadmin', 'owner')
 *
 * @param {string} role
 * @returns {boolean}
 */
export const isAdmin = (role) => {
  return role === ROLES.ADMIN
      || role === ROLES.SUPERADMIN
      || role === ROLES.OWNER
}
