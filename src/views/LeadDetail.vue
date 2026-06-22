<template>
  <div class="h-full flex flex-col">
    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-4">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando prospecto...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex flex-col items-center justify-center p-8">
      <div class="bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 text-center w-full max-w-md">
        <p class="mb-4">{{ error }}</p>
        <BaseButton @click="router.push('/leads')" variant="danger">
          Volver a Leads
        </BaseButton>
      </div>
    </div>

    <!-- Data State -->
    <template v-else-if="lead">
      <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 shadow-lg border border-primary/20 shrink-0">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
        <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-15 bg-primary blur-3xl"></div>
        <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 class="text-3xl font-bold text-text-main">{{ lead.full_name }}</h1>
            <p class="text-text-secondary mt-1">Prospecto · {{ lead.companies?.name || 'Sin empresa' }}</p>
          </div>
          <div class="flex space-x-3 items-center">
            <BaseButton
              v-if="lead.ai_score === null"
              variant="primary"
              @click="showAiModal = true"
            >
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.347.347a3.5 3.5 0 00-1.035 2.475V19a2 2 0 01-2 2h-1.5a2 2 0 01-2-2v-.189a3.5 3.5 0 00-1.036-2.474l-.347-.347z"/>
              </svg>
              Calificar con IA
            </BaseButton>
            <BaseButton
              v-else
              variant="secondary"
              size="sm"
              @click="showAiModal = true"
            >
              Re-analizar
            </BaseButton>

            <button 
              @click="router.push('/leads')"
              class="px-4 py-2 border border-border rounded-lg text-sm font-medium text-text-secondary hover:text-text-main hover:bg-surface-card transition-colors"
            >
              &larr; Volver
            </button>
          </div>
        </div>
      </div>

      <div class="flex-1 overflow-y-auto pb-8">
        
        <!-- Banners IA -->
        <div v-if="aiSuccess" class="mx-6 mb-6 p-4 rounded-lg bg-success/10 border border-success/20 text-success text-sm font-medium animate-fadeInUp">
          ✓ Análisis completado. Actualizando datos...
        </div>
        <div v-if="aiError" class="mx-6 mb-6 p-4 rounded-lg bg-danger/10 border border-danger/20 text-danger text-sm font-medium animate-fadeInUp">
          ⚠ {{ aiError }}
        </div>

        <!-- Panel Sales Intelligence — siempre visible cuando hay lead -->
        <div class="mx-6 mb-6 animate-fadeInUp">

          <!-- ESTADO: análisis disponible -->
          <BaseCard v-if="lead.ai_score" :padded="false" class="overflow-hidden">
            <!-- Banda de acento superior con color dinámico según score -->
            <div class="h-1 w-full"
                 :class="getScoreAccentClass(lead.ai_score)"></div>

            <div class="p-5">
              <!-- Header -->
              <div class="flex items-center justify-between mb-5">
                <div class="flex items-center gap-2">
                  <!-- Ícono sparkle / IA -->
                  <div class="w-7 h-7 rounded-lg bg-primary/10 flex items-center justify-center">
                    <svg class="w-4 h-4 text-primary-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round"
                        d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.347.347a3.5 3.5 0 00-1.035 2.475V19a2 2 0 01-2 2h-1.5a2 2 0 01-2-2v-.189a3.5 3.5 0 00-1.036-2.474l-.347-.347z"/>
                    </svg>
                  </div>
                  <span class="text-sm font-semibold text-text-main">Sales Intelligence</span>
                </div>
                <!-- Fecha de análisis -->
                <div class="flex items-center gap-1.5 text-xs text-text-muted">
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
                <p class="text-xs font-semibold text-text-muted uppercase tracking-wider mb-1.5">
                  Perfil del Prospecto
                </p>
                <p class="text-sm text-text-main leading-relaxed">{{ lead.ai_summary }}</p>
              </div>

              <!-- Acción Recomendada (ex Próximo paso) -->
              <div class="rounded-xl bg-primary/10 border border-primary/20 px-4 py-3">
                <div class="flex items-center gap-2 mb-1">
                  <!-- Check icon -->
                  <svg class="w-3.5 h-3.5 text-primary-300 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                    <polyline points="20 6 9 17 4 12"/>
                  </svg>
                  <p class="text-xs font-semibold text-primary-300 uppercase tracking-wider">
                    Acción Recomendada
                  </p>
                </div>
                <p class="text-sm font-medium text-text-main pl-5">{{ lead.ai_next_step }}</p>
              </div>
            </div>
          </BaseCard>

          <!-- ESTADO: sin análisis disponible -->
          <BaseCard v-else class="p-5">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-surface-card flex items-center justify-center shrink-0 border border-border">
                <svg class="w-6 h-6 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
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
          </BaseCard>

        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 px-6">
          
          <!-- COLUMNA IZQUIERDA -->
          <div class="lg:col-span-1">
            <BaseCard>
              <h2 class="font-semibold text-text-main mb-4 text-lg">Información del Prospecto</h2>
              <div class="space-y-0">
                
                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-muted">✉️</div>
                  <div>
                    <div class="text-xs text-text-muted uppercase tracking-wide">Email</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.email || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-muted">📞</div>
                  <div>
                    <div class="text-xs text-text-muted uppercase tracking-wide">Teléfono</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.phone || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-muted">📌</div>
                  <div>
                    <div class="text-xs text-text-muted uppercase tracking-wide">Estado</div>
                    <div class="mt-0.5">
                      <BaseBadge :variant="getStatusVariant(lead.status)">
                        {{ lead.status ? lead.status.charAt(0).toUpperCase() + lead.status.slice(1) : '—' }}
                      </BaseBadge>
                    </div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-muted">🔗</div>
                  <div>
                    <div class="text-xs text-text-muted uppercase tracking-wide">Fuente</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.source || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3 border-b border-border">
                  <div class="w-8 flex justify-center text-text-muted">🏢</div>
                  <div>
                    <div class="text-xs text-text-muted uppercase tracking-wide">Empresa</div>
                    <div class="text-sm text-text-main font-medium">{{ lead.companies?.name || '—' }}</div>
                  </div>
                </div>

                <div class="flex items-center gap-3 py-3">
                  <div class="w-8 flex justify-center text-text-muted">📅</div>
                  <div>
                    <div class="text-xs text-text-muted uppercase tracking-wide">Registrado</div>
                    <div class="text-sm text-text-main font-medium">{{ formatDate(lead.created_at) }}</div>
                  </div>
                </div>

              </div>
            </BaseCard>
          </div>

          <!-- COLUMNA DERECHA -->
          <div class="lg:col-span-2 space-y-6">
            
            <!-- Negocios Asociados -->
            <BaseCard>
              <div class="flex justify-between items-center mb-4">
                <h2 class="font-semibold text-text-main text-lg">Negocios</h2>
                <span class="bg-surface-card border border-border text-text-secondary px-2.5 py-0.5 rounded-full text-xs font-medium">{{ deals.length }}</span>
              </div>
              
              <div v-if="deals.length === 0" class="text-center py-4">
                <p class="text-sm text-text-secondary">Sin negocios asociados</p>
              </div>
              
              <div v-else class="space-y-0">
                <div v-for="deal in deals" :key="deal.id" class="flex justify-between items-center py-3 border-b border-border last:border-0 hover:bg-surface-card transition-colors -mx-6 px-6">
                  <div>
                    <div class="font-medium text-sm text-text-main">{{ deal.title }}</div>
                    <div v-if="deal.expected_close" class="text-xs text-text-secondary mt-0.5">Cierre: {{ formatDate(deal.expected_close) }}</div>
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

            <!-- Feed de Actividad -->
            <BaseCard>
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

      <!-- Modal de confirmación IA -->
      <OrbitModal v-model="showAiModal" title="Calificar lead con IA">
        <p class="text-sm text-text-secondary">
          Se analizará el perfil de <span class="font-semibold text-text-main">{{ lead.full_name }}</span> usando Gemini para generar un score, categoría y recomendaciones de seguimiento. ¿Continuar?
        </p>
        
        <template #footer>
          <div class="flex justify-end gap-3">
            <BaseButton variant="ghost" @click="showAiModal = false" :disabled="aiLoading">
              Cancelar
            </BaseButton>
            <BaseButton variant="primary" @click="qualifyLead" :loading="aiLoading">
              {{ aiLoading ? 'Analizando...' : 'Calificar' }}
            </BaseButton>
          </div>
        </template>
      </OrbitModal>
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
import OrbitModal from '../components/OrbitModal.vue'

