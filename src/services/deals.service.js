import { supabase } from '../lib/supabase'

export const DealsService = {
  /**
   * Obtiene todos los negocios para el pipeline.
   * Utiliza el delimitador explícito !company_id para evitar PGRST201.
   */
  async getDeals() {
    return supabase
      .from('deals')
      .select(`
        id,
        title,
        value,
        stage,
        probability,
        expected_close,
        stalled,
        ai_risk_score,
        ai_risk_factors,
        ai_analyzed_at,
        created_at,
        lead_id,
        company_id,
        leads(full_name),
        companies!company_id(name)
      `)
      .order('updated_at', { ascending: false })
  },

  /**
   * Crea un nuevo negocio.
   */
  async createDeal(dealData) {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      throw new Error('Sesión no válida.')
    }

    const payload = {
      ...dealData,
      owner_id: user.id
    }

    return supabase
      .from('deals')
      .insert(payload)
  },

  /**
   * Obtiene el detalle de un negocio específico por ID.
   * Utiliza el delimitador explícito !company_id para evitar PGRST201.
   */
  async getDealById(id) {
    return supabase
      .from('deals')
      .select('id, title, value, stage, probability, expected_close, stalled, ai_risk_score, ai_risk_factors, ai_analyzed_at, created_at, updated_at, lead_id, company_id, leads(full_name), companies!company_id(name)')
      .eq('id', id)
      .single()
  },

  /**
   * Obtiene las actividades recientes de un negocio.
   */
  async getDealActivities(dealId) {
    return supabase
      .from('activities')
      .select('id, type, description, created_at')
      .eq('deal_id', dealId)
      .order('created_at', { ascending: false })
      .limit(20)
  },

  /**
   * Obtiene las tareas asociadas a un negocio.
   */
  async getDealTasks(dealId) {
    return supabase
      .from('tasks')
      .select('id, title, status, due_date')
      .eq('deal_id', dealId)
      .order('due_date', { ascending: true })
  }
}
