import { supabase } from '../lib/supabase'

export const TasksService = {
  async getTasks() {
    return await supabase
      .from('tasks')
      .select(`
        id,
        title,
        due_date,
        status,
        created_at,
        lead_id,
        deal_id,
        priority,
        leads(full_name),
        deals(title)
      `)
      .order('due_date', { ascending: true, nullsFirst: false })
  },
  
  async getProfiles() {
    return await supabase
      .from('profiles')
      .select('id, full_name')
      .order('full_name', { ascending: true })
  },
  
  async getLeadOptions() {
    return await supabase
      .from('leads')
      .select('id, name:full_name')
      .order('full_name', { ascending: true })
  },

  async getDealOptions() {
    return await supabase
      .from('deals')
      .select('id, name:title')
      .order('title', { ascending: true })
  },

  async createTask(payload) {
    return await supabase.from('tasks').insert([payload])
  },

  async updateTask(id, payload) {
    return await supabase.from('tasks').update(payload).eq('id', id)
  },

  async updateTaskStatus(id, newStatus) {
    return await supabase.from('tasks').update({ status: newStatus }).eq('id', id)
  },

  async deleteTask(id) {
    return await supabase.from('tasks').delete().eq('id', id)
  }
}
