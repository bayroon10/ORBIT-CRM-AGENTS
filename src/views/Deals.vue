<template>
  <div class="h-full flex flex-col">
    <!-- ── Hero Header ── -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-primary/20 shadow-lg shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Pipeline</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-text-main mb-2 tracking-tight">Negocios</h1>
          <p class="text-text-secondary text-sm">Pipeline de ventas y gestión de oportunidades.</p>
        </div>
        <BaseButton @click="showModal = true" size="lg">Nuevo Negocio</BaseButton>
      </div>
    </div>

    <!-- ── Error State ── -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0">
      {{ error }}
    </div>

    <!-- ── Filtros / Buscador ── -->
    <div class="mb-6 flex justify-between items-center shrink-0">
      <div class="relative w-80">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar negocio, empresa o lead..."
          class="w-full pl-10 pr-4 py-2 bg-surface-card border border-border rounded-lg text-sm text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
        />
        <div class="absolute left-3 top-2.5 text-text-muted">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </div>
      </div>
    </div>

    <!-- ── Loading State ── -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando pipeline...</p>
    </div>

    <!-- ── Kanban Board ── -->
    <div v-else-if="deals.length > 0" class="flex-1 overflow-x-auto pb-4">
      <div class="flex gap-5 h-full min-w-max items-start">

        <!-- Column -->
        <div
          v-for="column in kanbanColumns"
          :key="column.id"
          class="kanban-column w-72 flex flex-col max-h-full bg-surface-container rounded-xl border border-border shrink-0 overflow-hidden"
        >
          <!-- Column Header -->
          <div class="p-4 border-b border-border bg-surface shrink-0 flex justify-between items-center">
            <h3 class="font-semibold text-text-main capitalize text-sm">{{ column.title }}</h3>
            <BaseBadge variant="muted">{{ getDealsByStage(column.id).length }}</BaseBadge>
          </div>

          <!-- Column Body (Scrollable) -->
          <div class="flex-1 overflow-y-auto p-3 space-y-3">
            <div
              v-for="deal in getDealsByStage(column.id)"
              :key="deal.id"
              @click="router.push(`/deals/${deal.id}`)"
              class="deal-card bg-surface-card p-4 rounded-xl border border-border cursor-pointer group relative"
            >
              <!-- AI Risk Indicator -->
              <div v-if="deal.ai_risk_score != null" class="absolute top-0 right-0 -mt-2 -mr-2 z-10 flex">
                <BaseBadge :variant="getRiskVariant(deal.ai_risk_score)" size="sm">
                  Riesgo: {{ deal.ai_risk_score }}
                </BaseBadge>
              </div>

              <!-- Deal Title -->
              <h4 class="font-medium text-text-main text-sm mb-2 group-hover:text-primary-300 transition-colors line-clamp-2">
                {{ deal.title }}
              </h4>

              <!-- Value & Probability -->
              <div class="flex items-center justify-between mb-3">
                <span class="font-semibold text-success text-sm">{{ formatCurrency(deal.value) }}</span>
                <span v-if="deal.probability !== null" class="text-xs font-medium px-2 py-0.5 bg-surface border border-border rounded-md text-text-secondary">
                  {{ deal.probability }}%
                </span>
              </div>

              <!-- Relations -->
              <div class="space-y-1.5">
                <div v-if="deal.companies || deal.company_id" class="flex items-center gap-1.5 text-xs text-text-secondary">
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><rect x="9" y="9" width="6" height="6"></rect><line x1="9" y1="1" x2="9" y2="4"></line><line x1="15" y1="1" x2="15" y2="4"></line><line x1="9" y1="20" x2="9" y2="23"></line><line x1="15" y1="20" x2="15" y2="23"></line><line x1="20" y1="9" x2="23" y2="9"></line><line x1="20" y1="14" x2="23" y2="14"></line><line x1="1" y1="9" x2="4" y2="9"></line><line x1="1" y1="14" x2="4" y2="14"></line></svg>
                  <span class="truncate" :class="{'italic': !deal.companies}">{{ deal.companies?.name || 'Empresa privada' }}</span>
                </div>

                <div v-if="deal.leads || deal.lead_id" class="flex items-center gap-1.5 text-xs text-text-secondary">
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                  <span class="truncate" :class="{'italic': !deal.leads}">{{ deal.leads?.full_name || 'Contacto privado' }}</span>
                </div>
              </div>

              <!-- Expected Close -->
              <div v-if="deal.expected_close" class="mt-3 pt-3 border-t border-border flex items-center justify-between text-[11px] text-text-muted">
                <span>Cierre esp.</span>
                <span :class="{'text-danger font-medium': isPastDue(deal.expected_close)}">
                  {{ formatDate(deal.expected_close) }}
                </span>
              </div>
            </div>

            <!-- Empty Column State -->
            <div v-if="getDealsByStage(column.id).length === 0" class="text-center py-6">
              <p class="text-xs text-text-muted font-medium">Sin negocios</p>
            </div>
          </div>

          <!-- Column Total -->
          <div class="p-3 bg-surface border-t border-border shrink-0">
            <div class="flex justify-between items-center text-xs text-text-secondary font-medium">
              <span>Total Estimado</span>
              <span class="text-text-main font-semibold">{{ formatCurrency(getColumnTotal(column.id)) }}</span>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- ── Global Empty State ── -->
    <div v-else class="flex-1 flex flex-col justify-center pb-20">
      <OrbitEmptyState
        :title="searchQuery ? 'No hay resultados' : 'Pipeline vacío'"
        :description="searchQuery ? 'Ningún negocio coincide con tu búsqueda.' : 'Crea tu primera oportunidad comercial para empezar a vender.'"
      />
    </div>

    <!-- ── Modal Nuevo Negocio ── -->
    <OrbitModal v-model="showModal" title="Nuevo Negocio">
      <form @submit.prevent="submitDeal" class="space-y-4">

        <div v-if="formError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm flex items-start gap-2 border border-danger/20">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 shrink-0"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
          <span>{{ formError }}</span>
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Nombre del negocio *</label>
          <input
            v-model="form.title"
            type="text"
            required
            placeholder="Nombre del negocio"
            class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Valor</label>
          <div class="relative">
            <span class="absolute left-3 top-2 text-text-muted font-medium">$</span>
            <input
              v-model="form.value"
              type="number"
              min="0"
              placeholder="0"
              class="w-full pl-7 pr-3 py-2 border border-border-strong rounded-lg text-sm bg-surface text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
            />
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Etapa</label>
          <select
            v-model="form.stage"
            class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          >
            <option value="prospecto">Prospecto</option>
            <option value="cotizado">Cotizado</option>
            <option value="negociando">Negociando</option>
            <option value="ganado">Ganado</option>
            <option value="perdido">Perdido</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Cierre esperado</label>
          <input
            v-model="form.expected_close"
            type="date"
            class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>
      </form>

      <template #footer>
        <div class="flex justify-end gap-3">
          <BaseButton variant="secondary" @click="showModal = false">Cancelar</BaseButton>
          <BaseButton :loading="formLoading" @click="submitDeal">
            {{ formLoading ? 'Guardando...' : 'Guardar' }}
          </BaseButton>
        </div>
      </template>
    </OrbitModal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch, nextTick } from 'vue'
