<template>
  <div class="h-full flex flex-col">
    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando empresa...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex flex-col items-center justify-center p-8">
      <div class="bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 text-center w-full max-w-md">
        <p class="mb-4">{{ error }}</p>
        <BaseButton @click="router.push('/companies')" variant="danger">
          Volver a Empresas
        </BaseButton>
      </div>
    </div>

    <!-- Data State -->
    <template v-else-if="company">
      <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 shadow-2xl border border-white/10 shrink-0">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
        <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-15 bg-primary blur-3xl"></div>
        <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div class="flex items-center gap-4">
            <div class="w-16 h-16 rounded-2xl bg-slate-800/50 flex items-center justify-center overflow-hidden border border-white/10 text-slate-50 font-bold text-3xl shrink-0 shadow-inner">
              {{ company.name.charAt(0).toUpperCase() }}
            </div>
            <div>
              <h1 class="text-3xl font-bold text-slate-50">{{ company.name }}</h1>
              <p class="text-slate-400 mt-1">Empresa · {{ company.industry || 'Sin industria especificada' }}</p>
            </div>
          </div>
          <div class="flex space-x-3 items-center">
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
              @click="router.push('/companies')"
              class="px-4 py-2 border border-white/10 rounded-lg text-sm font-medium text-slate-400 hover:text-slate-50 hover:bg-slate-800/50 transition-colors"
            >
              &larr; Volver
            </button>
          </div>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto pb-8 px-6">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          <!-- COLUMNA IZQUIERDA -->
          <div class="lg:col-span-1 space-y-6">
            <BaseCard>
              <h2 class="font-semibold text-slate-50 mb-4 text-lg">Información de la Empresa</h2>
              <div class="space-y-0">
                
                <div class="flex items-center gap-3 py-3 border-b border-white/10">
                  <div class="w-8 flex justify-center text-slate-500">🏢</div>
                  <div>
                    <div class="text-xs text-slate-500 uppercase tracking-wide">Nombre</div>
                    <div class="text-sm text-slate-50 font-medium">{{ company.name }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-white/10">
                  <div class="w-8 flex justify-center text-slate-500">💼</div>
                  <div>
                    <div class="text-xs text-slate-500 uppercase tracking-wide">Industria</div>
                    <div class="text-sm text-slate-50 font-medium">{{ company.industry || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-white/10">
                  <div class="w-8 flex justify-center text-slate-500">🌐</div>
                  <div>
                    <div class="text-xs text-slate-500 uppercase tracking-wide">Sitio Web</div>
                    <div class="text-sm text-slate-50 font-medium">
                      <a v-if="company.website" :href="formatUrl(company.website)" target="_blank" class="text-primary-300 hover:underline">{{ company.website }}</a>
                      <span v-else>—</span>
                    </div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3">
                  <div class="w-8 flex justify-center text-slate-500">📅</div>
                  <div>
                    <div class="text-xs text-slate-500 uppercase tracking-wide">Creado</div>
                    <div class="text-sm text-slate-50 font-medium">{{ formatDate(company.created_at) }}</div>
                  </div>
                </div>

              </div>
            </BaseCard>
          </div>

          <!-- COLUMNA DERECHA -->
          <div class="lg:col-span-2 space-y-6">
            
            <!-- Leads Asociados -->
            <BaseCard>
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-slate-50 text-lg">Contactos (Leads)</h2>
                <span class="bg-slate-800/50 border border-white/10 text-slate-400 px-2.5 py-0.5 rounded-full text-xs font-medium">{{ leads.length }}</span>
              </div>
              
              <div v-if="leads.length === 0" class="text-center py-4">
                <p class="text-sm text-slate-400">Sin prospectos asociados</p>
              </div>
              
              <div v-else class="space-y-0">
                <div v-for="lead in leads" :key="lead.id" class="flex justify-between items-center py-3 border-b border-white/10 last:border-0 hover:bg-slate-800/50 transition-colors -mx-6 px-6 cursor-pointer" @click="router.push('/leads/' + lead.id)">
                  <div>
                    <div class="font-medium text-sm text-slate-50">{{ lead.full_name }}</div>
                    <div class="text-xs text-slate-400 mt-0.5">{{ lead.email || 'Sin email' }}</div>
                  </div>
                  <div class="flex items-center gap-4">
                    <BaseBadge :variant="getLeadStatusVariant(lead.status)">
                      {{ lead.status ? lead.status.charAt(0).toUpperCase() + lead.status.slice(1) : '' }}
                    </BaseBadge>
                  </div>
                </div>
              </div>
            </BaseCard>

            <!-- Negocios Asociados -->
            <BaseCard>
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-slate-50 text-lg">Negocios Activos</h2>
                <span class="bg-slate-800/50 border border-white/10 text-slate-400 px-2.5 py-0.5 rounded-full text-xs font-medium">{{ deals.length }}</span>
              </div>
              
              <div v-if="deals.length === 0" class="text-center py-4">
                <p class="text-sm text-slate-400">Sin negocios asociados</p>
              </div>
              
              <div v-else class="space-y-0">
                <div v-for="deal in deals" :key="deal.id" class="flex justify-between items-center py-3 border-b border-white/10 last:border-0 hover:bg-slate-800/50 transition-colors -mx-6 px-6 cursor-pointer" @click="router.push('/deals/' + deal.id)">
                  <div>
                    <div class="font-medium text-sm text-slate-50">{{ deal.title }}</div>
                    <div v-if="deal.expected_close" class="text-xs text-slate-400 mt-0.5">Cierre: {{ formatDate(deal.expected_close) }}</div>
                  </div>
                  <div class="flex items-center gap-4">
                    <BaseBadge :variant="getDealStageVariant(deal.stage)">
                      {{ deal.stage ? deal.stage.charAt(0).toUpperCase() + deal.stage.slice(1) : '' }}
                    </BaseBadge>
                    <span class="text-sm font-semibold text-success">{{ formatCurrency(deal.value) }}</span>
                  </div>
                </div>
              </div>
            </BaseCard>

          </div>

        </div>
      </div>

      <!-- Modal Editar Empresa -->
      <OrbitModal v-model="showEditModal" title="Editar Empresa">
        <form @submit.prevent="updateCompany" class="space-y-4">
          <div v-if="editError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm flex items-start gap-2 border border-danger/20">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 shrink-0"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
            <span>{{ editError }}</span>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-50 mb-1">Nombre *</label>
            <input v-model="editForm.name" type="text" required class="w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-3 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-50 mb-1">Industria</label>
            <input v-model="editForm.industry" type="text" class="w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-3 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all" />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-50 mb-1">Sitio Web</label>
            <input v-model="editForm.website" type="url" class="w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-3 py-2 text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all" />
          </div>
        </form>
        <template #footer>
          <div class="flex justify-end gap-3">
            <BaseButton variant="ghost" @click="showEditModal = false">Cancelar</BaseButton>
            <BaseButton variant="primary" @click="updateCompany" :loading="editLoading">Guardar</BaseButton>
          </div>
        </template>
      </OrbitModal>

      <!-- Modal Eliminar Empresa -->
      <OrbitModal v-model="showDeleteModal" title="Eliminar Empresa">
        <div class="space-y-4">
          <div class="bg-danger/10 border border-danger/20 rounded-lg p-4">
            <h3 class="text-danger font-semibold mb-2">⚠ Acción irreversible</h3>
            <p class="text-sm text-slate-400">
              Estás a punto de eliminar la empresa <span class="font-bold text-slate-50">{{ company.name }}</span>. 
              Esta acción no se puede deshacer. Los leads y negocios asociados podrían perder esta relación.
            </p>
          </div>
          <div v-if="deleteError" class="text-sm text-danger mt-2">{{ deleteError }}</div>
        </div>
        <template #footer>
          <div class="flex justify-end gap-3">
            <BaseButton variant="ghost" @click="showDeleteModal = false">Cancelar</BaseButton>
            <BaseButton variant="danger" @click="deleteCompany" :loading="deleteLoading">Eliminar Empresa</BaseButton>
          </div>
        </template>
      </OrbitModal>

    </template>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'
import OrbitModal from '../components/OrbitModal.vue'

const route = useRoute()
const router = useRouter()

const company = ref(null)
const leads = ref([])
const deals = ref([])
const loading = ref(true)
const error = ref(null)

const userRole = ref('')

const showEditModal = ref(false)
const editLoading = ref(false)
const editError = ref(null)
const editForm = reactive({
  name: '',
  industry: '',
  website: ''
})

const showDeleteModal = ref(false)
const deleteLoading = ref(false)
const deleteError = ref(null)

const fetchCompanyData = async () => {
  loading.value = true
  error.value = null

  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single()
      if (profile) userRole.value = profile.role
    }

    const { data, error: fetchError } = await supabase
      .from('companies')
      .select('*')
      .eq('id', route.params.id)
      .single()

    if (fetchError || !data) {
      error.value = 'No se encontró la empresa.'
      return
    }

    company.value = data

    // Populate edit form
    editForm.name = data.name
    editForm.industry = data.industry || ''
    editForm.website = data.website || ''

    // Fetch related records
    const [leadsResponse, dealsResponse] = await Promise.all([
      supabase.from('leads').select('id, full_name, email, status').eq('company_id', route.params.id).order('created_at', { ascending: false }),
      supabase.from('deals').select('id, title, value, stage, expected_close').eq('company_id', route.params.id).order('created_at', { ascending: false })
    ])

    if (!leadsResponse.error) leads.value = leadsResponse.data || []
    if (!dealsResponse.error) deals.value = dealsResponse.data || []

  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const updateCompany = async () => {
  if (!editForm.name.trim()) {
    editError.value = 'El nombre es obligatorio.'
    return
  }

  editLoading.value = true
  editError.value = null

  try {
    const { error: updError } = await supabase
      .from('companies')
      .update({
        name: editForm.name.trim(),
        industry: editForm.industry.trim() || null,
        website: editForm.website.trim() || null
      })
      .eq('id', route.params.id)

    if (updError) throw updError

    showEditModal.value = false
    await fetchCompanyData()
  } catch (err) {
    console.error('Error updating company:', err)
    editError.value = 'Ocurrió un error al actualizar los datos.'
  } finally {
    editLoading.value = false
  }
}

const deleteCompany = async () => {
  deleteLoading.value = true
  deleteError.value = null

  try {
    const { error: delError } = await supabase
      .from('companies')
      .delete()
      .eq('id', route.params.id)

    if (delError) throw delError

    showDeleteModal.value = false
    router.replace('/companies')
  } catch (err) {
    console.error('Error deleting company:', err)
    deleteError.value = 'Ocurrió un error al eliminar. ' + (err.message || '')
  } finally {
    deleteLoading.value = false
  }
}

const formatUrl = (url) => {
  if (!url) return '#'
  if (!url.startsWith('http://') && !url.startsWith('https://')) return 'https://' + url
  return url
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', { dateStyle: 'medium' }).format(date)
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '—'
  return '$' + new Intl.NumberFormat('es-CL', { maximumFractionDigits: 0 }).format(value)
}

const getLeadStatusVariant = (status) => {
  const map = { 'nuevo': 'primary', 'contactado': 'warning', 'calificado': 'success' }
  return map[status] || 'default'
}

const getDealStageVariant = (stage) => {
  const map = { 'prospecto': 'primary', 'cotizado': 'warning', 'negociando': 'danger', 'ganado': 'success', 'perdido': 'danger' }
  return map[stage] || 'default'
}

onMounted(() => {
  fetchCompanyData()
})
</script>
