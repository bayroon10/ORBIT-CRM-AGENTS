<template>
  <div class="h-full flex flex-col relative overflow-x-hidden">
    <OrbitPageHeader 
      title="Centro de Automatizaciones" 
      description="Gestiona las automatizaciones activas y revisa su historial de ejecución."
    />

    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex items-center justify-center">
      <div class="flex flex-col items-center gap-4">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando automatizaciones...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="mb-6 bg-danger/10 text-danger p-4 rounded-lg text-sm border border-danger/20 flex justify-between items-center">
      <span>{{ error }}</span>
      <button @click="error = null" class="text-danger hover:text-danger/80 focus:outline-none">×</button>
    </div>

    <!-- Empty State -->
    <div v-else-if="automations.length === 0" class="flex-1 flex flex-col justify-center">
      <OrbitEmptyState 
        title="Sin automatizaciones" 
        description="No hay automatizaciones configuradas en el sistema en este momento."
      >
        <template #icon>
          <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="9" y1="3" x2="9" y2="21"></line>
          </svg>
        </template>
      </OrbitEmptyState>
    </div>

    <!-- Data State -->
    <div v-else class="grid grid-cols-1 gap-4 pb-8">
      <BaseCard v-for="automation in automations" :key="automation.id" class="p-5 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div class="flex-1">
          <div class="flex items-center gap-3 mb-1.5">
            <h3 class="text-lg font-semibold text-slate-50">{{ automation.name }}</h3>
            <BaseBadge :variant="getStatusVariant(automation.last_run_status)">
              {{ automation.last_run_status || 'Sin ejecución' }}
            </BaseBadge>
          </div>
          <p class="text-sm text-slate-400 mb-2">{{ automation.description || 'Sin descripción' }}</p>
          <p class="text-xs text-slate-500">
            Última ejecución: {{ formatRelativeTime(automation.last_run_at) }}
          </p>
        </div>
        
        <div class="flex items-center gap-4 shrink-0">
          <BaseButton variant="default" @click="openHistory(automation)">
            Ver historial
          </BaseButton>
          
          <label class="relative inline-flex items-center cursor-pointer">
            <input 
              type="checkbox" 
              class="sr-only peer" 
              :checked="automation.is_active"
              @change.prevent="requestToggle(automation)"
            >
            <div class="w-11 h-6 bg-slate-900/50 border border-white/10 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-slate-300 after:border-slate-400 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-success peer-checked:border-success"></div>
          </label>
        </div>
      </BaseCard>
    </div>

    <!-- Modal Confirmación Toggle -->
    <OrbitModal v-model="showToggleModal" title="Confirmar cambio">
      <p class="text-sm text-slate-50 mb-4">
        ¿Estás seguro de que deseas {{ targetAutomation?.is_active ? 'desactivar' : 'activar' }} la automatización <strong>{{ targetAutomation?.name }}</strong>?
      </p>
      <template #footer>
        <div class="flex justify-end gap-3 w-full">
          <BaseButton variant="default" @click="showToggleModal = false" :disabled="toggling">Cancelar</BaseButton>
          <BaseButton :variant="targetAutomation?.is_active ? 'danger' : 'success'" @click="executeToggle" :disabled="toggling">
            {{ toggling ? 'Aplicando...' : (targetAutomation?.is_active ? 'Desactivar' : 'Activar') }}
          </BaseButton>
        </div>
      </template>
    </OrbitModal>

    <!-- Modal Historial -->
    <OrbitModal v-model="showHistoryModal" :title="`Historial: ${historyAutomation?.name}`">
      <div v-if="loadingHistory" class="py-12 flex justify-center">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary"></div>
      </div>
      <div v-else-if="historyError" class="bg-danger/10 text-danger p-3 rounded-lg text-sm border border-danger/20 mb-2">
        {{ historyError }}
      </div>
      <div v-else-if="historyLogs.length === 0" class="py-4">
        <OrbitEmptyState 
          title="Sin registros" 
          description="Esta automatización no tiene ejecuciones registradas aún."
        />
      </div>
      <div v-else class="space-y-4">
        <div v-for="log in historyLogs" :key="log.id" class="p-4 bg-slate-800/50 border border-white/10 rounded-lg text-sm">
          <div class="flex items-center justify-between mb-3 border-b border-white/10 pb-2">
            <BaseBadge :variant="getStatusVariant(log.status)">
              {{ log.status || 'Desconocido' }}
            </BaseBadge>
            <span class="text-xs text-slate-500">{{ formatDate(log.created_at) }}</span>
          </div>
          <div class="mt-2">
            <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1 block">Payload</span>
            <div class="bg-slate-900/50 rounded-md p-2 overflow-x-auto max-h-48 overflow-y-auto text-xs text-slate-50 border border-white/10">
              <pre class="font-mono m-0 whitespace-pre-wrap">{{ formatPayload(log.payload) }}</pre>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <div class="flex justify-end w-full">
          <BaseButton variant="default" @click="showHistoryModal = false">Cerrar</BaseButton>
        </div>
      </template>
    </OrbitModal>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import OrbitPageHeader from '../components/OrbitPageHeader.vue'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const automations = ref([])
