import { supabase } from '../lib/supabase'

export const whatsappService = {
  // Obtener conversaciones agrupadas por lead/teléfono
  async getConversations(limit = 50) {
    const { data, error } = await supabase
      .from('whatsapp_conversations')
      .select(`
        id,
        phone,
        direction,
        message,
        ai_generated,
        read,
        created_at,
        lead_id,
        leads (
          id,
          full_name,
          email,
          ai_score,
          ai_category
        )
      `)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data
  },

  // Obtener conversación completa de un número
  async getConversationByPhone(phone) {
    const { data, error } = await supabase
      .from('whatsapp_conversations')
      .select(`
        id,
        phone,
        direction,
        message,
        ai_generated,
        read,
        created_at,
        lead_id,
        leads (
          id,
          full_name,
          email,
          ai_score,
          ai_category
        )
      `)
      .eq('phone', phone)
      .order('created_at', { ascending: true })

    if (error) throw error
    return data
  },

  // Marcar mensajes como leídos
  async markAsRead(phone) {
    const { error } = await supabase
      .from('whatsapp_conversations')
      .update({ read: true })
      .eq('phone', phone)
      .eq('direction', 'inbound')

    if (error) throw error
  },

  // Suscripción realtime a nuevas conversaciones
  subscribeToConversations(callback) {
    return supabase
      .channel('whatsapp_conversations_realtime')
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'whatsapp_conversations' },
        (payload) => callback(payload.new)
      )
      .subscribe()
  },

  // Obtener credential de WhatsApp en provider_settings
  async getWhatsAppCredential() {
    const { data, error } = await supabase
      .from('provider_settings')
      .select('*')
      .eq('provider', 'WhatsApp')
      .maybeSingle()

    if (error) throw error
    return data
  },

  async saveWhatsAppCredential(accessToken, phoneNumberId, verifyToken) {
    const existing = await this.getWhatsAppCredential()

    if (existing) {
      const { error } = await supabase
        .from('provider_settings')
        .update({
          credential_value: accessToken,
          is_active: true
        })
        .eq('provider', 'WhatsApp')

      if (error) throw error
    } else {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('Usuario no autenticado')

      const { error } = await supabase
        .from('provider_settings')
        .insert({
          user_id: user.id,
          provider: 'WhatsApp',
          label: `Phone ID: ${phoneNumberId} | Verify: ${verifyToken}`,
          credential_type: 'api_key',
          credential_value: accessToken,
          is_active: true
        })

      if (error) throw error
    }
  }
}
