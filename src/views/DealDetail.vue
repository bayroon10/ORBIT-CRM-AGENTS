<template>
  <div class="h-full flex flex-col">
    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando negocio...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex flex-col items-center justify-center p-8">
      <div class="bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 text-center w-full max-w-md">
        <p class="mb-4">{{ error }}</p>
        <button @click="router.push('/deals')" class="bg-danger hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
          Volver a Negocios
        </button>
      </div>
    </div>

    <!-- Data State -->
    <template v-else-if="deal">
      <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
        <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-10 bg-blue-400 blur-3xl"></div>
        <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 class="text-3xl font-bold text-white">{{ deal.title }}</h1>
            <p class="text-blue-200 mt-1">{{ (deal.stage ? deal.stage.charAt(0).toUpperCase() + deal.stage.slice(1) : '') + ' · ' + (deal.leads?.full_name || deal.companies?.name || 'Sin contacto') }}</p>
          </div>
          <div class="flex items-center gap-3">
            <span v-if="deal.stalled" class="px-2.5 py-1 bg-danger text-white text-xs font-bold rounded-full">
              ESTANCADO
            </span>
            <span class="px-3 py-1 text-sm font-medium rounded-full" :class="getStageClass(deal.stage)">
              {{ deal.stage ? deal.stage.charAt(0).toUpperCase() + deal.stage.slice(1) : '' }}
            </span>
            <button 
              @click="router.push('/deals')"
              class="px-4 py-2 border border-gray-600 rounded-lg text-sm font-medium text-white hover:bg-white/10 transition-colors"
            >
              &larr; Volver
            </button>
          </div>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto pb-8 mt-6">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          <!-- COLUMNA IZQUIERDA -->
          <div class="lg:col-span-1">
            <div class="bg-white rounded-xl border border-border p-6 mb-6">
              <h2 class="font-semibold text-text-main mb-4 text-lg">Detalles</h2>
              <div class="space-y-0">
                
                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Valor</div>
                  <div class="text-sm text-success font-semibold">{{ formatCurrency(deal.value) }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Probabilidad</div>
                  <div class="text-sm text-text-main font-medium">{{ deal.probability != null ? deal.probability + '%' : '—' }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Cierre Esperado</div>
                  <div class="text-sm font-medium" :class="isPastDue(deal.expected_close) ? 'text-danger' : 'text-text-main'">
                    {{ formatDate(deal.expected_close) }}
                  </div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Contacto</div>
                  <div class="text-sm text-text-main font-medium">{{ deal.leads?.full_name || '—' }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Empresa</div>
                  <div class="text-sm text-text-main font-medium">{{ deal.companies?.name || '—' }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Creado</div>
                  <div class="text-sm text-text-main font-medium">{{ formatDate(deal.created_at) }}</div>
                </div>

                <div class="flex items-center justify-between py-3">
                  <div class="text-xs text-text-secondary uppercase tracking-wide">Actualizado</div>
                  <div class="text-sm text-text-main font-medium">{{ formatDate(deal.updated_at) }}</div>
                </div>

              </div>
            </div>
          </div>

          <!-- COLUMNA DERECHA -->
          <div class="lg:col-span-2 space-y-6">
            
            <!-- Tareas -->
            <div class="bg-white rounded-xl border border-border p-6 mb-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-text-main text-lg">Tareas</h2>
                <span class="bg-gray-100 text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">{{ tasks.length }}</span>
              </div>
              
              <div v-if="tasks.length === 0" class="text-center py-4">
                <p class="text-sm text-text-secondary">Sin tareas asociadas</p>
              </div>
              
              <div v-else class="space-y-0">
                <div v-for="task in tasks" :key="task.id" class="flex justify-between items-start gap-3 py-3 border-b border-border last:border-0 hover:bg-gray-50 transition-colors -mx-6 px-6">
                  <div>
                    <div class="font-medium text-sm text-text-main">{{ task.title }}</div>
                    <div class="text-xs mt-0.5" :class="(isPastDue(task.due_date) && task.status !== 'completada') ? 'text-danger' : 'text-text-secondary'">
                      Vence: {{ formatDate(task.due_date) }}
                    </div>
                  </div>
                  <div>
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full" :class="getTaskStatusClass(task.status)">
                      {{ task.status ? task.status.replace('_', ' ').charAt(0).toUpperCase() + task.status.replace('_', ' ').slice(1) : '' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Feed de Actividad -->
            <div class="bg-white rounded-xl border border-border p-6 mb-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-text-main text-lg">Actividad Reciente</h2>
                <span class="bg-gray-100 text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">{{ activities.length }}</span>
              </div>

              <div v-if="activities.length === 0" class="text-center py-4">
                <p class="text-sm text-text-secondary">Sin actividad registrada</p>
              </div>

              <div v-else class="space-y-0">
                <div v-for="activity in activities" :key="activity.id" class="flex gap-4 py-4 border-b border-border last:border-0">
                  <div class="w-8 h-8 rounded-full bg-surface border border-border flex items-center justify-center shrink-0 shadow-sm text-sm">
                    {{ getActivityIcon(activity.type) }}
                  </div>
                  <div class="flex-1 pt-1">
                    <p class="text-sm text-text-main">{{ activity.description }}</p>
                    <p class="text-xs text-text-secondary mt-1">{{ formatDate(activity.created_at) }}</p>
                  </div>
                </div>
              </div>
            </div>

          </div>

        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import OrbitPageHeader from '../components/OrbitPageHeader.vue'

const route = useRoute()
const router = useRouter()

const deal = ref(null)
const activities = ref([])
const tasks = ref([])
const loading = ref(true)
const error = ref(null)

const fetchDeal = async () => {
  loading.value = true
  error.value = null

  try {
    const { data, error: dealError } = await supabase
      .from('deals')
      .select('id, title, value, stage, probability, expected_close, stalled, created_at, updated_at, lead_id, company_id, leads(full_name), companies(name)')
      .eq('id', route.params.id)
      .single()

    if (dealError || !data) {
      error.value = 'No se encontró el negocio.'
      return
    }

    deal.value = data

    const [activitiesResponse, tasksResponse] = await Promise.all([
      supabase
        .from('activities')
        .select('id, type, description, created_at')
        .eq('deal_id', route.params.id)
        .order('created_at', { ascending: false })
        .limit(20),
      supabase
        .from('tasks')
        .select('id, title, status, due_date')
        .eq('deal_id', route.params.id)
        .order('due_date', { ascending: true })
    ])

    if (!activitiesResponse.error) {
      activities.value = activitiesResponse.data || []
    }
    
    if (!tasksResponse.error) {
      tasks.value = tasksResponse.data || []
    }

  } catch (err) {
    console.error('Error al cargar deal detail:', err)
    error.value = 'Ocurrió un error al cargar la información.'
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '—'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(date)
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '—'
  return '$' + new Intl.NumberFormat('es-CL', {
    maximumFractionDigits: 0
  }).format(value)
}

const isPastDue = (dateString) => {
  if (!dateString) return false
  const closeDate = new Date(dateString + 'T00:00:00')
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return closeDate < today
}

const getStageClass = (stage) => {
  const map = {
    'prospecto': 'bg-blue-100 text-blue-700',
    'cotizado': 'bg-yellow-100 text-yellow-700',
    'negociando': 'bg-orange-100 text-orange-700',
    'ganado': 'bg-green-100 text-green-700',
    'perdido': 'bg-red-100 text-red-700'
  }
  return map[stage] || 'bg-gray-100 text-gray-700'
}

const getTaskStatusClass = (status) => {
  const map = {
    'pendiente': 'bg-yellow-100 text-yellow-700',
    'en_progreso': 'bg-blue-100 text-blue-700',
    'completada': 'bg-green-100 text-green-700'
  }
  return map[status] || 'bg-gray-100 text-gray-700'
}

const getActivityIcon = (type) => {
  if (!type) return '💬'
  const t = type.toLowerCase()
  if (t.includes('nota')) return '📝'
  if (t.includes('llamada')) return '📞'
  if (t.includes('email') || t.includes('correo')) return '✉️'
  if (t.includes('reunion')) return '🤝'
  if (t.includes('webhook') || t.includes('sistema') || t.includes('cread')) return '⚙️'
  return '💬'
}

onMounted(() => {
  fetchDeal()
})
</script>
