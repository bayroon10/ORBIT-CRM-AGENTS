<template>
  <div class="h-full flex flex-col">
    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando cotización...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex flex-col items-center justify-center p-8">
      <div class="bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 text-center w-full max-w-md">
        <p class="mb-4">{{ error }}</p>
        <BaseButton @click="router.push('/quotes')" variant="danger">
          Volver a Cotizaciones
        </BaseButton>
      </div>
    </div>

    <!-- Data State -->
    <template v-else-if="quote">
      <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 shadow-lg border border-primary/20 shrink-0">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
        <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-15 bg-primary blur-3xl"></div>
        <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 class="text-3xl font-bold text-text-main">{{ quote.quote_number }}</h1>
            <p class="text-text-secondary mt-1">Cotización · {{ quote.deals?.title || 'Sin negocio' }}</p>
          </div>
          <div class="flex space-x-3 items-center">
            <BaseBadge :variant="getStatusVariant(quote.status)" class="mr-2">
              {{ translateStatus(quote.status) }}
            </BaseBadge>
            <BaseButton
              variant="secondary"
              @click="showEditModal = true"
            >
              Editar
            </BaseButton>
            <BaseButton
              v-if="userRole === 'admin'"
              variant="danger"
              @click="showDeleteModal = true"
            >
              Eliminar
            </BaseButton>
            <button 
              @click="router.push('/quotes')"
              class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-text-secondary hover:text-text-main hover:bg-surface-card transition-colors"
            >
              &larr; Volver
            </button>
          </div>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto pb-8 px-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          
          <!-- COLUMNA IZQUIERDA -->
          <div class="space-y-6">
            <BaseCard>
              <h2 class="font-semibold text-text-main mb-4 text-lg">Detalles Comerciales</h2>
              <div class="space-y-0">
                
                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Monto</div>
                  <div class="text-lg text-success font-bold">{{ formatCurrency(quote.amount) }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Estado</div>
                  <div class="text-sm font-medium text-text-main">{{ translateStatus(quote.status) }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Válida Hasta</div>
                  <div class="text-sm font-medium" :class="isPastDue(quote.valid_until) ? 'text-danger' : 'text-text-main'">
                    {{ formatDate(quote.valid_until) }}
                  </div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Negocio</div>
                  <div class="text-sm text-text-main font-medium">
                    <router-link v-if="quote.deal_id" :to="`/deals/${quote.deal_id}`" class="text-primary-300 hover:underline">
                      {{ quote.deals?.title }}
                    </router-link>
                    <span v-else>—</span>
                  </div>
                </div>

                <div class="flex items-center justify-between py-3">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Creada</div>
                  <div class="text-sm text-text-main font-medium">{{ formatDate(quote.created_at) }}</div>
                </div>

              </div>
            </BaseCard>
          </div>

          <!-- COLUMNA DERECHA (vacia temporalmente) -->
          <div class="space-y-6">
          </div>

        </div>
      </div>

      <!-- Modal Editar Cotización -->
      <OrbitModal v-model="showEditModal" title="Editar Cotización">
        <form @submit.prevent="updateQuote" class="space-y-4">
          <div v-if="editError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm flex items-start gap-2 border border-danger/20">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 shrink-0"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
            <span>{{ editError }}</span>
          </div>

          <div class="bg-surface-card border border-border p-3 rounded-lg text-sm text-text-secondary mb-4">
            <svg class="inline-block w-4 h-4 mr-1 mb-0.5 text-primary-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            El número de cotización <span class="font-bold text-text-main">{{ quote.quote_number }}</span> no puede ser modificado.
          </div>

          <div>
            <label class="block text-sm font-medium text-text-main mb-1">Negocio Asociado (Deal) *</label>
            <select
              v-model="editForm.deal_id"
              required
              class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
            >
              <option v-for="deal in availableDeals" :key="deal.id" :value="deal.id">
                {{ deal.title }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-text-main mb-1">Monto *</label>
            <input v-model="editForm.amount" type="number" min="0" step="0.01" required class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all" />
          </div>

          <div>
            <label class="block text-sm font-medium text-text-main mb-1">Estado</label>
            <select v-model="editForm.status" class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all">
              <option value="draft">Borrador</option>
              <option value="sent">Enviada</option>
              <option value="accepted">Aceptada</option>
              <option value="rejected">Rechazada</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-text-main mb-1">Válida Hasta</label>
            <input v-model="editForm.valid_until" type="date" class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all" />
          </div>
        </form>
        <template #footer>
          <div class="flex justify-end gap-3">
            <BaseButton variant="ghost" @click="showEditModal = false">Cancelar</BaseButton>
            <BaseButton variant="primary" @click="updateQuote" :loading="editLoading">Guardar</BaseButton>
          </div>
        </template>
      </OrbitModal>

      <!-- Modal Eliminar Cotización -->
      <OrbitModal v-model="showDeleteModal" title="Eliminar Cotización">
        <div class="space-y-4">
          <div class="bg-danger/10 border border-danger/20 rounded-lg p-4">
            <h3 class="text-danger font-semibold mb-2">⚠ Acción irreversible</h3>
            <p class="text-sm text-text-secondary">
              Estás a punto de eliminar la cotización <span class="font-bold text-text-main">{{ quote.quote_number }}</span>. 
              Esta acción no se puede deshacer.
            </p>
          </div>
          <div v-if="deleteError" class="text-sm text-danger mt-2">{{ deleteError }}</div>
        </div>
        <template #footer>
          <div class="flex justify-end gap-3">
            <BaseButton variant="ghost" @click="showDeleteModal = false">Cancelar</BaseButton>
            <BaseButton variant="danger" @click="deleteQuote" :loading="deleteLoading">Eliminar Cotización</BaseButton>
          </div>
        </template>
      </OrbitModal>

    </template>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'
import OrbitModal from '../components/OrbitModal.vue'

const route = useRoute()
const router = useRouter()

const quote = ref(null)
const availableDeals = ref([])
const loading = ref(true)
const error = ref(null)

const userRole = ref('')

const showEditModal = ref(false)
const editLoading = ref(false)
const editError = ref(null)
const editForm = reactive({
  deal_id: '',
  amount: '',
  status: '',
  valid_until: ''
})

const showDeleteModal = ref(false)
const deleteLoading = ref(false)
const deleteError = ref(null)

const fetchQuoteData = async () => {
  loading.value = true
  error.value = null

  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single()
      if (profile) userRole.value = profile.role
    }

    const { data, error: fetchError } = await supabase
      .from('quotes')
      .select('*, deals(title)')
      .eq('id', route.params.id)
      .single()

    if (fetchError || !data) {
      error.value = 'No se encontró la cotización.'
      return
    }

    quote.value = data

    // Populate edit form
    editForm.deal_id = data.deal_id || ''
    editForm.amount = data.amount || 0
    editForm.status = data.status || 'draft'
    editForm.valid_until = data.valid_until || ''

    // Fetch deals for dropdown
    const { data: dealsData } = await supabase.from('deals').select('id, title').order('title', { ascending: true })
    if (dealsData) availableDeals.value = dealsData

  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const updateQuote = async () => {
  if (!editForm.deal_id) {
    editError.value = 'Debe seleccionar un negocio asociado.'
    return
  }

  editLoading.value = true
  editError.value = null

  try {
    const { error: updError } = await supabase
      .from('quotes')
      .update({
        deal_id: editForm.deal_id,
        amount: parseFloat(editForm.amount),
        status: editForm.status,
        valid_until: editForm.valid_until || null
      })
      .eq('id', route.params.id)

    if (updError) throw updError

    showEditModal.value = false
    await fetchQuoteData()
  } catch (err) {
    console.error('Error updating quote:', err)
    editError.value = 'Ocurrió un error al actualizar los datos.'
  } finally {
    editLoading.value = false
  }
}

const deleteQuote = async () => {
  deleteLoading.value = true
  deleteError.value = null

  try {
    const { error: delError } = await supabase
      .from('quotes')
      .delete()
      .eq('id', route.params.id)

    if (delError) throw delError

    showDeleteModal.value = false
    router.replace('/quotes')
  } catch (err) {
    console.error('Error deleting quote:', err)
    deleteError.value = 'Ocurrió un error al eliminar. ' + (err.message || '')
  } finally {
    deleteLoading.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '—'
  const date = new Date(dateString)
  date.setMinutes(date.getMinutes() + date.getTimezoneOffset())
  return new Intl.DateTimeFormat('es-CL', { dateStyle: 'medium' }).format(date)
}

const formatCurrency = (value) => {
  if (value == null) return '—'
  return '$' + new Intl.NumberFormat('es-CL', { maximumFractionDigits: 0 }).format(value)
}

const isPastDue = (dateString) => {
  if (!dateString) return false
  const closeDate = new Date(dateString + 'T00:00:00')
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return closeDate < today
}

const getStatusVariant = (status) => {
  const map = { 'draft': 'default', 'sent': 'primary', 'accepted': 'success', 'rejected': 'danger' }
  return map[status] || 'default'
}

const translateStatus = (status) => {
  const map = { 'draft': 'Borrador', 'sent': 'Enviada', 'accepted': 'Aceptada', 'rejected': 'Rechazada' }
  return map[status] || status
}

onMounted(() => {
  fetchQuoteData()
})
</script>
