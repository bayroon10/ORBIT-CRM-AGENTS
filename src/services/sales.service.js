import { supabase } from '../lib/supabase'

export const SalesService = {
  async getWonDeals() {
    return await supabase
      .from('deals')
      .select('*, leads(full_name), profiles(full_name)')
      .eq('stage', 'ganado')
      .order('updated_at', { ascending: false })
  },

  async getTotalDealsCount() {
    return await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
  }
}