const route = useRoute()
const router = useRouter()

const lead = ref(null)
const activities = ref([])
const deals = ref([])
const loading = ref(true)
const error = ref(null)

const showAiModal = ref(false)
const aiLoading = ref(false)
const aiSuccess = ref(false)
const aiError = ref('')

const qualifyLead = async () => {
  aiLoading.value = true
  aiError.value = ''

  if (!import.meta.env.VITE_N8N_WEBHOOK_URL) {
    showAiModal.value = false
    aiLoading.value = false
    aiError.value = 'URL del webhook de n8n no está configurada.'
    setTimeout(() => {
      aiError.value = ''
    }, 6000)
    return
  }
  
  let url = import.meta.env.VITE_N8N_WEBHOOK_URL
  
  try {
    let response
    try {
      response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Webhook-Secret': import.meta.env.VITE_N8N_WEBHOOK_SECRET
        },
        body: JSON.stringify({ lead_id: lead.value.id })
      })
    } catch (netErr) {
      if (url.includes('/webhook/')) {
        const testUrl = url.replace('/webhook/', '/webhook-test/')
        console.warn(`[n8n Fallback]: Falló webhook producción. Intentando webhook de pruebas: ${testUrl}`)
        response = await fetch(testUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-Webhook-Secret': import.meta.env.VITE_N8N_WEBHOOK_SECRET
          },
          body: JSON.stringify({ lead_id: lead.value.id })
        })
      } else {
        throw netErr
      }
    }

    if (!response || !response.ok) {
      throw new Error(`El servidor de automatización devolvió un código de error: ${response ? response.status : 'vacío'}`)
    }

    const text = await response.text()
    const data = text ? JSON.parse(text) : {}
    
    if (data.error) {
      throw new Error(data.error)
    }

    showAiModal.value = false
    aiSuccess.value = true
    
    setTimeout(() => {
      aiSuccess.value = false
    }, 4000)

    await fetchLead()

  } catch (err) {
    showAiModal.value = false
    if (
      err.name === 'TypeError' || 
      err.message.includes('Failed to fetch') || 
      err.message.includes('fetch') || 
      err.message.includes('código de error: vacío') ||
      err.message.includes('empty')
    ) {
      aiError.value = 'El flujo de automatización n8n no devolvió ninguna respuesta (ERR_EMPTY_RESPONSE). Asegúrate de activar el flujo en la UI de n8n.'
    } else {
      aiError.value = err.message || 'Error al calificar el lead'
    }
    setTimeout(() => {
      aiError.value = ''
    }, 6000)
  } finally {
    aiLoading.value = false
  }
}

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

