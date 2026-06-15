<template>
  <div class="h-full flex flex-col">
    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando prospecto...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex flex-col items-center justify-center p-8">
      <div class="bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 text-center w-full max-w-md">
        <p class="mb-4">{{ error }}</p>
        <button @click="router.push('/leads')" class="bg-danger hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
          Volver a Leads
        </button>
      </div>
    </div>

    <!-- Data State -->
    <template v-else-if="lead">
      <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
        <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-10 bg-blue-400 blur-3xl"></div>
        <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 class="text-3xl font-bold text-white">{{ lead.full_name }}</h1>
            <p class="text-blue-200 mt-1">Prospecto · {{ lead.companies?.name || 'Sin empresa' }}</p>
          </div>
          <div class="flex space-x-3">
            <button 
              @click="router.push('/leads')"
              class="px-4 py-2 border border-gray-600 rounded-lg text-sm font-medium text-white hover:bg-white/10 transition-colors"
            >
              &larr; Volver
            </button>
          </div>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto pb-8">
        
        <!-- Panel Sales Intelligence — siempre visible cuando hay lead -->
        <div class="mx-6 mb-6 animate-fadeInUp">

          <!-- ESTADO: análisis disponible -->
          <div v-if="lead.ai_score"
               class="rounded-2xl border border-border bg-white shadow-sm overflow-hidden">

            <!-- Banda de acento superior con color dinámico según score -->
            <div class="h-1 w-full"
                 :class="getScoreAccentClass(lead.ai_score)"></div>

            <div class="p-5">
              <!-- Header -->
              <div class="flex items-center justify-between mb-5">
                <div class="flex items-center gap-2">
                  <!-- Ícono sparkle / IA -->
                  <div class="w-7 h-7 rounded-lg bg-primary/10 flex items-center justify-center">
                    <svg class="w-4 h-4 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round"
                        d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.347.347a3.5 3.5 0 00-1.035 2.475V19a2 2 0 01-2 2h-1.5a2 2 0 01-2-2v-.189a3.5 3.5 0 00-1.036-2.474l-.347-.347z"/>
                    </svg>
                  </div>
                  <span class="text-sm font-semibold text-text-main">Sales Intelligence</span>
                </div>
                <!-- Fecha de análisis -->
                <div class="flex items-center gap-1.5 text-xs text-text-secondary">
                  <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <polyline points="12 6 12 12 16 14"/>
                  </svg>
                  Analizado {{ formatDate(lead.ai_analyzed_at) }}
                </div>
              </div>

              <!-- Score + Categoría: row principal -->
              <div class="flex items-center gap-5 mb-5">

                <!-- Score hero -->
                <div class="flex flex-col items-center justify-center w-20 h-20 rounded-2xl shadow-sm border shrink-0"
                     :class="getScoreBgClass(lead.ai_score)">
                  <span class="text-3xl font-bold leading-none" :class="getScoreTextClass(lead.ai_score)">
                    {{ lead.ai_score }}
                  </span>
                  <span class="text-xs font-medium mt-0.5" :class="getScoreTextClass(lead.ai_score)">
                    Potencial
                  </span>
                </div>

                <!-- Separador + Categoría + descripción -->
                <div class="flex-1">
                  <!-- Badge de categoría sin emojis -->
                  <div class="flex items-center gap-2 mb-2">
                    <!-- Ícono de categoría SVG inline -->
                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-semibold border"
                          :class="getCategoryClass(lead.ai_category)">
                      <!-- Hot -->
                      <svg v-if="lead.ai_category === 'Hot'" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z"/>
                      </svg>
                      <!-- Warm -->
                      <svg v-else-if="lead.ai_category === 'Warm'" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="5"/>
                        <line x1="12" y1="1" x2="12" y2="3"/>
                        <line x1="12" y1="21" x2="12" y2="23"/>
                        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                        <line x1="1" y1="12" x2="3" y2="12"/>
                        <line x1="21" y1="12" x2="23" y2="12"/>
                        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                      </svg>
                      <!-- Cold -->
                      <svg v-else class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <line x1="12" y1="2" x2="12" y2="22"/>
                        <path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>
                      </svg>
                      {{ lead.ai_category }}
                    </span>
                  </div>
                  <p class="text-xs text-text-secondary leading-relaxed">
                    {{ getCategoryDescription(lead.ai_category) }}
                  </p>
                </div>

              </div>

              <!-- Divisor -->
              <div class="border-t border-border mb-4"></div>

              <!-- Perfil del Prospecto (ex Resumen) -->
              <div class="mb-4">
                <p class="text-xs font-semibold text-text-secondary uppercase tracking-wider mb-1.5">
                  Perfil del Prospecto
                </p>
                <p class="text-sm text-text-main leading-relaxed">{{ lead.ai_summary }}</p>
              </div>

              <!-- Acción Recomendada (ex Próximo paso) -->
              <div class="rounded-xl bg-primary/5 border border-primary/15 px-4 py-3">
                <div class="flex items-center gap-2 mb-1">
                  <!-- Check icon -->
                  <svg class="w-3.5 h-3.5 text-primary shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                    <polyline points="20 6 9 17 4 12"/>
                  </svg>
                  <p class="text-xs font-semibold text-primary uppercase tracking-wider">
                    Acción Recomendada
                  </p>
                </div>
                <p class="text-sm font-medium text-text-main pl-5">{{ lead.ai_next_step }}</p>
              </div>
            </div>
          </div>

          <!-- ESTADO: sin análisis disponible -->
          <div v-else
               class="rounded-2xl border border-border bg-white shadow-sm p-5">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-surface-container flex items-center justify-center shrink-0">
                <svg class="w-6 h-6 text-text-secondary" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round"
                    d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.347.347a3.5 3.5 0 00-1.035 2.475V19a2 2 0 01-2 2h-1.5a2 2 0 01-2-2v-.189a3.5 3.5 0 00-1.036-2.474l-.347-.347z"/>
                </svg>
              </div>
              <div>
                <p class="text-sm font-semibold text-text-main">Sales Intelligence</p>
                <p class="text-xs text-text-secondary mt-0.5">
                  El análisis IA aún no está disponible para este prospecto.
                  Se generará automáticamente al registrar el lead.
                </p>
              </div>
            </div>
          </div>

        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          <!-- COLUMNA IZQUIERDA -->
          <div class="lg:col-span-1">
            <div class="bg-white rounded-xl border border-border p-6 shadow-sm">
              <h2 class="font-semibold text-text-main mb-4 text-lg">Información del Prospecto</h2>
              <div class="space-y-0">
                
                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-secondary">✉️</div>
                  <div>
                    <div class="text-xs text-text-secondary uppercase tracking-wide">Email</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.email || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-secondary">📞</div>
                  <div>
                    <div class="text-xs text-text-secondary uppercase tracking-wide">Teléfono</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.phone || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-secondary">📌</div>
                  <div>
                    <div class="text-xs text-text-secondary uppercase tracking-wide">Estado</div>
                    <div class="mt-0.5">
                      <span class="px-2 py-0.5 text-xs font-medium rounded-full" :class="getStatusClass(lead.status)">
                        {{ lead.status ? lead.status.charAt(0).toUpperCase() + lead.status.slice(1) : '—' }}
                      </span>
                    </div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-secondary">🔗</div>
                  <div>
                    <div class="text-xs text-text-secondary uppercase tracking-wide">Fuente</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.source || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-secondary">🏢</div>
                  <div>
                    <div class="text-xs text-text-secondary uppercase tracking-wide">Empresa</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.companies?.name || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3">
                  <div class="w-8 flex justify-center text-text-secondary">📅</div>
                  <div>
                    <div class="text-xs text-text-secondary uppercase tracking-wide">Registrado</div>
                    <div class="text-sm text-text-main font-medium">{{ formatDate(lead.created_at) }}</div>
                  </div>
                </div>

              </div>
            </div>
          </div>

          <!-- COLUMNA DERECHA -->
          <div class="lg:col-span-2 space-y-6">
            
            <!-- Negocios Asociados -->
            <div class="bg-white rounded-xl border border-border p-6 shadow-sm">
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-text-main text-lg">Negocios</h2>
                <span class="bg-gray-100 text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">{{ deals.length }}</span>
              </div>
              
              <div v-if="deals.length === 0" class="text-center py-4">
                <p class="text-sm text-text-secondary">Sin negocios asociados</p>
              </div>
              
              <div v-else class="space-y-0">
                <div v-for="deal in deals" :key="deal.id" class="flex justify-between items-center py-3 border-b border-border last:border-0 hover:bg-gray-50 transition-colors -mx-6 px-6">
                  <div>
                    <div class="font-medium text-sm text-text-main">{{ deal.title }}</div>
                    <div v-if="deal.expected_close" class="text-xs text-text-secondary mt-0.5">Cierre: {{ formatDate(deal.expected_close) }}</div>
                  </div>
                  <div class="flex items-center gap-4">
                    <span class="px-2 py-0.5 text-xs font-medium rounded-full" :class="getDealStageClass(deal.stage)">
                      {{ deal.stage ? deal.stage.charAt(0).toUpperCase() + deal.stage.slice(1) : '' }}
                    </span>
                    <span class="text-sm font-semibold text-success">{{ formatCurrency(deal.value) }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Feed de Actividad -->
            <div class="bg-white rounded-xl border border-border p-6 shadow-sm">
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

const lead = ref(null)
const activities = ref([])
const deals = ref([])
const loading = ref(true)
const error = ref(null)

const fetchLead = async () => {
  loading.value = true
  error.value = null

  try {
    const { data, error: leadError } = await supabase
      .from('leads')
      .select('id, full_name, email, phone, status, source, created_at, company_id, ai_score, ai_category, ai_summary, ai_next_step, ai_analyzed_at, companies(name)')
      .eq('id', route.params.id)
      .single()

    if (leadError || !data) {
      error.value = 'No se encontró el prospecto.'
      return
    }

    lead.value = data

    const [activitiesResponse, dealsResponse] = await Promise.all([
      supabase
        .from('activities')
        .select('id, type, description, created_at')
        .eq('lead_id', route.params.id)
        .order('created_at', { ascending: false })
        .limit(20),
      supabase
        .from('deals')
        .select('id, title, value, stage, expected_close')
        .eq('lead_id', route.params.id)
        .order('created_at', { ascending: false })
    ])

    if (!activitiesResponse.error) {
      activities.value = activitiesResponse.data || []
    }
    
    if (!dealsResponse.error) {
      deals.value = dealsResponse.data || []
    }

  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

const formatDate = (dateString) => {
  if (!dateString) return ''
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

const getStatusClass = (status) => {
  const map = {
    'nuevo': 'bg-blue-100 text-blue-700',
    'contactado': 'bg-yellow-100 text-yellow-700',
    'calificado': 'bg-green-100 text-green-700'
  }
  return map[status] || 'bg-gray-100 text-gray-700'
}

// --- Helpers del panel Sales Intelligence ---

// Color de acento superior de la card (banda de 4px)
const getScoreAccentClass = (score) => {
  if (score >= 70) return 'bg-gradient-to-r from-emerald-400 to-emerald-600'
  if (score >= 40) return 'bg-gradient-to-r from-yellow-400 to-orange-400'
  return 'bg-gradient-to-r from-red-400 to-red-600'
}

// Fondo + borde de la caja del score hero
const getScoreBgClass = (score) => {
  if (score >= 70) return 'bg-emerald-50 border-emerald-200'
  if (score >= 40) return 'bg-yellow-50 border-yellow-200'
  return 'bg-red-50 border-red-200'
}

// Color del número y etiqueta dentro del score hero
const getScoreTextClass = (score) => {
  if (score >= 70) return 'text-emerald-700'
  if (score >= 40) return 'text-yellow-700'
  return 'text-red-700'
}

// Badge de categoría (Hot / Warm / Cold)
const getCategoryClass = (category) => {
  const map = {
    'Hot':  'bg-red-50 text-red-700 border-red-200',
    'Warm': 'bg-yellow-50 text-yellow-700 border-yellow-200',
    'Cold': 'bg-blue-50 text-blue-700 border-blue-200'
  }
  return map[category] || 'bg-surface-container text-text-secondary border-border'
}

// Descripción de apoyo bajo el badge de categoría
const getCategoryDescription = (category) => {
  const map = {
    'Hot':  'Prospecto con alta probabilidad de conversión. Prioridad máxima.',
    'Warm': 'Prospecto con interés moderado. Requiere seguimiento activo.',
    'Cold': 'Prospecto con baja señal de intención. Contacto a largo plazo.'
  }
  return map[category] || ''
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

const getDealStageClass = (stage) => {
  const map = {
    'prospecto': 'bg-blue-100 text-blue-700',
    'cotizado': 'bg-yellow-100 text-yellow-700',
    'negociando': 'bg-orange-100 text-orange-700',
    'ganado': 'bg-green-100 text-green-700',
    'perdido': 'bg-red-100 text-red-700'
  }
  return map[stage] || 'bg-gray-100 text-gray-700'
}

onMounted(() => {
  fetchLead()
})
</script>
