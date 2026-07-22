import { supabase } from '../lib/supabase'
import { AuthService } from './auth.service'

export const DashboardService = {
  /**
   * Obtiene el rol del usuario autenticado.
   * Fuente única: profiles.role (T-SEC-03).
   */
  async getUserRole() {
    return AuthService.getUserRole()
  },

  /**
   * Obtiene todas las métricas del dashboard de forma concurrente para maximizar el rendimiento.
   */
  async getDashboardMetrics() {
    const [
      leadsResponse,
      activeDealsResponse,
      sentQuotesResponse,
      closedSalesResponse,
      aiLeadsResponse,
      activitiesResponse
    ] = await Promise.all([
      supabase.from('leads').select('*', { count: 'exact', head: true }).eq('status', 'nuevo'),
      supabase.from('deals').select('*', { count: 'exact', head: true }).in('stage', ['prospecto', 'cotizado', 'negociando']),
      supabase.from('quotes').select('*', { count: 'exact', head: true }).eq('status', 'sent'),
      supabase.from('deals').select('value').eq('stage', 'ganado'),
      supabase.from('leads').select('id, full_name, ai_score, ai_category'),
      supabase.from('activities')
        .select('id, type, description, created_at, leads(full_name)')
        .order('created_at', { ascending: false })
        .limit(5)
    ])

    // Verificación de errores en paralelo
    if (leadsResponse.error) throw leadsResponse.error
    if (activeDealsResponse.error) throw activeDealsResponse.error
    if (sentQuotesResponse.error) throw sentQuotesResponse.error
    if (closedSalesResponse.error) throw closedSalesResponse.error
    if (aiLeadsResponse.error) throw aiLeadsResponse.error
    if (activitiesResponse.error) throw activitiesResponse.error

    const totalVentas = closedSalesResponse.data?.reduce((sum, item) => sum + Number(item.value || 0), 0) || 0

    let agentStats = {
      total: 0, analyzed: 0, pending: 0, avgScore: 0, hot: 0, warm: 0, cold: 0
    }
    let topAiLeads = []

    if (aiLeadsResponse.data) {
      const analyzedLeads = aiLeadsResponse.data.filter(l => l.ai_score !== null)
      const pendingLeads = aiLeadsResponse.data.filter(l => l.ai_score === null)
      const totalScore = analyzedLeads.reduce((sum, l) => sum + l.ai_score, 0)
      const avgScore = analyzedLeads.length > 0 ? Math.round(totalScore / analyzedLeads.length) : 0

      agentStats = {
        total: aiLeadsResponse.data.length,
        analyzed: analyzedLeads.length,
        pending: pendingLeads.length,
        avgScore: avgScore,
        hot: analyzedLeads.filter(l => l.ai_category === 'Hot').length,
        warm: analyzedLeads.filter(l => l.ai_category === 'Warm').length,
        cold: analyzedLeads.filter(l => l.ai_category === 'Cold').length
      }

      topAiLeads = analyzedLeads
        .sort((a, b) => b.ai_score - a.ai_score)
        .slice(0, 3)
    }

    return {
      stats: {
        nuevosLeads: leadsResponse.count || 0,
        negociosActivos: activeDealsResponse.count || 0,
        cotizacionesEnviadas: sentQuotesResponse.count || 0,
        ventasCerradas: totalVentas
      },
      agentStats,
      topAiLeads,
      activities: activitiesResponse.data || []
    }
  }
}