const getStatusVariant = (status) => {
  const map = {
    'nuevo': 'primary',
    'contactado': 'warning',
    'calificado': 'success'
  }
  return map[status] || 'default'
}

// --- Helpers del panel Sales Intelligence ---

// Color de acento superior de la card (banda de 4px)
const getScoreAccentClass = (score) => {
  if (score >= 70) return 'bg-gradient-to-r from-emerald-500 to-emerald-700'
  if (score >= 40) return 'bg-gradient-to-r from-yellow-500 to-orange-500'
  return 'bg-gradient-to-r from-red-500 to-red-700'
}

// Fondo + borde de la caja del score hero
const getScoreBgClass = (score) => {
  if (score >= 70) return 'bg-success/10 border-success/20'
  if (score >= 40) return 'bg-warning/10 border-warning/20'
  return 'bg-danger/10 border-danger/20'
}

// Color del número y etiqueta dentro del score hero
const getScoreTextClass = (score) => {
  if (score >= 70) return 'text-success'
  if (score >= 40) return 'text-warning'
  return 'text-danger'
}

// Badge de categoría (Hot / Warm / Cold)
const getCategoryClass = (category) => {
  const map = {
    'Hot':  'bg-danger/10 text-danger border-danger/20',
    'Warm': 'bg-warning/10 text-warning border-warning/20',
    'Cold': 'bg-primary/10 text-primary-300 border-primary/20'
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

const getDealStageVariant = (stage) => {
  const map = {
    'prospecto': 'primary',
    'cotizado': 'warning',
    'negociando': 'danger', // usando danger para naranja/negociando si no hay orange
    'ganado': 'success',
    'perdido': 'danger'
  }
  return map[stage] || 'default'
}

onMounted(() => {
  fetchLead()
})
</script>