import { gsap } from 'gsap'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const router = useRouter()
const deals = ref([])
const loading = ref(true)
const error = ref(null)
const searchQuery = ref('')

// Modal & Form State
const showModal = ref(false)
const formLoading = ref(false)
const formError = ref(null)

const form = reactive({
  title: '',
  value: 0,
  stage: 'prospecto',
  expected_close: ''
})

const resetForm = () => {
  form.title = ''
  form.value = 0
  form.stage = 'prospecto'
  form.expected_close = ''
  formError.value = null
}

watch(showModal, (newVal) => {
  if (!newVal) resetForm()
})

const submitDeal = async () => {
  if (!form.title.trim()) {
    formError.value = 'El título es obligatorio.'
    return
  }

  formLoading.value = true
  formError.value = null

  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      formError.value = 'Sesión no válida.'
      return
    }

    const payload = {
      title: form.title.trim(),
      value: Number(form.value) || 0,
      stage: form.stage,
      owner_id: user.id
    }

    if (form.expected_close) {
      payload.expected_close = form.expected_close
    }

    const { error: insertError } = await supabase
      .from('deals')
      .insert(payload)

    if (insertError) throw insertError

    showModal.value = false
    resetForm()
    await fetchDeals()
  } catch (err) {
    console.error('Error al crear negocio:', err)
    formError.value = err.message
  } finally {
    formLoading.value = false
  }
}

