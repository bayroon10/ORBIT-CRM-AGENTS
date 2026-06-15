<template>
  <div class="min-h-full">
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl">
      <!-- Efecto de puntos decorativos -->
      <div class="absolute inset-0 opacity-10"
        style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;">
      </div>
      <!-- Orbe decorativo -->
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10"
        style="background: radial-gradient(circle, #3b82f6, transparent 70%);">
      </div>
      <div class="relative z-10">
        <div class="flex items-center gap-2 mb-3">
          <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">
            Dashboard
          </span>
        </div>
        <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Panel de Control</h1>
        <p class="text-gray-400 text-sm">Resumen ejecutivo del pipeline comercial en tiempo real.</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10">
      {{ error }}
    </div>

    <!-- Metrics Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
      <OrbitMetricCard
        class="metric-card"
        title="Prospectos Nuevos"
        :value="loading ? '—' : stats.nuevosLeads"
        icon="users"
        color="blue"
      />
      <OrbitMetricCard
        class="metric-card"
        title="Negocios Activos"
        :value="loading ? '—' : stats.negociosActivos"
        icon="briefcase"
        color="purple"
      />
      <OrbitMetricCard
        class="metric-card"
        title="En Cotización"
        :value="loading ? '—' : stats.cotizacionesEnviadas"
        icon="document"
        color="orange"
      />
      <OrbitMetricCard
        class="metric-card"
        title="Ventas Cerradas"
        :value="loading ? '—' : formatCurrency(stats.ventasCerradas)"
        icon="chart"
        color="green"
      />
    </div>

    <!-- Agent Overview Layer -->
    <div class="agent-overview-section relative overflow-hidden bg-gradient-to-br from-slate-50 to-blue-50/40 rounded-2xl border border-blue-100/60 p-6 mb-8 shadow-sm">
      <!-- Línea de acento superior IA -->
      <div class="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-400 via-violet-400 to-emerald-400 opacity-80"></div>
      
      <!-- Header IA -->
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6 relative z-10">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h2 class="text-lg font-bold text-gray-900 tracking-tight">Sales Intelligence Agent</h2>
              <span class="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-emerald-100 text-emerald-700 border border-emerald-200">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                Activo
              </span>
            </div>
            <p class="text-xs text-gray-500 mt-0.5">Análisis automático de leads vía Gemini AI</p>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 relative z-10">
        <!-- Columna 1: KPIs Básicos -->
        <div class="flex flex-col gap-4">
          <div class="bg-white rounded-xl border border-gray-100 p-4 shadow-sm flex items-center justify-between transition-shadow hover:shadow-md">
            <div>
              <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Analizados</p>
              <div class="flex items-baseline gap-2">
                <span class="text-2xl font-bold text-gray-900">{{ loading ? '—' : agentStats.analyzed }}</span>
                <span class="text-xs text-gray-500 font-medium">/ {{ loading ? '—' : agentStats.total }} leads</span>
              </div>
            </div>
            <div class="w-10 h-10 rounded-full bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600">
              <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
          
          <div class="bg-white rounded-xl border border-gray-100 p-4 shadow-sm flex items-center justify-between transition-shadow hover:shadow-md">
            <div>
              <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Pendientes</p>
              <div class="flex items-baseline gap-2">
                <span class="text-2xl font-bold text-gray-900">{{ loading ? '—' : agentStats.pending }}</span>
                <span class="text-xs text-gray-500 font-medium">en cola</span>
              </div>
            </div>
            <div class="w-10 h-10 rounded-full bg-gray-50 border border-gray-200 flex items-center justify-center text-gray-400">
              <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>

        <!-- Columna 2: Distribución y Score -->
        <div class="bg-white rounded-xl border border-gray-100 p-5 shadow-sm flex flex-col justify-between transition-shadow hover:shadow-md">
          <div class="flex items-start justify-between mb-4">
            <div>
              <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Score Promedio IA</p>
              <div class="flex items-baseline gap-1.5 text-3xl font-bold" :class="agentStats.avgScore >= 70 ? 'text-emerald-600' : (agentStats.avgScore >= 40 ? 'text-yellow-600' : (agentStats.avgScore > 0 ? 'text-red-600' : 'text-gray-400'))">
                {{ loading ? '—' : agentStats.avgScore }}
                <span v-if="!loading && agentStats.analyzed > 0" class="text-sm font-medium text-gray-400">/ 100</span>
              </div>
            </div>
          </div>
          
          <div class="space-y-3 mt-auto">
            <!-- Hot -->
            <div>
              <div class="flex justify-between text-xs font-medium mb-1.5">
                <span class="text-gray-600 flex items-center gap-1.5"><span class="w-2 h-2 rounded-full bg-red-500"></span>Hot</span>
                <span class="text-gray-900 font-semibold">{{ loading ? '-' : agentStats.hot }}</span>
              </div>
              <div class="w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
                <div class="bg-red-500 h-1.5 rounded-full transition-all duration-1000 ease-out" :style="{ width: loading || agentStats.analyzed === 0 ? '0%' : `${(agentStats.hot / agentStats.analyzed) * 100}%` }"></div>
              </div>
            </div>
            <!-- Warm -->
            <div>
              <div class="flex justify-between text-xs font-medium mb-1.5">
                <span class="text-gray-600 flex items-center gap-1.5"><span class="w-2 h-2 rounded-full bg-amber-500"></span>Warm</span>
                <span class="text-gray-900 font-semibold">{{ loading ? '-' : agentStats.warm }}</span>
              </div>
              <div class="w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
                <div class="bg-amber-500 h-1.5 rounded-full transition-all duration-1000 ease-out" :style="{ width: loading || agentStats.analyzed === 0 ? '0%' : `${(agentStats.warm / agentStats.analyzed) * 100}%` }"></div>
              </div>
            </div>
            <!-- Cold -->
            <div>
              <div class="flex justify-between text-xs font-medium mb-1.5">
                <span class="text-gray-600 flex items-center gap-1.5"><span class="w-2 h-2 rounded-full bg-slate-400"></span>Cold</span>
                <span class="text-gray-900 font-semibold">{{ loading ? '-' : agentStats.cold }}</span>
              </div>
              <div class="w-full bg-gray-100 rounded-full h-1.5 overflow-hidden">
                <div class="bg-slate-400 h-1.5 rounded-full transition-all duration-1000 ease-out" :style="{ width: loading || agentStats.analyzed === 0 ? '0%' : `${(agentStats.cold / agentStats.analyzed) * 100}%` }"></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Columna 3: Top Leads -->
        <div class="bg-white rounded-xl border border-gray-100 p-0 shadow-sm flex flex-col overflow-hidden transition-shadow hover:shadow-md">
          <div class="px-5 py-4 border-b border-gray-100 bg-gray-50/50">
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Top Priorizados</p>
          </div>
          
          <div v-if="loading" class="flex-1 flex flex-col gap-3 p-5">
            <div class="h-8 bg-gray-50 animate-pulse rounded-md"></div>
            <div class="h-8 bg-gray-50 animate-pulse rounded-md"></div>
            <div class="h-8 bg-gray-50 animate-pulse rounded-md"></div>
          </div>
          
          <div v-else-if="topAiLeads.length > 0" class="flex-1 overflow-y-auto flex flex-col divide-y divide-gray-50">
            <router-link 
              v-for="lead in topAiLeads" 
              :key="lead.id" 
              :to="{ name: 'LeadDetail', params: { id: lead.id } }"
              class="px-5 py-3 hover:bg-blue-50/50 transition-colors flex items-center justify-between group cursor-pointer"
            >
              <div class="min-w-0 flex-1 pr-3">
                <p class="text-sm font-medium text-gray-900 truncate group-hover:text-blue-700 transition-colors">{{ lead.full_name }}</p>
              </div>
              <div class="flex items-center gap-3 shrink-0">
                <span class="inline-flex items-center justify-center min-w-[32px] px-1.5 py-0.5 rounded text-xs font-bold border" :class="getScoreBadgeClass(lead.ai_score)">
                  {{ lead.ai_score }}
                </span>
                <svg class="w-4 h-4 text-gray-300 group-hover:text-blue-500 transition-colors transform group-hover:translate-x-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </div>
            </router-link>
          </div>
          
          <div v-else class="flex-1 flex flex-col items-center justify-center p-5 text-center bg-gray-50/30">
            <div class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center mb-2">
              <svg class="w-5 h-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
            </div>
            <p class="text-sm font-medium text-gray-600">No hay leads analizados</p>
            <p class="text-xs text-gray-400 mt-1">El agente procesará los nuevos leads.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Sección inferior: Actividad + Pipeline -->
    <div class="dashboard-bottom grid grid-cols-1 lg:grid-cols-3 gap-6">

      <!-- COLUMNA IZQUIERDA: Actividad Reciente -->
      <div class="lg:col-span-2 bg-white rounded-xl border border-border overflow-hidden">
        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-border">
          <h3 class="font-semibold text-text-main">Actividad Reciente</h3>
          <span class="bg-gray-100 text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">
            {{ activities.length }}
          </span>
        </div>

        <!-- Body -->
        <div class="px-6">
          <!-- Loading skeletons -->
          <div v-if="loading" class="flex flex-col gap-3 py-3">
            <div class="h-14 bg-surface animate-pulse rounded-lg"></div>
            <div class="h-14 bg-surface animate-pulse rounded-lg"></div>
            <div class="h-14 bg-surface animate-pulse rounded-lg"></div>
          </div>

          <!-- Con datos -->
          <ul v-else-if="activities.length > 0" class="divide-y divide-border">
            <li v-for="act in activities" :key="act.id" class="py-4 flex items-start gap-3">
              <div class="w-8 h-8 bg-surface rounded-full flex items-center justify-center text-sm shrink-0">
                {{ act.type?.includes('llamada') ? '📞' : act.type?.includes('correo') || act.type?.includes('email') ? '✉️' : act.type?.includes('webhook') ? '⚙️' : '💬' }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-text-main truncate">{{ act.description }}</p>
                <p v-if="act.leads?.full_name" class="text-xs text-text-secondary">{{ act.leads.full_name }}</p>
              </div>
              <span class="text-xs text-text-secondary whitespace-nowrap ml-auto">{{ formatDate(act.created_at) }}</span>
            </li>
          </ul>

          <!-- Sin datos -->
          <OrbitEmptyState
            v-else
            title="Sin actividad"
            description="Aún no hay registros."
          />
        </div>
      </div>

      <!-- COLUMNA DERECHA: Estado del Pipeline -->
      <div class="lg:col-span-1 bg-white rounded-xl border border-border overflow-hidden">
        <!-- Header -->
        <div class="px-6 py-4 border-b border-border">
          <h3 class="font-semibold text-text-main">Pipeline</h3>
        </div>

        <!-- Body -->
        <div class="px-6 py-5">
          <!-- Barra de progreso -->
          <p class="text-sm text-text-secondary mb-3">Negocios en curso</p>
          <div class="bg-gray-100 rounded-full h-2">
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
          <p class="text-xs text-text-secondary mt-1">Negocios en etapa "ganado"</p>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import { gsap } from 'gsap'
import { supabase } from '../lib/supabase'
import OrbitPageHeader from '../components/OrbitPageHeader.vue'
import OrbitMetricCard from '../components/OrbitMetricCard.vue'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'

const loading = ref(true)
const error = ref(null)

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

const getScoreBadgeClass = (score) => {
  if (score == null) return ''
  if (score >= 70) return 'bg-emerald-50 text-emerald-700 border-emerald-100'
  if (score >= 40) return 'bg-yellow-50 text-yellow-700 border-yellow-100'
  return 'bg-red-50 text-red-700 border-red-100'
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

      // Sort analyzed leads by score descending and take top 3
      topAiLeads.value = analyzedLeads
        .sort((a, b) => b.ai_score - a.ai_score)
        .slice(0, 3)
    }

    // 6. Obtener Actividades Recientes con unión a leads (columna full_name)
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


