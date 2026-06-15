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
        
        <!-- Panel IA — solo visible si lead.ai_score existe -->
        <div v-if="lead.ai_score" 
             class="mx-6 -mt-4 mb-6 rounded-2xl border border-blue-100 
                    bg-gradient-to-r from-blue-50 to-indigo-50 p-5 shadow-sm">
          
          <!-- Header del panel -->
          <div class="flex items-center gap-2 mb-4">
            <!-- ícono robot SVG inline -->
            <svg class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5
                   a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
            </svg>
            <span class="text-sm font-semibold text-primary">Análisis IA</span>
            <span class="ml-auto text-xs text-gray-400">
              {{ formatDate(lead.ai_analyzed_at) }}
            </span>
          </div>

          <!-- Score + Category -->
          <div class="flex items-center gap-4 mb-4">
            <!-- Score circular -->
            <div class="flex flex-col items-center">
              <div class="w-16 h-16 rounded-full flex items-center justify-center font-bold text-xl text-white shadow-md"
                   :class="{
                     'bg-red-500': lead.ai_score >= 70,
                     'bg-yellow-500': lead.ai_score >= 40 && lead.ai_score < 70,
                     'bg-gray-400': lead.ai_score < 40
                   }">
                {{ lead.ai_score }}
              </div>
              <span class="text-xs text-gray-500 mt-1 font-medium">Score</span>
            </div>
            <!-- Category badge -->
            <div>
              <span class="rounded-full px-3 py-1 text-sm font-semibold shadow-sm"
                    :class="{
                      'bg-red-100 text-red-700 border border-red-200': lead.ai_category === 'Hot',
                      'bg-yellow-100 text-yellow-700 border border-yellow-200': lead.ai_category === 'Warm',
                      'bg-gray-100 text-gray-600 border border-gray-200': lead.ai_category === 'Cold'
                    }">
                {{ lead.ai_category === 'Hot' ? '🔥 Hot' : 
                   lead.ai_category === 'Warm' ? '⚡ Warm' : '❄️ Cold' }}
              </span>
              <p class="text-xs text-gray-400 mt-1">Categoría</p>
            </div>
          </div>

          <!-- Summary -->
          <div class="mb-3">
            <p class="text-xs font-medium text-gray-500 uppercase tracking-wide mb-1">
              Resumen
            </p>
            <p class="text-sm text-gray-700">{{ lead.ai_summary }}</p>
          </div>

          <!-- Next step -->
          <div class="rounded-xl bg-white border border-blue-100 px-4 py-3 shadow-sm">
            <p class="text-xs font-medium text-primary uppercase tracking-wide mb-1">
              ✅ Próximo paso recomendado
            </p>
            <p class="text-sm font-medium text-gray-800">{{ lead.ai_next_step }}</p>
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
