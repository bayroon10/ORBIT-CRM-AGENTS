<template>
  <div class="flex flex-col h-full">
    <!-- ── Hero Header ── -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-white/10 shadow-2xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Prospectos</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-slate-50 mb-2 tracking-tight">Leads</h1>
          <p class="text-slate-400 text-sm">Gestión de prospectos comerciales.</p>
        </div>
        <BaseButton @click="showModal = true" size="lg">Nuevo Lead</BaseButton>
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
            placeholder="Buscar por nombre, email o empresa..."
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
        <p class="text-sm text-text-secondary">Cargando prospectos...</p>
      </div>

      <!-- Table -->
      <div v-else-if="filteredLeads.length > 0" class="overflow-x-auto overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-slate-950/50 backdrop-blur-md text-slate-400 font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-white/10">Nombre</th>
              <th class="px-6 py-4 border-b border-white/10">Contacto</th>
              <th class="px-6 py-4 border-b border-white/10 hidden sm:table-cell">Empresa</th>
              <th class="px-6 py-4 border-b border-white/10">Score IA</th>
              <th class="px-6 py-4 border-b border-white/10">Estado</th>
              <th class="px-6 py-4 border-b border-white/10 hidden md:table-cell">Fecha</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-white/10">
            <tr
              v-for="lead in filteredLeads"
              :key="lead.id"
              @click="router.push(`/leads/${lead.id}`)"
              class="hover:bg-slate-900/50 transition-colors cursor-pointer group"
            >
              <td class="px-6 py-4">
                <div class="font-medium text-slate-50">{{ lead.full_name }}</div>
              </td>
              <td class="px-6 py-4">
                <div class="text-slate-50">{{ lead.email || '—' }}</div>
                <div class="text-xs text-slate-400 mt-0.5">{{ lead.phone || '—' }}</div>
              </td>
              <td class="px-6 py-4 text-slate-400 hidden sm:table-cell">
                {{ lead.companies?.name || '—' }}
              </td>
              <td class="px-6 py-4">
                <div v-if="lead.ai_score != null" class="inline-flex items-center gap-1.5">
                  <svg class="w-3 h-3 text-primary-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.347.347a3.5 3.5 0 00-1.035 2.475V19a2 2 0 01-2 2h-1.5a2 2 0 01-2-2v-.189a3.5 3.5 0 00-1.036-2.474l-.347-.347z"/>
                  </svg>
                  <BaseBadge :variant="lead.ai_score >= 70 ? 'success' : lead.ai_score >= 40 ? 'warning' : 'danger'">
                    {{ lead.ai_score }}
                  </BaseBadge>
                </div>
                <div v-else class="text-xs text-slate-500 font-medium italic whitespace-nowrap">
                  Pendiente
                </div>
              </td>
              <td class="px-6 py-4">
                <BaseBadge :variant="getStatusVariant(lead.status)">
                  {{ formatStatus(lead.status) }}
                </BaseBadge>
              </td>
              <td class="px-6 py-4 text-slate-400 whitespace-nowrap hidden md:table-cell">
                {{ formatDate(lead.created_at) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-else class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState
          :title="searchQuery ? 'No hay resultados' : 'No hay leads registrados'"
          :description="searchQuery ? 'No se encontraron prospectos que coincidan con tu búsqueda.' : 'Crea tu primer prospecto comercial para empezar a gestionarlo.'"
        />
      </div>
    </BaseCard>

    <!-- ── Modal Nuevo Lead ── -->
    <OrbitModal v-model="showModal" title="Nuevo Lead">
      <form @submit.prevent="submitLead" class="space-y-4">

        <div v-if="formError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm flex items-start gap-2 border border-danger/20">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 shrink-0"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
          <span>{{ formError }}</span>
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Nombre completo *</label>
          <input
            v-model="form.full_name"
            type="text"
            required
            placeholder="Nombre completo"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Email</label>
          <input
            v-model="form.email"
            type="email"
            placeholder="correo@empresa.com"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Teléfono</label>
          <input
            v-model="form.phone"
            type="text"
            placeholder="+56 9 xxxx xxxx"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Estado</label>
          <select
            v-model="form.status"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          >
            <option value="nuevo">Nuevo</option>
            <option value="contactado">Contactado</option>
            <option value="calificado">Calificado</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Empresa</label>
          <input
            v-model="form.company"
            type="text"
            placeholder="Empresa (Opcional)"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Fuente</label>
          <input
            v-model="form.source"
            type="text"
            placeholder="Ej. LinkedIn, Web, Referido"
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1">Notas</label>
          <textarea
            v-model="form.notes"
            rows="3"
            placeholder="Información adicional del lead..."
            class="w-full border border-white/20 rounded-lg px-3 py-2 text-sm bg-slate-900/50 text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          ></textarea>
        </div>
      </form>

      <template #footer>
        <div class="flex justify-end gap-3">
          <BaseButton variant="secondary" @click="showModal = false">Cancelar</BaseButton>
          <BaseButton :loading="formLoading" @click="submitLead">
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
import { LeadsService } from '../services/leads.service'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const router = useRouter()
const leads = ref([])
const loading = ref(true)
const error = ref(null)
const searchQuery = ref('')

// Modal & Form State
const showModal = ref(false)
const formLoading = ref(false)
const formError = ref(null)

const form = reactive({
  full_name: '',
  email: '',
  phone: '',
  status: 'nuevo',
  company: '',
  source: '',
  notes: ''
})

const resetForm = () => {
  form.full_name = ''
  form.email = ''
  form.phone = ''
  form.status = 'nuevo'
  form.company = ''
  form.source = ''
  form.notes = ''
  formError.value = null
}

watch(showModal, (newVal) => {
  if (!newVal) resetForm()
})

const submitLead = async () => {
  if (!form.full_name.trim()) {
    formError.value = 'El nombre es obligatorio.'
    return
  }

  formLoading.value = true
  formError.value = null

  try {
    const { error: insertError } = await LeadsService.createLead({
      full_name: form.full_name.trim(),
      email: form.email.trim(),
      phone: form.phone.trim(),
      status: form.status,
      company: form.company.trim(),
      source: form.source.trim(),
      notes: form.notes.trim()
    })

    if (insertError) throw insertError

    showModal.value = false
    resetForm()
    await fetchLeads()
  } catch (err) {
    console.error('Error al crear lead:', err)
    formError.value = err.message
  } finally {
    formLoading.value = false
  }
}

const filteredLeads = computed(() => {
  if (!searchQuery.value) return leads.value
  const query = searchQuery.value.toLowerCase()
  return leads.value.filter(lead =>
    lead.full_name?.toLowerCase().includes(query) ||
    lead.email?.toLowerCase().includes(query) ||
    lead.companies?.name?.toLowerCase().includes(query)
  )
})

// Mapea status a variante de BaseBadge
const getStatusVariant = (status) => {
  const map = {
    nuevo:      'primary',
    contactado: 'warning',
    calificado: 'success',
  }
  return map[status] || 'default'
}

const formatStatus = (status) => {
  if (!status) return 'Desconocido'
  return status.charAt(0).toUpperCase() + status.slice(1)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(date)
}

const fetchLeads = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await LeadsService.getLeads()

    if (err) throw err
    leads.value = data || []
  } catch (err) {
    console.error('Error al cargar leads:', err)
    error.value = 'Ocurrió un error al cargar los leads desde Supabase.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchLeads()
})
</script>