const loading = ref(true)
const error = ref(null)

// Toggle State
const showToggleModal = ref(false)
const targetAutomation = ref(null)
const toggling = ref(false)

// History State
const showHistoryModal = ref(false)
const historyAutomation = ref(null)
const historyLogs = ref([])
const loadingHistory = ref(false)
const historyError = ref(null)

const fetchAutomations = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('automations')
      .select('id, name, description, is_active, config, last_run_at, last_run_status, created_at')
      .order('created_at', { ascending: true })
      
    if (err) throw err
    automations.value = data || []
  } catch (err) {
    console.error('Error fetching automations:', err)
    error.value = 'Error al cargar las automatizaciones.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchAutomations()
})

const getStatusVariant = (status) => {
  if (!status) return 'default'
  const lowerStatus = status.toLowerCase()
  if (lowerStatus === 'success' || lowerStatus === 'éxito') return 'success'
  if (lowerStatus === 'error' || lowerStatus === 'failed') return 'danger'
  if (lowerStatus === 'warning' || lowerStatus === 'pending') return 'warning'
  return 'primary'
}

const formatRelativeTime = (dateStr) => {
  if (!dateStr) return 'Nunca'
  const date = new Date(dateStr)
  const now = new Date()
  const diffMs = now - date
  const diffSec = Math.floor(diffMs / 1000)
  const diffMin = Math.floor(diffSec / 60)
  const diffHour = Math.floor(diffMin / 60)
  const diffDay = Math.floor(diffHour / 24)

  if (diffSec < 60) return 'hace un momento'
  if (diffMin < 60) return `hace ${diffMin}m`
  if (diffHour < 24) return `hace ${diffHour}h`
  if (diffDay < 7) return `hace ${diffDay}d`
  
  return new Intl.DateTimeFormat('es-CL', { dateStyle: 'short' }).format(date)
}

const formatDate = (dateStr) => {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'short',
    timeStyle: 'short'
  }).format(new Date(dateStr))
}

const requestToggle = (automation) => {
  targetAutomation.value = automation
  showToggleModal.value = true
}

const executeToggle = async () => {
  if (!targetAutomation.value) return
  
  toggling.value = true
  const newActiveState = !targetAutomation.value.is_active
  
  try {
    const { error: err } = await supabase
      .from('automations')
      .update({ is_active: newActiveState })
      .eq('id', targetAutomation.value.id)
      
    if (err) throw err
    
    // Update local state without full refetch to be efficient
    targetAutomation.value.is_active = newActiveState
    showToggleModal.value = false
  } catch (err) {
    console.error('Error toggling automation:', err)
    error.value = `Error al cambiar estado de ${targetAutomation.value.name}.`
    showToggleModal.value = false
  } finally {
    toggling.value = false
    targetAutomation.value = null
  }
}

const openHistory = async (automation) => {
  historyAutomation.value = automation
  showHistoryModal.value = true
  loadingHistory.value = true
  historyError.value = null
  historyLogs.value = []
  
  try {
    const { data, error: err } = await supabase
      .from('automation_logs')
      .select('id, status, payload, created_at')
      .eq('automation_id', automation.id)
      .order('created_at', { ascending: false })
      .limit(50)
      
    if (err) throw err
    historyLogs.value = data || []
  } catch (err) {
    console.error('Error fetching logs:', err)
    historyError.value = 'No se pudo cargar el historial de ejecución.'
  } finally {
    loadingHistory.value = false
  }
}

const formatPayload = (payload) => {
  if (payload === null || payload === undefined) return 'Sin datos (null)'
  try {
    return JSON.stringify(payload, null, 2)
  } catch (e) {
    return String(payload)
  }
}
</script>
