<template>
  <div class="h-full flex flex-col">
    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando negocio...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex flex-col items-center justify-center p-8">
      <div class="bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 text-center w-full max-w-md">
        <p class="mb-4">{{ error }}</p>
        <BaseButton @click="router.push('/deals')" variant="danger">
          Volver a Negocios
        </BaseButton>
      </div>
    </div>

    <!-- Data State -->
    <template v-else-if="deal">
      <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 shadow-lg border border-primary/20 shrink-0">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
        <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-15 bg-primary blur-3xl"></div>
        <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 class="text-3xl font-bold text-text-main">{{ deal.title }}</h1>
            <p class="text-text-secondary mt-1">{{ (deal.stage ? deal.stage.charAt(0).toUpperCase() + deal.stage.slice(1) : '') + ' · ' + (deal.leads?.full_name || deal.companies?.name || 'Sin contacto') }}</p>
          </div>
          <div class="flex items-center gap-3">
            <BaseBadge v-if="deal.ai_risk_score != null" :variant="getRiskVariant(deal.ai_risk_score)">
              Riesgo: {{ deal.ai_risk_score }}
            </BaseBadge>
            <BaseBadge :variant="getStageVariant(deal.stage)">
              {{ deal.stage ? deal.stage.charAt(0).toUpperCase() + deal.stage.slice(1) : '' }}
            </BaseBadge>
            <button 
              @click="router.push('/deals')"
              class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-text-secondary hover:text-text-main hover:bg-surface-card transition-colors"
            >
              &larr; Volver
            </button>
          </div>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto pb-8 mt-6 px-6">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          <!-- COLUMNA IZQUIERDA -->
          <div class="lg:col-span-1">
            <BaseCard class="mb-6">
              <h2 class="font-semibold text-text-main mb-4 text-lg">Detalles</h2>
              <div class="space-y-0">
                
                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Valor</div>
                  <div class="text-sm text-success font-semibold">{{ formatCurrency(deal.value) }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Probabilidad</div>
                  <div class="text-sm text-text-main font-medium">{{ deal.probability != null ? deal.probability + '%' : '—' }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Cierre Esperado</div>
                  <div class="text-sm font-medium" :class="isPastDue(deal.expected_close) ? 'text-danger' : 'text-text-main'">
                    {{ formatDate(deal.expected_close) }}
                  </div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Contacto</div>
                  <div class="text-sm text-text-main font-medium">{{ deal.leads?.full_name || '—' }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Empresa</div>
                  <div class="text-sm text-text-main font-medium">{{ deal.companies?.name || '—' }}</div>
                </div>

                <div class="flex items-center justify-between py-3 border-b border-border">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Creado</div>
                  <div class="text-sm text-text-main font-medium">{{ formatDate(deal.created_at) }}</div>
                </div>

                <div class="flex items-center justify-between py-3">
                  <div class="text-xs text-text-muted uppercase tracking-wide">Actualizado</div>
                  <div class="text-sm text-text-main font-medium">{{ formatDate(deal.updated_at) }}</div>
                </div>

              </div>
            </BaseCard>
          </div>

          <!-- COLUMNA DERECHA -->
          <div class="lg:col-span-2 space-y-6">
            
            <!-- Deal Health (AI Panel) -->
            <BaseCard :padded="false" class="bg-gradient-to-br from-surface-card to-surface border-border overflow-hidden relative">
              <div class="absolute top-0 right-0 w-32 h-32 bg-primary/10 rounded-full blur-3xl -mr-10 -mt-10 pointer-events-none"></div>
              
              <div class="p-6">
                <div class="flex justify-between items-start mb-4 relative z-10">
                  <div class="flex items-center gap-2">
                    <svg class="w-5 h-5 text-primary-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                    <h2 class="font-bold text-text-main text-lg tracking-wide">Deal Health</h2>
                  </div>
                  <BaseBadge v-if="deal.ai_risk_score != null" :variant="getRiskVariant(deal.ai_risk_score)">
                    Score: {{ deal.ai_risk_score }}
                  </BaseBadge>
                  <BaseBadge v-else variant="default">
                    Pendiente
                  </BaseBadge>
                </div>
                
                <div class="relative z-10">
                  <template v-if="deal.ai_risk_score != null">
                    <p class="text-sm text-text-main leading-relaxed font-medium mb-3">
                      {{ deal.ai_risk_factors || 'No se detectaron factores de riesgo críticos.' }}
                    </p>
                    <div class="text-[11px] text-text-muted flex items-center gap-1.5">
                      <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      Analizado: {{ formatDateTime(deal.ai_analyzed_at) }}
                    </div>
                  </template>
                  <template v-else>
                    <p class="text-sm text-text-secondary leading-relaxed italic">
                      El agente aún no ha evaluado el riesgo de esta negociación. Se procesará en el próximo ciclo nocturno.
                    </p>
                  </template>
                </div>
              </div>
            </BaseCard>

            <!-- Tareas -->
            <BaseCard class="mb-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-text-main text-lg">Tareas</h2>
                <span class="bg-surface-card border border-border text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">{{ tasks.length }}</span>
              </div>
              
              <div v-if="tasks.length === 0" class="text-center py-4">
                <p class="text-sm text-text-secondary">Sin tareas asociadas</p>
              </div>
              
              <div v-else class="space-y-0">
                <div v-for="task in tasks" :key="task.id" class="flex justify-between items-start gap-3 py-3 border-b border-border last:border-0 hover:bg-surface-card transition-colors -mx-6 px-6">
                  <div>
                    <div class="font-medium text-sm text-text-main">{{ task.title }}</div>
                    <div class="text-xs mt-0.5" :class="(isPastDue(task.due_date) && task.status !== 'completada') ? 'text-danger' : 'text-text-secondary'">
                      Vence: {{ formatDate(task.due_date) }}
                    </div>
                  </div>
                  <div>
                    <BaseBadge :variant="getTaskStatusVariant(task.status)">
                      {{ task.status ? task.status.replace('_', ' ').charAt(0).toUpperCase() + task.status.replace('_', ' ').slice(1) : '' }}
                    </BaseBadge>
                  </div>
                </div>
              </div>
            </BaseCard>

            <!-- Feed de Actividad -->
            <BaseCard class="mb-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-text-main text-lg">Actividad Reciente</h2>
                <span class="bg-surface-card border border-border text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">{{ activities.length }}</span>
              </div>

              <div v-if="activities.length === 0" class="text-center py-4">
                <p class="text-sm text-text-secondary">Sin actividad registrada</p>
              </div>

              <div v-else class="space-y-0">
                <div v-for="activity in activities" :key="activity.id" class="flex gap-4 py-4 border-b border-border last:border-0">
                  <div class="w-8 h-8 rounded-full bg-surface-container border border-border flex items-center justify-center shrink-0 shadow-sm text-sm">
                    {{ getActivityIcon(activity.type) }}
                  </div>
                  <div class="flex-1 pt-1">
                    <p class="text-sm text-text-main">{{ activity.description }}</p>
                    <p class="text-xs text-text-secondary mt-1">{{ formatDate(activity.created_at) }}</p>
                  </div>
                </div>
              </div>
            </BaseCard>

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
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

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
      .select('id, title, value, stage, probability, expected_close, stalled, ai_risk_score, ai_risk_factors, ai_analyzed_at, created_at, updated_at, lead_id, company_id, leads(full_name), companies(name)')
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

const formatDateTime = (dateString) => {
  if (!dateString) return '—'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(date)
}

const getRiskVariant = (score) => {
  if (score >= 75) return 'danger'
  if (score >= 40) return 'warning'
  return 'success'
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

const getStageVariant = (stage) => {
  const map = {
    'prospecto': 'primary',
    'cotizado': 'warning',
    'negociando': 'danger', // usando danger por ser anaranjado
    'ganado': 'success',
    'perdido': 'danger'
  }
  return map[stage] || 'default'
}

const getTaskStatusVariant = (status) => {
  const map = {
    'pendiente': 'warning',
    'en_progreso': 'primary',
    'completada': 'success'
  }
  return map[status] || 'default'
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
