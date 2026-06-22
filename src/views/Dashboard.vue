<template>
  <div class="min-h-full">
    <!-- ── Hero Header ── -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-primary/20 shadow-lg">
      <div class="absolute inset-0 opacity-10"
        style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;">
      </div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15"
        style="background: radial-gradient(circle, #6366f1, transparent 70%);">
      </div>
      <div class="relative z-10">
        <div class="flex items-center gap-2 mb-3">
          <BaseBadge variant="primary">Dashboard</BaseBadge>
        </div>
        <h1 class="text-3xl font-bold text-text-main mb-2 tracking-tight">Panel de Control</h1>
        <p class="text-text-secondary text-sm">Resumen ejecutivo del pipeline comercial en tiempo real.</p>
      </div>
    </div>

    <!-- ── Error State ── -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20">
      {{ error }}
    </div>

    <!-- ── Metrics Grid ── -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
      <OrbitMetricCard
        class="metric-card"
        title="Prospectos Nuevos"
        :value="loading ? '—' : stats.nuevosLeads"
        icon="users"
      />
      <OrbitMetricCard
        class="metric-card"
        title="Negocios Activos"
        :value="loading ? '—' : stats.negociosActivos"
        icon="briefcase"
      />
      <OrbitMetricCard
        class="metric-card"
        title="En Cotización"
        :value="loading ? '—' : stats.cotizacionesEnviadas"
        icon="document"
      />
      <OrbitMetricCard
        class="metric-card"
        title="Ventas Cerradas"
        :value="loading ? '—' : formatCurrency(stats.ventasCerradas)"
        icon="chart"
      />
    </div>

    <!-- ── Agent Overview Layer ── -->
    <BaseCard :padded="false" class="agent-overview-section mb-8 overflow-hidden">
      <!-- Línea de acento superior IA -->
      <div class="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-primary/50 via-primary to-success/60"></div>

      <!-- Header IA -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-6 pb-4">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-primary/15 border border-primary/20 text-primary-300 flex items-center justify-center shrink-0">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h2 class="text-base font-bold text-text-main tracking-tight">Sales Intelligence Agent</h2>
              <BaseBadge variant="success" :dot="true">Activo</BaseBadge>
            </div>
            <p class="text-xs text-text-secondary mt-0.5">Análisis automático de leads vía Gemini AI</p>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5 px-6 pb-6">
        <!-- Columna 1: KPIs Básicos -->
        <div class="flex flex-col gap-4">
          <div class="bg-surface rounded-xl border border-border p-4 flex items-center justify-between transition-shadow hover:shadow-md hover:border-border-strong">
            <div>
              <p class="text-2xs font-semibold text-text-muted uppercase tracking-wider mb-1">Analizados</p>
              <div class="flex items-baseline gap-2">
                <span class="text-2xl font-bold text-text-main">{{ loading ? '—' : agentStats.analyzed }}</span>
                <span class="text-xs text-text-secondary font-medium">/ {{ loading ? '—' : agentStats.total }} leads</span>
              </div>
            </div>
            <div class="w-9 h-9 rounded-full bg-success/10 border border-success/20 flex items-center justify-center text-success">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>

          <div class="bg-surface rounded-xl border border-border p-4 flex items-center justify-between transition-shadow hover:shadow-md hover:border-border-strong">
            <div>
              <p class="text-2xs font-semibold text-text-muted uppercase tracking-wider mb-1">Pendientes</p>
              <div class="flex items-baseline gap-2">
                <span class="text-2xl font-bold text-text-main">{{ loading ? '—' : agentStats.pending }}</span>
                <span class="text-xs text-text-secondary font-medium">en cola</span>
              </div>
            </div>
            <div class="w-9 h-9 rounded-full bg-surface-card border border-border-strong flex items-center justify-center text-text-muted">
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>

        <!-- Columna 2: Score y distribución -->
        <div class="bg-surface rounded-xl border border-border p-5 flex flex-col justify-between transition-shadow hover:shadow-md hover:border-border-strong">
          <div class="flex items-start justify-between mb-4">
            <div>
              <p class="text-2xs font-semibold text-text-muted uppercase tracking-wider mb-1">Score Promedio IA</p>
              <div
                class="flex items-baseline gap-1.5 text-3xl font-bold"
                :class="agentStats.avgScore >= 70 ? 'text-success' : (agentStats.avgScore >= 40 ? 'text-warning' : (agentStats.avgScore > 0 ? 'text-danger' : 'text-text-muted'))"
              >
                {{ loading ? '—' : agentStats.avgScore }}
                <span v-if="!loading && agentStats.analyzed > 0" class="text-sm font-medium text-text-muted">/ 100</span>
              </div>
            </div>
          </div>

          <div class="space-y-3 mt-auto">
            <!-- Hot -->
            <div>
              <div class="flex justify-between text-xs font-medium mb-1.5">
                <span class="text-text-secondary flex items-center gap-1.5"><span class="w-2 h-2 rounded-full bg-danger"></span>Hot</span>
                <span class="text-text-main font-semibold">{{ loading ? '-' : agentStats.hot }}</span>
              </div>
              <div class="w-full bg-surface rounded-full h-1.5 overflow-hidden">
                <div class="bg-danger h-1.5 rounded-full transition-all duration-1000 ease-out" :style="{ width: loading || agentStats.analyzed === 0 ? '0%' : `${(agentStats.hot / agentStats.analyzed) * 100}%` }"></div>
              </div>
            </div>
            <!-- Warm -->
            <div>
              <div class="flex justify-between text-xs font-medium mb-1.5">
                <span class="text-text-secondary flex items-center gap-1.5"><span class="w-2 h-2 rounded-full bg-warning"></span>Warm</span>
                <span class="text-text-main font-semibold">{{ loading ? '-' : agentStats.warm }}</span>
              </div>
              <div class="w-full bg-surface rounded-full h-1.5 overflow-hidden">
                <div class="bg-warning h-1.5 rounded-full transition-all duration-1000 ease-out" :style="{ width: loading || agentStats.analyzed === 0 ? '0%' : `${(agentStats.warm / agentStats.analyzed) * 100}%` }"></div>
              </div>
            </div>
            <!-- Cold -->
            <div>
              <div class="flex justify-between text-xs font-medium mb-1.5">
                <span class="text-text-secondary flex items-center gap-1.5"><span class="w-2 h-2 rounded-full bg-text-muted"></span>Cold</span>
                <span class="text-text-main font-semibold">{{ loading ? '-' : agentStats.cold }}</span>
              </div>
              <div class="w-full bg-surface rounded-full h-1.5 overflow-hidden">
                <div class="bg-text-muted h-1.5 rounded-full transition-all duration-1000 ease-out" :style="{ width: loading || agentStats.analyzed === 0 ? '0%' : `${(agentStats.cold / agentStats.analyzed) * 100}%` }"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Columna 3: Top Leads -->
        <div class="bg-surface rounded-xl border border-border flex flex-col overflow-hidden transition-shadow hover:shadow-md hover:border-border-strong">
          <div class="px-5 py-3 border-b border-border bg-surface-container/50">
            <p class="text-2xs font-semibold text-text-muted uppercase tracking-wider">Top Priorizados</p>
          </div>

          <div v-if="loading" class="flex-1 flex flex-col gap-3 p-5">
            <div class="h-8 bg-surface-card animate-pulse rounded-lg"></div>
            <div class="h-8 bg-surface-card animate-pulse rounded-lg"></div>
            <div class="h-8 bg-surface-card animate-pulse rounded-lg"></div>
          </div>

          <div v-else-if="topAiLeads.length > 0" class="flex-1 overflow-y-auto flex flex-col divide-y divide-border">
            <router-link
              v-for="lead in topAiLeads"
              :key="lead.id"
              :to="{ name: 'LeadDetail', params: { id: lead.id } }"
              class="px-5 py-3 hover:bg-surface-card transition-colors flex items-center justify-between group cursor-pointer"
            >
              <div class="min-w-0 flex-1 pr-3">
                <p class="text-sm font-medium text-text-main truncate group-hover:text-primary-300 transition-colors">{{ lead.full_name }}</p>
              </div>
              <div class="flex items-center gap-3 shrink-0">
                <BaseBadge :variant="lead.ai_score >= 70 ? 'success' : lead.ai_score >= 40 ? 'warning' : 'danger'">
                  {{ lead.ai_score }}
                </BaseBadge>
                <svg class="w-4 h-4 text-text-muted group-hover:text-primary-300 transition-colors transform group-hover:translate-x-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </div>
            </router-link>
          </div>

          <div v-else class="flex-1 flex flex-col items-center justify-center p-5 text-center">
            <div class="w-10 h-10 rounded-full bg-surface-card border border-border flex items-center justify-center mb-2">
              <svg class="w-5 h-5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
            </div>
            <p class="text-sm font-medium text-text-secondary">No hay leads analizados</p>
            <p class="text-xs text-text-muted mt-1">El agente procesará los nuevos leads.</p>
          </div>
        </div>
      </div>
    </BaseCard>

    <!-- ── Panel de Gestión de Agentes IA (Solo Admins) ── -->
    <AgentStatusPanel v-if="isAdmin" />

    <!-- ── Sección inferior: Actividad + Pipeline ── -->
    <div class="dashboard-bottom grid grid-cols-1 lg:grid-cols-3 gap-6">

      <!-- COLUMNA IZQUIERDA: Actividad Reciente -->
      <BaseCard :padded="false" class="lg:col-span-2 overflow-hidden">
        <div class="flex items-center justify-between px-6 py-4 border-b border-border">
          <h3 class="font-semibold text-text-main">Actividad Reciente</h3>
          <BaseBadge variant="default">{{ activities.length }}</BaseBadge>
        </div>

        <div class="px-6">
          <!-- Loading skeletons -->
          <div v-if="loading" class="flex flex-col gap-3 py-3">
            <div class="h-14 bg-surface-container animate-pulse rounded-lg"></div>
            <div class="h-14 bg-surface-container animate-pulse rounded-lg"></div>
            <div class="h-14 bg-surface-container animate-pulse rounded-lg"></div>
          </div>

          <!-- Con datos -->
          <ul v-else-if="activities.length > 0" class="divide-y divide-border">
            <li v-for="act in activities" :key="act.id" class="py-4 flex items-start gap-3">
              <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm shrink-0 border" :class="act.type?.includes('resumen') || act.type?.includes('ai') ? 'bg-indigo-500/20 border-indigo-500/30 shadow-[0_0_8px_rgba(99,102,241,0.3)]' : 'bg-surface-container border-border'">
                {{ act.type?.includes('resumen') || act.type?.includes('ai') ? '✨' : act.type?.includes('llamada') ? '📞' : act.type?.includes('correo') || act.type?.includes('email') ? '✉️' : act.type?.includes('webhook') ? '⚙️' : '💬' }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-text-main" :class="{'truncate': !act.type?.includes('resumen') && !act.type?.includes('ai'), 'line-clamp-2 text-indigo-100': act.type?.includes('resumen') || act.type?.includes('ai')}">{{ act.description }}</p>
                <p v-if="act.leads?.full_name" class="text-xs text-text-secondary">{{ act.leads.full_name }}</p>
              </div>
              <span class="text-xs text-text-muted whitespace-nowrap ml-auto">{{ formatDate(act.created_at) }}</span>
            </li>
          </ul>

          <!-- Sin datos -->
          <OrbitEmptyState
            v-else
            title="Sin actividad"
            description="Aún no hay registros."
          />
        </div>
      </BaseCard>

      <!-- COLUMNA DERECHA: Estado del Pipeline -->
      <BaseCard :padded="false" class="lg:col-span-1 overflow-hidden">
        <div class="px-6 py-4 border-b border-border">
          <h3 class="font-semibold text-text-main">Pipeline</h3>
        </div>

        <div class="px-6 py-5">
          <!-- Barra de progreso -->
          <p class="text-sm text-text-secondary mb-3">Negocios en curso</p>
          <div class="bg-surface rounded-full h-2">
            <div
              class="bg-primary rounded-full h-2 transition-all duration-500"
              :style="{ width: stats.negociosActivos > 0 ? '100%' : '0%' }"
            ></div>
          </div>
          <p class="text-xs text-text-secondary mt-2">
            <span class="font-semibold text-text-main">{{ loading ? '—' : stats.negociosActivos }}</span>
            negocios activos en pipeline
          </p>

          <!-- Separador -->
          <div class="border-t border-border my-5"></div>

          <!-- Total ventas cerradas -->
          <p class="text-sm text-text-secondary">Total cerrado</p>
          <p class="text-xl font-bold text-success mt-1">
            {{ loading ? '—' : formatCurrency(stats.ventasCerradas) }}
          </p>
          <p class="text-xs text-text-muted mt-1">Negocios en etapa "ganado"</p>
        </div>
      </BaseCard>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import { gsap } from 'gsap'
import { supabase } from '../lib/supabase'
import OrbitMetricCard from '../components/OrbitMetricCard.vue'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import AgentStatusPanel from '../components/AgentStatusPanel.vue'

const loading = ref(true)
const error = ref(null)
const isAdmin = ref(false)

const stats = ref({
  nuevosLeads: 0,
  negociosActivos: 0,
  cotizacionesEnviadas: 0,
  ventasCerradas: 0
})

const agentStats = ref({
  total: 0,
  analyzed: 0,
  pending: 0,
  avgScore: 0,
  hot: 0,
  warm: 0,
  cold: 0
})

const topAiLeads = ref([])
const activities = ref([])

const animateDashboard = () => {
  nextTick(() => {
    gsap.fromTo('.metric-card',
      { opacity: 0, y: 30, scale: 0.95 },
      {
        opacity: 1, y: 0, scale: 1,
        duration: 0.5,
        stagger: 0.1,
        ease: 'power2.out'
      }
    )
    gsap.fromTo('.agent-overview-section',
      { opacity: 0, y: 20 },
      { opacity: 1, y: 0, duration: 0.6, delay: 0.3, ease: 'power2.out' }
    )
    gsap.fromTo('.dashboard-bottom',
      { opacity: 0, y: 20 },
      { opacity: 1, y: 0, duration: 0.6, delay: 0.5, ease: 'power2.out' }
    )
  })
}

const animateCounter = (element, target) => {
  const obj = { val: 0 }
  gsap.to(obj, {
    val: target,
    duration: 1.2,
    ease: 'power2.out',
    onUpdate: () => {
      if (element) element.textContent = Math.round(obj.val).toLocaleString('es-CL')
    }
  })
}

watch(loading, (newVal) => {
  if (!newVal) {
    animateDashboard()
    nextTick(() => {
      const counterEls = document.querySelectorAll('.metric-counter')
      counterEls.forEach(el => {
        const target = parseInt(el.dataset.target || '0')
        if (!isNaN(target)) animateCounter(el, target)
      })
    })
  }
})

const formatCurrency = (value) => {
  return '$' + new Intl.NumberFormat('es-CL', {
    maximumFractionDigits: 0
  }).format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'short',
    timeStyle: 'short'
  }).format(date)
}

