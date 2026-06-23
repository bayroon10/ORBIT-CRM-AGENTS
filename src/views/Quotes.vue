<template>
  <div class="flex flex-col h-full">
    <!-- ── Hero Header ── -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-white/10 shadow-2xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Comercial</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-slate-50 mb-2 tracking-tight">Cotizaciones</h1>
          <p class="text-slate-400 text-sm">Gestiona y haz seguimiento de todas tus propuestas comerciales.</p>
        </div>
        <BaseButton @click="showModal = true" size="lg">Nueva Cotización</BaseButton>
      </div>
    </div>

    <!-- ── Error State ── -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0">
      {{ error }}
    </div>

    <!-- ── Table Card ── -->
    <BaseCard :padded="false" class="flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-white/10 flex justify-between items-center shrink-0">
        <div class="relative w-72">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar por código..."
            class="w-full pl-10 pr-4 py-2 bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
          <div class="absolute left-3 top-2.5 text-slate-400">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando cotizaciones...</p>
      </div>

      <!-- Table -->
      <div v-else-if="filteredQuotes.length > 0" class="overflow-x-auto overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-slate-950/50 backdrop-blur-md text-slate-400 font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Código</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Negocio</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Monto</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs">Estado</th>
              <th class="px-6 py-4 border-b border-white/10 uppercase tracking-wider text-xs hidden md:table-cell">Válida Hasta</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/10">
            <tr
              v-for="quote in filteredQuotes"
              :key="quote.id"
              @click="router.push(`/quotes/${quote.id}`)"
              class="hover:bg-slate-900/50 transition-colors cursor-pointer group"
            >
              <td class="px-6 py-4">
                <div class="font-medium text-slate-50 group-hover:text-primary-300 transition-colors">{{ quote.quote_number }}</div>
              </td>
              <td class="px-6 py-4 text-slate-400">
                {{ quote.deals?.title || '—' }}
              </td>
              <td class="px-6 py-4 font-semibold text-success">
                {{ formatCurrency(quote.amount) }}
              </td>
              <td class="px-6 py-4">
                <BaseBadge :variant="getStatusVariant(quote.status)">
                  {{ translateStatus(quote.status) }}
                </BaseBadge>
              </td>
              <td class="px-6 py-4 text-slate-400 whitespace-nowrap hidden md:table-cell">
                {{ formatDate(quote.valid_until) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-else class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState
          :title="searchQuery ? 'No hay resultados' : 'No hay cotizaciones'"
          :description="searchQuery ? 'No se encontraron cotizaciones que coincidan con tu búsqueda.' : 'Crea tu primera cotización y asóciala a un negocio.'"
        />
      </div>
    </BaseCard>

    <!-- ── Modal Nueva Cotización ── -->
    <OrbitModal v-model="showModal" title="Nueva Cotización">
      <form @submit.prevent="submitQuote" class="space-y-4">

        <div v-if="formError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm flex items-start gap-2 border border-danger/20">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 shrink-0"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
          <span>{{ formError }}</span>
        </div>

        <div class="bg-slate-800/50 border border-white/10 p-3 rounded-lg text-sm text-slate-400 mb-4">
          <svg class="inline-block w-4 h-4 mr-1 mb-0.5 text-primary-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          El código <span class="font-bold text-slate-50">Quote Number</span> se generará automáticamente tras guardar.
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Negocio Asociado (Deal) *</label>
          <select
            v-model="form.deal_id"
            required
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          >
            <option value="" disabled>Seleccione un negocio</option>
            <option v-for="deal in availableDeals" :key="deal.id" :value="deal.id">
              {{ deal.title }}
            </option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Monto *</label>
          <input
            v-model="form.amount"
            type="number"
            min="0"
            step="0.01"
            required
            placeholder="0.00"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Estado</label>
          <select
            v-model="form.status"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          >
            <option value="draft">Borrador</option>
            <option value="sent">Enviada</option>
            <option value="accepted">Aceptada</option>
            <option value="rejected">Rechazada</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Válida Hasta</label>
          <input
            v-model="form.valid_until"
            type="date"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>
      </form>

      <template #footer>
        <div class="flex justify-end gap-3">
          <BaseButton variant="secondary" @click="showModal = false">Cancelar</BaseButton>
          <BaseButton :loading="formLoading" @click="submitQuote">
            {{ formLoading ? 'Guardando...' : 'Guardar' }}
          </BaseButton>
        </div>
      </template>
    </OrbitModal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { QuotesService } from '../services/quotes.service'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const router = useRouter()
const quotes = ref([])
const availableDeals = ref([])
const loading = ref(true)
const error = ref(null)
const searchQuery = ref('')

// Modal & Form State
const showModal = ref(false)
const formLoading = ref(false)
const formError = ref(null)

const form = reactive({
  deal_id: '',
  amount: '',
  status: 'draft',
  valid_until: ''
})

const resetForm = () => {
  form.deal_id = ''
  form.amount = ''
  form.status = 'draft'
  form.valid_until = ''
  formError.value = null
}

watch(showModal, (newVal) => {
  if (!newVal) resetForm()
})

const submitQuote = async () => {
  if (!form.deal_id) {
    formError.value = 'Debe seleccionar un negocio asociado.'
    return
  }
  if (!form.amount) {
    formError.value = 'El monto es obligatorio.'
    return
  }

  formLoading.value = true
  formError.value = null

  try {
    const { error: insertError } = await QuotesService.createQuote({
      deal_id: form.deal_id,
      amount: parseFloat(form.amount),
      status: form.status,
      valid_until: form.valid_until || null
    })

    if (insertError) throw insertError

    showModal.value = false
    resetForm()
    await fetchQuotes()
  } catch (err) {
    console.error('Error al crear cotización:', err)
    formError.value = err.message
  } finally {
    formLoading.value = false
  }
}

const filteredQuotes = computed(() => {
  if (!searchQuery.value) return quotes.value
  const query = searchQuery.value.toLowerCase()
  return quotes.value.filter(quote =>
    quote.quote_number?.toLowerCase().includes(query)
  )
})

const formatCurrency = (value) => {
  if (value == null) return '—'
  return '$' + new Intl.NumberFormat('es-CL').format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return '—'
  const date = new Date(dateString)
  // Fix timezone shift
  date.setMinutes(date.getMinutes() + date.getTimezoneOffset())
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(date)
}

const getStatusVariant = (status) => {
  const map = {
    'draft': 'default',
    'sent': 'primary',
    'accepted': 'success',
    'rejected': 'danger'
  }
  return map[status] || 'default'
}

const translateStatus = (status) => {
  const map = {
    'draft': 'Borrador',
    'sent': 'Enviada',
    'accepted': 'Aceptada',
    'rejected': 'Rechazada'
  }
  return map[status] || status
}

const fetchQuotes = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await QuotesService.getQuotes()

    if (err) throw err
    quotes.value = data || []
    
    // Also fetch deals for the modal
    const { data: dealsData } = await QuotesService.getDealsOptions()
      
    if (dealsData) {
      availableDeals.value = dealsData
    }
  } catch (err) {
    console.error('Error al cargar cotizaciones:', err)
    error.value = 'Ocurrió un error al cargar las cotizaciones.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchQuotes()
})
</script>
