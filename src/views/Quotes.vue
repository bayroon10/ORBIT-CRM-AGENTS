<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10" style="background: radial-gradient(circle, #3b82f6, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">Propuestas</span>
          </div>
          <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Cotizaciones</h1>
          <p class="text-gray-400 text-sm">Gestiona y haz seguimiento de todas tus propuestas comerciales.</p>
        </div>
        <button 
          @click="router.push('/quotes/new')"
          class="bg-primary hover:bg-primary-variant btn-glow text-white px-5 py-2.5 rounded-lg text-sm font-medium transition-all flex items-center gap-2 shadow-sm"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          Nueva cotización
        </button>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 shrink-0">
      {{ error }}
    </div>

    <!-- Summary Metrics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6 shrink-0" v-if="quotes.length > 0">
      <div class="bg-white border border-gray-100 rounded-xl p-4 shadow-sm flex flex-col gap-1">
        <span class="text-sm font-semibold text-text-secondary">Total Cotizaciones</span>
        <span class="text-2xl font-bold text-text-main">{{ quotes.length }}</span>
      </div>
      <div class="bg-white border border-gray-100 rounded-xl p-4 shadow-sm flex flex-col gap-1">
        <span class="text-sm font-semibold text-text-secondary">Pendientes</span>
        <span class="text-2xl font-bold text-text-main">{{ pendingQuotesCount }}</span>
      </div>
      <div class="bg-white border border-gray-100 rounded-xl p-4 shadow-sm flex flex-col gap-1">
        <span class="text-sm font-semibold text-text-secondary">Aprobadas</span>
        <span class="text-2xl font-bold text-text-main">{{ approvedQuotesCount }}</span>
      </div>
      <div class="bg-white border border-primary/30 rounded-xl p-4 shadow-sm flex flex-col gap-1 relative overflow-hidden">
        <div class="absolute inset-0 bg-primary/5 pointer-events-none"></div>
        <span class="text-sm font-semibold text-text-secondary relative z-10">Valor Total Estimado</span>
        <span class="text-2xl font-bold text-primary relative z-10">{{ formatCurrency(totalValue) }}</span>
      </div>
    </div>

    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-gray-100 flex justify-between items-center shrink-0">
        <div class="flex items-center gap-4">
          <div class="relative w-72">
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="Buscar por cliente o ID..." 
              class="w-full pl-10 pr-4 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            />
            <div class="absolute left-3 top-2.5 text-text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            </div>
          </div>
          <div class="relative">
            <select 
              v-model="selectedStatus"
              class="appearance-none bg-surface border border-border rounded-lg px-4 py-2 pr-10 text-sm text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary cursor-pointer transition-all"
            >
              <option value="">Todos los estados</option>
              <option value="Borrador">Borrador</option>
              <option value="Enviada">Enviada</option>
              <option value="Aprobada">Aprobada</option>
              <option value="Rechazada">Rechazada</option>
            </select>
            <svg class="absolute right-3 top-2.5 pointer-events-none text-text-secondary" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando cotizaciones...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredQuotes.length === 0" class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState 
          :title="searchQuery || selectedStatus ? 'No hay resultados' : 'No hay cotizaciones'" 
          :description="searchQuery || selectedStatus ? 'No se encontraron cotizaciones que coincidan con los filtros.' : 'Genera tu primera propuesta comercial.'"
        />
      </div>

      <!-- Data Table -->
      <div v-else class="overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-[#f0edef] text-text-secondary font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">#</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Cliente</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs text-right">Monto</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Estado</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Fecha</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs text-right">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="quote in filteredQuotes" :key="quote.id" class="hover:bg-primary/5 transition-colors group">
              <td class="px-6 py-4 font-medium text-primary">
                #QT-{{ String(quote.id).padStart(5, '0') }}
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-full bg-surface flex items-center justify-center border border-border text-xs font-bold text-text-secondary">
                    {{ getInitials(getClientName(quote)) }}
                  </div>
                  <div>
                    <div class="font-semibold text-text-main">{{ getClientName(quote) }}</div>
                    <div class="text-xs text-text-secondary">{{ quote.leads?.full_name || 'Sin contacto' }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 text-right font-semibold text-text-main">
                {{ formatCurrency(quote.value) }}
              </td>
              <td class="px-6 py-4">
                <span 
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border"
                  :class="getStatusBadgeClass(getMappedStatus(quote.stage))"
                >
                  {{ getMappedStatus(quote.stage) }}
                </span>
              </td>
              <td class="px-6 py-4 text-text-secondary whitespace-nowrap">
                {{ formatDate(quote.created_at) }}
              </td>
              <td class="px-6 py-4 text-right">
                <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button class="p-1.5 text-text-secondary hover:text-primary rounded hover:bg-primary/10 transition-colors" title="Ver">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                  </button>
                  <button class="p-1.5 text-text-secondary hover:text-primary rounded hover:bg-primary/10 transition-colors" title="Editar">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                  </button>
                </div>
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
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'

const router = useRouter()
const quotes = ref([])
const loading = ref(true)
const error = ref(null)

const searchQuery = ref('')
const selectedStatus = ref('')

const fetchQuotes = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('deals')
      .select('id, title, value, stage, created_at, companies(name), leads(full_name)')
      .gt('value', 0)
      .order('created_at', { ascending: false })
      
    if (err) throw err
    quotes.value = data || []
  } catch (err) {
    console.error('Error fetching quotes:', err)
    error.value = 'Ocurrió un error al cargar las cotizaciones.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchQuotes()
})

const getMappedStatus = (stage) => {
  const map = {
    'prospecto': 'Borrador',
    'cotizado': 'Enviada',
    'negociando': 'Enviada',
    'ganado': 'Aprobada',
    'perdido': 'Rechazada'
  }
  return map[stage] || 'Borrador'
}

const getStatusBadgeClass = (status) => {
  const map = {
    'Borrador': 'bg-gray-100 text-gray-600 border-gray-200',
    'Enviada': 'bg-[#d8e2ff] text-[#085ac0] border-[#085ac0]/20',
    'Aprobada': 'bg-[#84f9c3] text-[#019668] border-[#019668]/20',
    'Rechazada': 'bg-[#ffdad6] text-[#ba1a1a] border-[#ba1a1a]/20'
  }
  return map[status] || 'bg-gray-100 text-gray-600 border-gray-200'
}

const getClientName = (quote) => {
  return quote.companies?.name || quote.title || 'Sin cliente'
}

const getInitials = (name) => {
  if (!name) return '?'
  return name.substring(0, 2).toUpperCase()
}

const filteredQuotes = computed(() => {
  return quotes.value.filter(quote => {
    const clientName = getClientName(quote).toLowerCase()
    const matchName = clientName.includes(searchQuery.value.toLowerCase()) || 
                      String(quote.id).includes(searchQuery.value)
    
    const mappedStatus = getMappedStatus(quote.stage)
    const matchStatus = !selectedStatus.value || mappedStatus === selectedStatus.value
    
    return matchName && matchStatus
  })
})

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '—'
  return '$' + new Intl.NumberFormat('es-CL').format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(new Date(dateString))
}

// Derived Metrics
const totalValue = computed(() => {
  return quotes.value.reduce((acc, curr) => acc + (Number(curr.value) || 0), 0)
})

const pendingQuotesCount = computed(() => {
  return quotes.value.filter(q => {
    const status = getMappedStatus(q.stage)
    return status === 'Borrador' || status === 'Enviada'
  }).length
})

const approvedQuotesCount = computed(() => {
  return quotes.value.filter(q => getMappedStatus(q.stage) === 'Aprobada').length
})
</script>
