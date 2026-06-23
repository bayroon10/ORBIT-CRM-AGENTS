<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-white/10 shadow-2xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Resultados</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-slate-50 mb-2 tracking-tight">Ventas</h1>
          <p class="text-slate-400 text-sm">Monitoreo de ingresos y transacciones comerciales cerradas.</p>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0">
      {{ error }}
    </div>

    <!-- Metrics Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 shrink-0" v-if="sales.length > 0 || !loading">
      <OrbitMetricCard 
        title="Total Ventas" 
        :value="totalSales" 
        icon="briefcase" 
      />
      <OrbitMetricCard 
        title="Monto Total" 
        :value="formatCurrency(totalAmount)" 
        icon="document" 
      />
      <OrbitMetricCard 
        title="Ticket Promedio" 
        :value="formatCurrency(averageTicket)" 
        icon="chart" 
      />
      <OrbitMetricCard 
        title="Tasa de Cierre" 
        :value="winRate + '%'" 
        icon="users" 
      />
    </div>

    <BaseCard :padded="false" class="flex flex-col flex-1 overflow-hidden">
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
          <thead class="bg-slate-950/50 backdrop-blur-md text-slate-400 font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Negocio</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Cliente (Lead)</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs text-right">Monto</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Fecha cierre</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Vendedor</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs text-center">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/10">
            <tr v-for="sale in sales" :key="sale.id" class="hover:bg-slate-900/50 transition-colors group">
              <td class="px-6 py-4">
                <div class="font-medium text-slate-50">{{ sale.title }}</div>
                <div class="text-xs text-slate-400 mt-0.5">ID: #TX-{{ String(sale.id).padStart(4, '0') }}</div>
              </td>
              <td class="px-6 py-4 text-slate-400">
                {{ sale.leads?.full_name || 'Sin contacto' }}
              </td>
              <td class="px-6 py-4 text-right">
                <span class="font-semibold text-success bg-success/10 border border-success/20 px-2.5 py-1 rounded-full text-xs">
                  {{ formatCurrency(sale.value) }}
                </span>
              </td>
              <td class="px-6 py-4 text-slate-400 whitespace-nowrap">
                {{ formatDate(sale.updated_at || sale.created_at) }}
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <div class="w-6 h-6 rounded-full bg-primary/15 border border-primary/20 flex items-center justify-center text-primary-300 text-[10px] font-bold">
                    {{ getInitials(sale.profiles?.full_name) }}
                  </div>
                  <span class="text-slate-50 font-medium">{{ sale.profiles?.full_name || 'Usuario' }}</span>
                </div>
              </td>
              <td class="px-6 py-4 text-center">
                <button class="p-2 hover:bg-slate-800/50 rounded-full transition-colors text-slate-500 group-hover:text-slate-50 opacity-0 group-hover:opacity-100">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </BaseCard>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { SalesService } from '../services/sales.service'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitMetricCard from '../components/OrbitMetricCard.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'

const sales = ref([])
const loading = ref(true)
const error = ref(null)

const totalDealsCount = ref(0)

const fetchSales = async () => {
  loading.value = true
  error.value = null
  try {
    // 1. Obtener los ganados para la tabla
    const { data, error: err } = await SalesService.getWonDeals()
      
    if (err) throw err
    sales.value = data || []

    // 2. Obtener el conteo total para la tasa de cierre (opcional pero lo hace real)
    const { count, error: countErr } = await SalesService.getTotalDealsCount()
      
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
