import { supabase } from '../lib/supabase'
import { AuthService } from './auth.service'

export const QuotesService = {
  async getQuotes() {
    return await supabase
      .from('quotes')
      .select('id, quote_number, deal_id, amount, status, valid_until, created_at, deals(title)')
      .order('created_at', { ascending: false })
  },

  async getQuoteById(id) {
    return await supabase
      .from('quotes')
      .select('*, deals(title)')
      .eq('id', id)
      .single()
  },

  async getDealsOptions() {
    return await supabase
      .from('deals')
      .select('id, title')
      .order('title', { ascending: true })
  },

  async createQuote(payload) {
    return await supabase.from('quotes').insert([payload])
  },

  async updateQuote(id, payload) {
    return await supabase.from('quotes').update(payload).eq('id', id)
  },

  async deleteQuote(id) {
    return await supabase.from('quotes').delete().eq('id', id)
  },

  async getUserRole() {
    // Fuente única: profiles.role (T-SEC-03)
    return AuthService.getUserRole()
  }
}
