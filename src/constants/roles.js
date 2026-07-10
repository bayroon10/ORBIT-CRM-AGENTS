// Centralizamos los roles para evitar errores de escritura ("admin" vs "Admin")
export const ROLES = {
  ADMIN: 'admin',
  SELLER: 'seller'
};

export const isAdmin = (role) => {
  return role === ROLES.ADMIN;
};
