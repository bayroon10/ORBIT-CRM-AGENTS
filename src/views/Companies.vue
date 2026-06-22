<template>
  <div class="flex flex-col h-full">
    <!-- ── Hero Header ── -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-primary/20 shadow-lg shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Directorio</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-text-main mb-2 tracking-tight">Empresas</h1>
          <p class="text-text-secondary text-sm">Gestión de empresas y clientes corporativos.</p>
        </div>
        <BaseButton @click="showModal = true" size="lg">Nueva Empresa</BaseButton>
      </div>
    </div>

    <!-- ── Error State ── -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0">
      {{ error }}
    </div>

    <!-- ── Table Card ── -->
    <BaseCard :padded="false" class="flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-border flex justify-between items-center shrink-0">
        <div class="relative w-72">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar por nombre o industria..."
            class="w-full pl-10 pr-4 py-2 bg-surface border border-border rounded-lg text-sm text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
          <div class="absolute left-3 top-2.5 text-text-muted">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando empresas...</p>
      </div>

      <!-- Table -->
      <div v-else-if="filteredCompanies.length > 0" class="overflow-x-auto overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-surface-container text-text-muted font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs">Empresa</th>
              <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs hidden sm:table-cell">Industria</th>
              <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs hidden sm:table-cell">Sitio Web</th>
              <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs hidden md:table-cell">Fecha Creación</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-border">
            <tr
              v-for="company in filteredCompanies"
              :key="company.id"
              @click="router.push(`/companies/${company.id}`)"
              class="hover:bg-surface-container/60 transition-colors cursor-pointer group"
            >
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-lg bg-surface-card flex items-center justify-center overflow-hidden border border-border text-primary-300 font-bold text-lg shrink-0">
                    {{ company.name.charAt(0).toUpperCase() }}
                  </div>
                  <div class="font-medium text-text-main group-hover:text-primary-300 transition-colors">{{ company.name }}</div>
                </div>
              </td>
              <td class="px-6 py-4 text-text-secondary hidden sm:table-cell">
                {{ company.industry || '—' }}
              </td>
              <td class="px-6 py-4 text-text-secondary hidden sm:table-cell">
                <a v-if="company.website" :href="formatUrl(company.website)" target="_blank" @click.stop class="text-primary-300 hover:underline">{{ company.website }}</a>
                <span v-else>—</span>
              </td>
              <td class="px-6 py-4 text-text-secondary whitespace-nowrap hidden md:table-cell">
                {{ formatDate(company.created_at) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-else class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState
          :title="searchQuery ? 'No hay resultados' : 'No hay empresas registradas'"
          :description="searchQuery ? 'No se encontraron empresas que coincidan con tu búsqueda.' : 'Registra tu primera empresa corporativa para asociarla a prospectos y negocios.'"
        />
      </div>
    </BaseCard>

    <!-- ── Modal Nueva Empresa ── -->
    <OrbitModal v-model="showModal" title="Nueva Empresa">
      <form @submit.prevent="submitCompany" class="space-y-4">

        <div v-if="formError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm flex items-start gap-2 border border-danger/20">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 shrink-0"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
          <span>{{ formError }}</span>
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Nombre de la Empresa *</label>
          <input
            v-model="form.name"
            type="text"
            required
            placeholder="Ej. Acme Corp"
            class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Industria</label>
          <input
            v-model="form.industry"
            type="text"
            placeholder="Ej. Tecnología, Finanzas"
            class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-text-main mb-1">Sitio Web</label>
          <input
            v-model="form.website"
            type="url"
            placeholder="https://ejemplo.com"
            class="w-full border border-border-strong rounded-lg px-3 py-2 text-sm bg-surface text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>
      </form>

      <template #footer>
        <div class="flex justify-end gap-3">
          <BaseButton variant="secondary" @click="showModal = false">Cancelar</BaseButton>
          <BaseButton :loading="formLoading" @click="submitCompany">
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
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const router = useRouter()
const companies = ref([])
const loading = ref(true)
const error = ref(null)
const searchQuery = ref('')

// Modal & Form State
const showModal = ref(false)
const formLoading = ref(false)
const formError = ref(null)

const form = reactive({
  name: '',
  industry: '',
  website: ''
})

const resetForm = () => {
  form.name = ''
  form.industry = ''
  form.website = ''
  formError.value = null
}

watch(showModal, (newVal) => {
  if (!newVal) resetForm()
})

const formatUrl = (url) => {
  if (!url) return '#'
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'https://' + url
  }
  return url
}

const submitCompany = async () => {
  if (!form.name.trim()) {
    formError.value = 'El nombre de la empresa es obligatorio.'
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

    const { error: insertError } = await supabase
      .from('companies')
      .insert({
        name: form.name.trim(),
        industry: form.industry.trim() || null,
        website: form.website.trim() || null,
        owner_id: user.id
      })

    if (insertError) throw insertError

    showModal.value = false
    resetForm()
    await fetchCompanies()
  } catch (err) {
    console.error('Error al crear empresa:', err)
    formError.value = err.message
  } finally {
    formLoading.value = false
  }
}

const filteredCompanies = computed(() => {
  if (!searchQuery.value) return companies.value
  const query = searchQuery.value.toLowerCase()
  return companies.value.filter(company =>
    company.name?.toLowerCase().includes(query) ||
    company.industry?.toLowerCase().includes(query)
  )
})

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(date)
}

const fetchCompanies = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('companies')
      .select('id, name, industry, website, created_at')
      .order('created_at', { ascending: false })

    if (err) throw err
    companies.value = data || []
  } catch (err) {
    console.error('Error al cargar empresas:', err)
    error.value = 'Ocurrió un error al cargar las empresas desde Supabase.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchCompanies()
})
</script>
