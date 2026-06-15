<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10" style="background: radial-gradient(circle, #3b82f6, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">Resultados</span>
          </div>
          <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Ventas</h1>
          <p class="text-gray-400 text-sm">Monitoreo de ingresos y transacciones comerciales cerradas.</p>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 shrink-0">
      {{ error }}
    </div>

    <!-- Metrics Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 shrink-0" v-if="sales.length > 0 || !loading">
      <OrbitMetricCard 
        title="Total Ventas" 
        :value="totalSales" 
        icon="briefcase" 
        color="purple" 
      />
      <OrbitMetricCard 
        title="Monto Total" 
        :value="formatCurrency(totalAmount)" 
        icon="document" 
        color="blue" 
      />
      <OrbitMetricCard 
        title="Ticket Promedio" 
        :value="formatCurrency(averageTicket)" 
        icon="chart" 
        color="orange" 
      />
      <OrbitMetricCard 
        title="Tasa de Cierre" 
        :value="winRate + '%'" 
        icon="users" 
        color="green" 
      />
    </div>

    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm flex flex-col flex-1 overflow-hidden">
      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando ventas cerradas...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="sales.length === 0" class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState 
          title="No hay ventas cerradas" 
          description="Aún no hay negocios ganados. Sigue trabajando en tu pipeline."
        />
      </div>

      <!-- Data Table -->
      <div v-else class="overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-[#f0edef] text-text-secondary font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Negocio</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Cliente (Lead)</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs text-right">Monto</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Fecha cierre</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Vendedor</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs text-center">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="sale in sales" :key="sale.id" class="hover:bg-primary/5 transition-colors group">
              <td class="px-6 py-4">
                <div class="font-medium text-text-main">{{ sale.title }}</div>
                <div class="text-xs text-text-secondary mt-0.5">ID: #TX-{{ String(sale.id).padStart(4, '0') }}</div>
              </td>
              <td class="px-6 py-4 text-text-secondary">
                {{ sale.leads?.full_name || 'Sin contacto' }}
              </td>
              <td class="px-6 py-4 text-right">
                <span class="font-semibold text-success bg-success/10 px-2.5 py-1 rounded-full text-xs">
                  {{ formatCurrency(sale.value) }}
                </span>
              </td>
              <td class="px-6 py-4 text-text-secondary whitespace-nowrap">
                {{ formatDate(sale.updated_at || sale.created_at) }}
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <div class="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center text-primary text-[10px] font-bold">
                    {{ getInitials(sale.profiles?.full_name) }}
                  </div>
                  <span class="text-text-main font-medium">{{ sale.profiles?.full_name || 'Usuario' }}</span>
                </div>
              </td>
              <td class="px-6 py-4 text-center">
                <button class="p-2 hover:bg-surface rounded-full transition-colors text-border group-hover:text-text-secondary opacity-0 group-hover:opacity-100">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitMetricCard from '../components/OrbitMetricCard.vue'

const sales = ref([])
const loading = ref(true)
const error = ref(null)

const totalDealsCount = ref(0)

const fetchSales = async () => {
  loading.value = true
  error.value = null
  try {
    // 1. Obtener los ganados para la tabla
    const { data, error: err } = await supabase
      .from('deals')
      .select('*, leads(full_name), profiles(full_name)')
      .eq('stage', 'Ganado')
      .order('updated_at', { ascending: false })
      
    if (err) throw err
    sales.value = data || []

    // 2. Obtener el conteo total para la tasa de cierre (opcional pero lo hace real)
    const { count, error: countErr } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      
    if (!countErr && count) {
      totalDealsCount.value = count
    } else {
      totalDealsCount.value = sales.value.length // fallback
    }

  } catch (err) {
    console.error('Error fetching sales:', err)
    error.value = 'Ocurrió un error al cargar las ventas cerradas.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchSales()
})

const getInitials = (name) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const totalSales = computed(() => sales.value.length)

const totalAmount = computed(() => {
  return sales.value.reduce((acc, sale) => acc + (Number(sale.value) || 0), 0)
})

const averageTicket = computed(() => {
  if (totalSales.value === 0) return 0
  return Math.round(totalAmount.value / totalSales.value)
})

const winRate = computed(() => {
  if (totalDealsCount.value === 0) return 0
  return Math.round((totalSales.value / totalDealsCount.value) * 100)
})

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '—'
  return '$' + new Intl.NumberFormat('es-CL', {
    maximumFractionDigits: 0
  }).format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(new Date(dateString))
}
</script>
