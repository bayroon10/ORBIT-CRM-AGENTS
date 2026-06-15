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
    gsap.fromTo('.dashboard-bottom',
      { opacity: 0, y: 20 },
      { opacity: 1, y: 0, duration: 0.6, delay: 0.4, ease: 'power2.out' }
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

    // 5. Obtener Actividades Recientes con unión a leads (columna full_name)
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


