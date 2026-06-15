<template>
  <div class="flex flex-col h-full">
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10" style="background: radial-gradient(circle, #3b82f6, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">Auditoría</span>
          </div>
          <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Feed de Actividad</h1>
          <p class="text-gray-400 text-sm">Auditoría global de acciones y eventos del sistema.</p>
        </div>
        <div class="text-sm text-white/80 bg-white/10 backdrop-blur-md px-3 py-1.5 rounded-md border border-white/20">
          Últimos 30 días
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 shrink-0">
      {{ error }}
    </div>

    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-gray-100 flex justify-between items-center shrink-0">
        <div class="relative w-80">
          <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Buscar por descripción, lead o negocio..." 
            class="w-full pl-10 pr-4 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
          />
          <div class="absolute left-3 top-2.5 text-text-secondary">
            <!-- Search Icon -->
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando historial...</p>
      </div>

      <!-- Timeline Feed -->
      <div v-else-if="filteredActivities.length > 0" class="overflow-y-auto flex-1 p-6">
        <div class="relative border-l border-gray-200 ml-3 space-y-8 pb-4">
          <div 
            v-for="act in filteredActivities" 
            :key="act.id" 
            class="relative pl-8"
          >
            <!-- Timeline Node Icon -->
            <div 
              class="absolute -left-3.5 top-1 h-7 w-7 rounded-full flex items-center justify-center border-2 border-white shadow-sm"
              :class="getIconClass(act.type)"
            >
              <component :is="getIconComponent(act.type)" class="w-3.5 h-3.5" />
            </div>

            <!-- Content Card -->
            <div class="bg-white border border-gray-100 rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow">
              <div class="flex justify-between items-start mb-2">
                <div class="flex items-center gap-2">
                  <span class="text-xs font-semibold uppercase tracking-wider" :class="getTextClass(act.type)">
                    {{ formatType(act.type) }}
                  </span>
                  <span class="text-[11px] text-gray-400">&bull;</span>
                  <span class="text-xs text-text-secondary">{{ formatDateTime(act.created_at) }}</span>
                </div>
              </div>
              
              <p class="text-sm text-text-main font-medium mb-3">
                {{ act.description }}
              </p>

              <!-- Relaciones -->
              <div class="flex flex-wrap gap-3 mt-3 pt-3 border-t border-gray-100">
                <!-- Deal -->
                <div v-if="act.deals || act.deal_id" class="flex items-center gap-1.5 text-xs text-text-secondary bg-surface px-2.5 py-1 rounded-md border border-border">
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
                  <span class="truncate max-w-[150px]" :class="{'italic': !act.deals}">
                    {{ act.deals?.title || 'Negocio privado' }}
                  </span>
                </div>
                <!-- Lead -->
                <div v-if="act.leads || act.lead_id" class="flex items-center gap-1.5 text-xs text-text-secondary bg-surface px-2.5 py-1 rounded-md border border-border">
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                  <span class="truncate max-w-[150px]" :class="{'italic': !act.leads}">
                    {{ act.leads?.full_name || 'Contacto privado' }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState 
          :title="searchQuery ? 'No hay coincidencias' : 'Feed vacío'" 
          :description="searchQuery ? 'Ninguna actividad coincide con tu búsqueda.' : 'No hay registros de actividad recientes en el sistema.'"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, h } from 'vue'
import { supabase } from '../lib/supabase'
import OrbitPageHeader from '../components/OrbitPageHeader.vue'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'

const activities = ref([])
const loading = ref(true)
const error = ref(null)
const searchQuery = ref('')

// Computed para filtrar el historial
const filteredActivities = computed(() => {
  if (!searchQuery.value) return activities.value
  
  const query = searchQuery.value.toLowerCase()
  return activities.value.filter(act => {
    return (
      act.description?.toLowerCase().includes(query) ||
      act.leads?.full_name?.toLowerCase().includes(query) ||
      act.deals?.title?.toLowerCase().includes(query)
    )
  })
})

// Mapeos visuales basados en el 'type'
const formatType = (type) => {
  if (!type) return 'Sistema'
  return type
}

const getIconClass = (type) => {
  const norm = type?.toLowerCase() || ''
  if (norm.includes('llamada') || norm.includes('call')) return 'bg-green-500 text-white'
  if (norm.includes('email') || norm.includes('correo')) return 'bg-blue-500 text-white'
  if (norm.includes('nota') || norm.includes('note')) return 'bg-yellow-500 text-white'
  if (norm.includes('reunion') || norm.includes('meeting')) return 'bg-purple-500 text-white'
  return 'bg-gray-400 text-white' // default/sistema
}

const getTextClass = (type) => {
  const norm = type?.toLowerCase() || ''
  if (norm.includes('llamada') || norm.includes('call')) return 'text-green-600'
  if (norm.includes('email') || norm.includes('correo')) return 'text-blue-600'
  if (norm.includes('nota') || norm.includes('note')) return 'text-yellow-600'
  if (norm.includes('reunion') || norm.includes('meeting')) return 'text-purple-600'
  return 'text-gray-500'
}

// Iconos SVG inline usando la función h de Vue
const getIconComponent = (type) => {
  const norm = type?.toLowerCase() || ''
  
  // Icono Llamada (Phone)
  if (norm.includes('llamada') || norm.includes('call')) {
    return () => h('svg', { xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", 'stroke-width': "2", 'stroke-linecap': "round", 'stroke-linejoin': "round" }, [
      h('path', { d: "M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" })
    ])
  }
  // Icono Email (Mail)
  if (norm.includes('email') || norm.includes('correo')) {
    return () => h('svg', { xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", 'stroke-width': "2", 'stroke-linecap': "round", 'stroke-linejoin': "round" }, [
      h('path', { d: "M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" }),
      h('polyline', { points: "22,6 12,13 2,6" })
    ])
  }
  // Icono Nota (File-text)
  if (norm.includes('nota') || norm.includes('note')) {
    return () => h('svg', { xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", 'stroke-width': "2", 'stroke-linecap': "round", 'stroke-linejoin': "round" }, [
      h('path', { d: "M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" }),
      h('polyline', { points: "14 2 14 8 20 8" }),
      h('line', { x1: "16", y1: "13", x2: "8", y2: "13" }),
      h('line', { x1: "16", y1: "17", x2: "8", y2: "17" }),
      h('polyline', { points: "10 9 9 9 8 9" })
    ])
  }
  // Icono Default (Activity)
  return () => h('svg', { xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", 'stroke-width': "2", 'stroke-linecap': "round", 'stroke-linejoin': "round" }, [
    h('polyline', { points: "22 12 18 12 15 21 9 3 6 12 2 12" })
  ])
}

const formatDateTime = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(date)
}

// Obtener datos
const fetchActivities = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('activities')
      .select(`
        id, 
        type, 
        description, 
        created_at, 
        lead_id,
        deal_id,
        leads(full_name),
        deals(title)
      `)
      .order('created_at', { ascending: false })
      .limit(100) // Límite razonable para el frontend
      
    if (err) throw err
    
    activities.value = data || []
  } catch (err) {
    console.error('Error al cargar actividades:', err)
    error.value = 'Ocurrió un error al cargar el feed de actividades.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchActivities()
})
</script>
