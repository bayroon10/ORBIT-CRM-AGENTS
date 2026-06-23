import { supabase } from '../lib/supabase'

export const CompaniesService = {
  /**
   * Obtiene la lista de empresas.
   */
  async getCompanies() {
    return supabase
      .from('companies')
      .select('id, name, industry, website, created_at')
      .order('created_at', { ascending: false })
  },

  /**
   * Crea una nueva empresa asociada al usuario autenticado.
   */
  async createCompany(companyData) {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      throw new Error('Sesión no válida.')
    }

    const payload = {
      ...companyData,
      owner_id: user.id
    }

    return supabase
      .from('companies')
      .insert(payload)
  }
}
