import { ref } from 'vue'
import { supabase } from '../lib/supabase'

// Estado global para las alertas
const alerts = ref([])
let channel = null

export function useRealtimeAlerts() {
  const initRealtime = async () => {
    if (channel) return // Ya inicializado
    
    // Obtenemos el usuario y su tenant_id
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) return
    
    const { data: profile } = await supabase
      .from('profiles')
      .select('tenant_id')
      .eq('id', session.user.id)
      .single()
      
    if (!profile?.tenant_id) return

    channel = supabase.channel('realtime_leads')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'leads',
          filter: `tenant_id=eq.${profile.tenant_id}`
        },
        (payload) => {
          const lead = payload.new
          if (lead.ai_score >= 70) {
            addAlert({
              id: lead.id,
              name: lead.name,
              score: lead.ai_score,
              message: 'Nuevo prospecto de alta prioridad evaluado por IA'
            })
          }
        }
      )
      .subscribe((status) => {
        console.log('Realtime leads status:', status)
      })
  }

  const addAlert = (alert) => {
    alerts.value.push(alert)
    setTimeout(() => {
      removeAlert(alert.id)
    }, 5000)
  }

  const removeAlert = (id) => {
    alerts.value = alerts.value.filter(a => a.id !== id)
  }

  const cleanupRealtime = () => {
    if (channel) {
      supabase.removeChannel(channel)
      channel = null
    }
  }

  return {
    alerts,
    initRealtime,
    cleanupRealtime,
    removeAlert
  }
}