// Definición de las columnas del Kanban
const kanbanColumns = [
  { id: 'prospecto',  title: 'Prospecto' },
  { id: 'cotizado',   title: 'Cotizado' },
  { id: 'negociando', title: 'Negociando' },
  { id: 'ganado',     title: 'Ganado' },
  { id: 'perdido',    title: 'Perdido' },
]

const filteredDeals = computed(() => {
  if (!searchQuery.value) return deals.value
  const query = searchQuery.value.toLowerCase()
  return deals.value.filter(deal =>
    deal.title?.toLowerCase().includes(query) ||
    deal.companies?.name?.toLowerCase().includes(query) ||
    deal.leads?.full_name?.toLowerCase().includes(query)
  )
})

const getDealsByStage = (stageId) => filteredDeals.value.filter(deal => deal.stage === stageId)
const getColumnTotal = (stageId) => getDealsByStage(stageId).reduce((sum, deal) => sum + Number(deal.value || 0), 0)

const formatCurrency = (value) => {
  if (!value && value !== 0) return '—'
  return '$' + new Intl.NumberFormat('es-CL', { maximumFractionDigits: 0 }).format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString + 'T00:00:00')
  return new Intl.DateTimeFormat('es-CL', { dateStyle: 'short' }).format(date)
}

const isPastDue = (dateString) => {
  if (!dateString) return false
  const closeDate = new Date(dateString + 'T00:00:00')
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return closeDate < today
}

// Mapea risk score a variante de BaseBadge
const getRiskVariant = (score) => {
  if (score >= 75) return 'danger'
  if (score >= 40) return 'warning'
  return 'success'
}

const fetchDeals = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('deals')
      .select(`
        id,
        title,
        value,
        stage,
        probability,
        expected_close,
        stalled,
        ai_risk_score,
        ai_risk_factors,
        ai_analyzed_at,
        created_at,
        lead_id,
        company_id,
        leads(full_name),
        companies(name)
      `)
      .order('updated_at', { ascending: false })

    if (err) throw err

    deals.value = data || []
  } catch (err) {
    console.error('Error al cargar deals:', err)
    error.value = 'Ocurrió un error al cargar el pipeline de negocios.'
  } finally {
    loading.value = false
  }
}

// Animar Kanban sólo cuando los elementos ya están en el DOM
// (v-else-if="deals.length > 0" hace que existan sólo tras loading=false)
watch(deals, async (newDeals) => {
  if (!newDeals?.length) return
  await nextTick()
  gsap.fromTo('.kanban-column',
    { opacity: 0, y: 40 },
    { opacity: 1, y: 0, duration: 0.5, stagger: 0.08, ease: 'power3.out' }
  )
  gsap.fromTo('.deal-card',
    { opacity: 0, scale: 0.92 },
    { opacity: 1, scale: 1, duration: 0.4, stagger: 0.05, delay: 0.2, ease: 'back.out(1.4)' }
  )
})

onMounted(() => {
  fetchDeals()
})
</script>
