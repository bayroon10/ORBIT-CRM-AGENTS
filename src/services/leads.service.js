import { supabase } from '../lib/supabase'

export const LeadsService = {
  /**
   * Obtiene la lista de leads con la información de la empresa.
   */
  async getLeads() {
    return supabase
      .from('leads')
      .select('id, full_name, email, phone, status, created_at, ai_score, ai_category, companies!company_id(name)')
      .order('created_at', { ascending: false })
  },

  /**
   * Crea un nuevo lead asignando automáticamente el owner_id del usuario actual.
   */
  async createLead(leadData) {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      throw new Error('Sesión no válida.')
    }
    
    // Inyectar el owner_id al payload
    const payload = {
      ...leadData,
      owner_id: user.id
    }

    return supabase
      .from('leads')
      .insert(payload)
  },

  /**
   * Obtiene los detalles completos de un lead por su ID.
   */
  async getLeadById(id) {
    return supabase
      .from('leads')
      .select('id, full_name, email, phone, status, source, created_at, company_id, ai_score, ai_category, ai_summary, ai_next_step, ai_analyzed_at, companies!company_id(name)')
      .eq('id', id)
      .single()
  },

  /**
   * Obtiene la actividad reciente (actividades) asociada a un lead.
   */
  async getLeadActivities(leadId) {
    return supabase
      .from('activities')
      .select('id, type, description, created_at')
      .eq('lead_id', leadId)
      .order('created_at', { ascending: false })
      .limit(20)
  },

  /**
   * Recarga únicamente los campos AI de un lead (ai_score, ai_category,
   * ai_summary, ai_next_step, ai_analyzed_at) sin traer el resto del perfil.
   * Usado por LeadDetail.vue tras una calificación exitosa con IA.
   */
  async getLeadAiFields(id) {
    return supabase
      .from('leads')
      .select('ai_score, ai_category, ai_summary, ai_next_step, ai_analyzed_at')
      .eq('id', id)
      .single()
  },

  /**
   * Obtiene los negocios (deals) asociados a un lead.
   */
  async getLeadDeals(leadId) {
    return supabase
      .from('deals')
      .select('id, title, value, stage, expected_close')
      .eq('lead_id', leadId)
      .order('created_at', { ascending: false })
  }
}
