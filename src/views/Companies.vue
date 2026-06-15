<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10" style="background: radial-gradient(circle, #3b82f6, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">Directorio</span>
          </div>
          <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Empresas</h1>
          <p class="text-gray-400 text-sm">Gestiona tus relaciones corporativas y el flujo de ventas.</p>
        </div>
        <button class="bg-primary hover:bg-primary-variant btn-glow text-white px-5 py-2.5 rounded-lg text-sm font-medium transition-all flex items-center gap-2 shadow-sm">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="19" y1="8" x2="19" y2="14"></line><line x1="22" y1="11" x2="16" y2="11"></line></svg>
          Nueva Empresa
        </button>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 shrink-0">
      {{ error }}
    </div>

    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-gray-100 flex justify-between items-center shrink-0">
        <div class="flex items-center gap-4">
          <div class="relative w-72">
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="Buscar empresas..." 
              class="w-full pl-10 pr-4 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            />
            <div class="absolute left-3 top-2.5 text-text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            </div>
          </div>
          
          <div class="relative">
            <select 
              v-model="selectedIndustry"
              class="appearance-none bg-surface border border-border rounded-lg px-4 py-2 pr-10 text-sm text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary cursor-pointer transition-all"
            >
              <option value="">Industria: Todas</option>
              <option v-for="ind in uniqueIndustries" :key="ind" :value="ind">{{ ind }}</option>
            </select>
            <svg class="absolute right-3 top-2.5 pointer-events-none text-text-secondary" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
          </div>
        </div>

        <div class="text-sm text-text-secondary font-medium">
          Mostrando {{ filteredCompanies.length }} empresa(s)
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando empresas...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredCompanies.length === 0" class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState 
          :title="searchQuery || selectedIndustry ? 'No hay resultados' : 'No hay empresas registradas'" 
          :description="searchQuery || selectedIndustry ? 'No se encontraron empresas que coincidan con los filtros.' : 'Comienza agregando tu primera empresa al directorio.'"
        />
      </div>

      <!-- Data Table -->
      <div v-else class="overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-[#f0edef] text-text-secondary font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Empresa</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Industria</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Leads asociados</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Deals activos</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs">Fecha creación</th>
              <th class="px-6 py-4 border-b border-gray-100 uppercase tracking-wider text-xs text-center">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="company in filteredCompanies" :key="company.id" @click="openDetail(company)" class="hover:bg-primary/5 transition-colors cursor-pointer group">
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center overflow-hidden border border-border text-primary font-bold text-lg">
                    {{ company.name.charAt(0).toUpperCase() }}
                  </div>
                  <div>
                    <div class="font-medium text-text-main">{{ company.name }}</div>
                    <div class="text-xs text-text-secondary">{{ company.website || '—' }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 text-text-secondary">
                {{ company.industry || '—' }}
              </td>
              <td class="px-6 py-4">
                <span class="bg-secondary-fixed text-text-main px-2 py-1 rounded text-xs font-semibold">
                  {{ getCount(company.leads) }} Leads
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-1 font-semibold text-primary">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"></polyline><polyline points="16 7 22 7 22 13"></polyline></svg>
                  {{ getCount(company.deals) }} Deals
                </div>
              </td>
              <td class="px-6 py-4 text-text-secondary whitespace-nowrap">
                {{ formatDate(company.created_at) }}
              </td>
              <td class="px-6 py-4 text-center" @click.stop>
                <div class="relative inline-block text-left group/menu">
                  <button class="p-2 hover:bg-surface rounded-full transition-colors text-border group-hover:text-text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>
                  </button>
                  <!-- Popover menu placeholder -->
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Slide-in Panel Overlay -->
    <div 
      class="fixed inset-0 bg-gray-900/40 backdrop-blur-sm z-50 transition-opacity duration-300"
      :class="selectedCompany ? 'opacity-100' : 'opacity-0 pointer-events-none'"
      @click="selectedCompany = null"
    ></div>

    <!-- Slide-in Detail Panel -->
    <div 
      class="fixed top-0 right-0 h-full w-full sm:w-[400px] bg-white shadow-2xl z-[60] border-l border-gray-100 transition-transform duration-300 ease-in-out flex flex-col"
      :class="selectedCompany ? 'translate-x-0' : 'translate-x-full'"
    >
      <div v-if="selectedCompany" class="flex-1 flex flex-col overflow-hidden">
        <!-- Panel Header -->
        <div class="p-6 border-b border-gray-100 flex justify-between items-center bg-white z-10 shrink-0">
          <h2 class="text-xl font-bold text-text-main">Detalle de Empresa</h2>
          <button @click="selectedCompany = null" class="p-2 hover:bg-surface rounded-full transition-colors text-text-secondary">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>

        <!-- Panel Content -->
        <div class="p-6 overflow-y-auto flex-1 space-y-8">
          <!-- Basic Info -->
          <div class="flex flex-col items-center text-center">
            <div class="w-24 h-24 rounded-2xl bg-surface flex items-center justify-center mb-4 overflow-hidden shadow-sm border border-border text-primary font-bold text-4xl">
              {{ selectedCompany.name.charAt(0).toUpperCase() }}
            </div>
            <h3 class="text-2xl font-bold text-text-main">{{ selectedCompany.name }}</h3>
            <p class="text-primary font-semibold text-sm mt-1">{{ selectedCompany.industry || 'Sin industria especificada' }}</p>
          </div>

          <div class="grid grid-cols-2 gap-4 bg-surface p-4 rounded-xl">
            <div>
              <p class="text-xs font-semibold text-text-secondary uppercase mb-1">Website</p>
              <a v-if="selectedCompany.website" :href="'http://' + selectedCompany.website" target="_blank" class="text-primary text-sm font-medium flex items-center gap-1 hover:underline">
                {{ selectedCompany.website }}
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
              </a>
              <span v-else class="text-text-main text-sm">—</span>
            </div>
            <div>
              <p class="text-xs font-semibold text-text-secondary uppercase mb-1">Creación</p>
              <p class="text-text-main text-sm font-medium">{{ formatDate(selectedCompany.created_at) }}</p>
            </div>
          </div>

          <!-- Stats Overview -->
          <div class="space-y-4">
            <div class="p-4 rounded-xl border border-gray-100 shadow-sm flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-primary">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                </div>
                <div>
                  <p class="text-sm font-bold text-text-main">Leads Asociados</p>
                  <p class="text-xs text-text-secondary">Contactos en esta empresa</p>
                </div>
              </div>
              <span class="text-xl font-bold text-text-main">{{ getCount(selectedCompany.leads) }}</span>
            </div>

            <div class="p-4 rounded-xl border border-gray-100 shadow-sm flex items-center justify-between">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-lg bg-green-50 flex items-center justify-center text-success">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                </div>
                <div>
                  <p class="text-sm font-bold text-text-main">Deals Activos</p>
                  <p class="text-xs text-text-secondary">Negociaciones en curso</p>
                </div>
              </div>
              <span class="text-xl font-bold text-text-main">{{ getCount(selectedCompany.deals) }}</span>
            </div>
          </div>
        </div>
        
        <!-- Panel Footer -->
        <div class="p-6 border-t border-gray-100 bg-surface shrink-0">
          <button class="w-full border-2 border-primary text-primary py-2.5 rounded-lg text-sm font-semibold hover:bg-primary/5 transition-colors">
            Ver Expediente Completo
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'

const companies = ref([])
const loading = ref(true)
const error = ref(null)

const searchQuery = ref('')
const selectedIndustry = ref('')
const selectedCompany = ref(null)

const fetchCompanies = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('companies')
      .select('*, leads(count), deals(count)')
      .order('created_at', { ascending: false })
      
    if (err) throw err
    companies.value = data || []
  } catch (err) {
    console.error('Error fetching companies:', err)
    error.value = 'Ocurrió un error al cargar las empresas.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchCompanies()
})

const uniqueIndustries = computed(() => {
  const industries = companies.value.map(c => c.industry).filter(Boolean)
  return [...new Set(industries)].sort()
})

const filteredCompanies = computed(() => {
  return companies.value.filter(company => {
    const matchName = company.name?.toLowerCase().includes(searchQuery.value.toLowerCase()) || false
    const matchIndustry = !selectedIndustry.value || company.industry === selectedIndustry.value
    return matchName && matchIndustry
  })
})

const openDetail = (company) => {
  selectedCompany.value = company
}

const getCount = (relation) => {
  if (!relation) return 0
  if (Array.isArray(relation)) {
    return relation.length > 0 ? relation[0].count : 0
  }
  return relation.count || 0
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(new Date(dateString))
}
</script>