const fetchDashboardData = async () => {
  loading.value = true
  error.value = null

  try {
    const { data: { session } } = await supabase.auth.getSession()
    const role = session?.user?.user_metadata?.role
    isAdmin.value = role === 'admin' || role === 'superadmin'

    // 1. Obtener Nuevos Leads (status = 'nuevo')
    const { count: nuevosLeadsCount, error: errLeads } = await supabase
      .from('leads')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'nuevo')
    if (errLeads) throw errLeads

    // 2. Obtener Negocios Activos (excluyendo ganados/perdidos)
    const { count: negociosActivosCount, error: errDeals } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      .in('stage', ['prospecto', 'cotizado', 'negociando'])
    if (errDeals) throw errDeals

    // 3. Obtener Cotizaciones Enviadas (stage = 'cotizado')
    const { count: cotizacionesEnviadasCount, error: errQuotes } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      .eq('stage', 'cotizado')
    if (errQuotes) throw errQuotes

    // 4. Obtener Ventas Cerradas (sum de value para stage = 'ganado')
    const { data: ventasCerradasData, error: errVentas } = await supabase
      .from('deals')
      .select('value')
      .eq('stage', 'ganado')
    if (errVentas) throw errVentas

    const totalVentas = ventasCerradasData?.reduce((sum, item) => sum + Number(item.value || 0), 0) || 0

    stats.value = {
      nuevosLeads: nuevosLeadsCount || 0,
      negociosActivos: negociosActivosCount || 0,
      cotizacionesEnviadas: cotizacionesEnviadasCount || 0,
      ventasCerradas: totalVentas
    }

    // 5. Obtener datos del Agente IA (Leads con score)
    const { data: aiLeadsData, error: errAiLeads } = await supabase
      .from('leads')
      .select('id, full_name, ai_score, ai_category')

    if (errAiLeads) throw errAiLeads

    if (aiLeadsData) {
      const analyzedLeads = aiLeadsData.filter(l => l.ai_score !== null)
      const pendingLeads = aiLeadsData.filter(l => l.ai_score === null)

      const totalScore = analyzedLeads.reduce((sum, l) => sum + l.ai_score, 0)
      const avgScore = analyzedLeads.length > 0 ? Math.round(totalScore / analyzedLeads.length) : 0

      agentStats.value = {
        total: aiLeadsData.length,
        analyzed: analyzedLeads.length,
        pending: pendingLeads.length,
        avgScore: avgScore,
        hot: analyzedLeads.filter(l => l.ai_category === 'Hot').length,
        warm: analyzedLeads.filter(l => l.ai_category === 'Warm').length,
        cold: analyzedLeads.filter(l => l.ai_category === 'Cold').length
      }

      topAiLeads.value = analyzedLeads
        .sort((a, b) => b.ai_score - a.ai_score)
        .slice(0, 3)
    }

    // 6. Obtener Actividades Recientes
    const { data: activitiesData, error: errActivities } = await supabase
      .from('activities')
      .select('id, type, description, created_at, leads(full_name)')
      .order('created_at', { ascending: false })
      .limit(5)
    if (errActivities) throw errActivities

    activities.value = activitiesData || []

  } catch (err) {
    console.error('Error al cargar datos del Dashboard:', err)
    error.value = 'Error al cargar los datos en tiempo real de Supabase.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>
