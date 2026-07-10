<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { gsap } from 'gsap'
import { whatsappService } from '../services/whatsapp.service'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'

const router = useRouter()

// Estado
const loading = ref(true)
const error = ref(null)
const conversations = ref([])
const selectedPhone = ref(null)
const selectedMessages = ref([])
const loadingMessages = ref(false)
const realtimeChannel = ref(null)

// Agrupar conversaciones por teléfono (última de cada número)
const groupedConversations = computed(() => {
  const groups = {}
  conversations.value.forEach(msg => {
    if (!groups[msg.phone]) {
      groups[msg.phone] = {
        phone: msg.phone,
        lead: msg.leads,
        lastMessage: msg.message,
        lastAt: msg.created_at,
        unread: 0
      }
    }
    if (msg.direction === 'inbound' && !msg.read) {
      groups[msg.phone].unread++
    }
  })
  return Object.values(groups).sort((a, b) => new Date(b.lastAt) - new Date(a.lastAt))
})

// Cargar conversaciones
async function loadConversations() {
  try {
    loading.value = true
    error.value = null
    conversations.value = await whatsappService.getConversations()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

// Seleccionar conversación
async function selectConversation(phone) {
  selectedPhone.value = phone
  loadingMessages.value = true
  try {
    await whatsappService.markAsRead(phone)
    selectedMessages.value = await whatsappService.getConversationByPhone(phone)
    const group = groupedConversations.value.find(g => g.phone === phone)
    if (group) group.unread = 0
    await nextTick()
    scrollToBottom()
  } catch (e) {
    error.value = e.message
  } finally {
    loadingMessages.value = false
  }
}

function scrollToBottom() {
  const el = document.getElementById('messages-container')
  if (el) el.scrollTop = el.scrollHeight
}

function formatTime(ts) {
  return new Date(ts).toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })
}

function formatDate(ts) {
  return new Date(ts).toLocaleDateString('es-CL', { day: 'numeric', month: 'short' })
}

function getLeadName(conv) {
  return conv.lead?.full_name || conv.phone
}

// Realtime: escuchar nuevos mensajes
function setupRealtime() {
  realtimeChannel.value = whatsappService.subscribeToConversations((newMsg) => {
    conversations.value.unshift(newMsg)
    if (selectedPhone.value === newMsg.phone) {
      selectedMessages.value.push(newMsg)
      nextTick(() => scrollToBottom())
    }
  })
}

onMounted(async () => {
  await loadConversations()
  setupRealtime()
  await nextTick()
  const panels = document.querySelectorAll('.inbox-panel')
  if (panels.length > 0) {
    gsap.fromTo(panels, { opacity: 0, x: -20 }, { opacity: 1, x: 0, duration: 0.4, stagger: 0.05 })
  }
})

onUnmounted(() => {
  if (realtimeChannel.value) {
    realtimeChannel.value.unsubscribe()
  }
})
</script>

<template>
  <div class="p-6 h-screen flex flex-col">
    <!-- Header manual (sin OrbitPageHeader para evitar dependencias de slot) -->
    <div class="mb-6 flex items-center justify-between shrink-0">
      <div>
        <h1 class="text-2xl font-bold text-slate-50 tracking-tight">WhatsApp Inbox</h1>
        <p class="text-sm text-slate-400 mt-1">Conversaciones en tiempo real con tus leads</p>
      </div>
      <button
        id="wa-inbox-config-btn"
        @click="router.push({ name: 'ProviderSettings' })"
        class="flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-slate-300 bg-slate-800/50 border border-white/10 rounded-lg hover:bg-slate-700/50 transition-colors"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="3"></circle>
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
        </svg>
        Configurar
      </button>
    </div>

    <!-- Error banner -->
    <div v-if="error" class="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-400 text-sm shrink-0">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex-1 flex items-center justify-center">
      <div class="w-6 h-6 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
    </div>

    <!-- Empty state -->
    <div
      v-else-if="!loading && groupedConversations.length === 0"
      class="flex-1 flex flex-col items-center justify-center text-center"
    >
      <div class="text-5xl mb-4">💬</div>
      <h3 class="text-lg font-bold text-slate-50 mb-2">Sin conversaciones aún</h3>
      <p class="text-sm text-slate-400 max-w-xs">Los mensajes de WhatsApp aparecerán aquí cuando lleguen. Asegúrate de configurar el webhook en Meta Developer.</p>
    </div>

    <!-- Inbox layout -->
    <div v-else class="flex-1 flex gap-4 overflow-hidden">

      <!-- Panel izquierdo: lista de conversaciones -->
      <div id="wa-conversations-panel" class="inbox-panel w-72 flex-shrink-0 bg-slate-900/50 rounded-xl border border-white/10 overflow-y-auto">
        <div class="p-3 border-b border-white/5">
          <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider">Conversaciones</p>
        </div>
        <div
          v-for="conv in groupedConversations"
          :key="conv.phone"
          :id="`wa-conv-${conv.phone.replace(/\D/g,'')}`"
          @click="selectConversation(conv.phone)"
          class="p-3 border-b border-white/5 cursor-pointer hover:bg-white/5 transition-colors"
          :class="{ 'bg-indigo-500/10 border-l-2 border-l-indigo-500': selectedPhone === conv.phone }"
        >
          <div class="flex items-start justify-between gap-2">
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-slate-50 truncate">{{ getLeadName(conv) }}</p>
              <p class="text-xs text-slate-400 truncate mt-0.5">{{ conv.lastMessage }}</p>
            </div>
            <div class="flex flex-col items-end gap-1 flex-shrink-0">
              <span class="text-xs text-slate-500">{{ formatDate(conv.lastAt) }}</span>
              <span
                v-if="conv.unread > 0"
                class="text-xs bg-indigo-500 text-white rounded-full px-1.5 py-0.5 font-medium min-w-[18px] text-center"
              >
                {{ conv.unread }}
              </span>
            </div>
          </div>
          <!-- Lead badge si tiene score -->
          <div v-if="conv.lead?.ai_score" class="mt-1.5 flex gap-1">
            <span class="text-xs px-1.5 py-0.5 rounded bg-emerald-500/10 text-emerald-400 font-medium">
              Score {{ conv.lead.ai_score }}
            </span>
            <span v-if="conv.lead.ai_category" class="text-xs px-1.5 py-0.5 rounded bg-indigo-500/10 text-indigo-300">
              {{ conv.lead.ai_category }}
            </span>
          </div>
        </div>
      </div>

      <!-- Panel derecho: hilo de mensajes -->
      <div class="inbox-panel flex-1 bg-slate-900/50 rounded-xl border border-white/10 flex flex-col overflow-hidden">

        <!-- Sin conversación seleccionada -->
        <div v-if="!selectedPhone" class="flex-1 flex items-center justify-center">
          <div class="text-center text-slate-500">
            <p class="text-4xl mb-3">💬</p>
            <p class="text-sm">Selecciona una conversación para ver los mensajes</p>
          </div>
        </div>

        <!-- Hilo de mensajes -->
        <template v-else>
          <!-- Header del hilo -->
          <div class="p-4 border-b border-white/10 flex items-center justify-between shrink-0">
            <div>
              <p class="font-semibold text-slate-50 text-sm">
                {{ getLeadName(groupedConversations.find(g => g.phone === selectedPhone) || { phone: selectedPhone }) }}
              </p>
              <p class="text-xs text-slate-400">{{ selectedPhone }}</p>
            </div>
            <button
              v-if="groupedConversations.find(g => g.phone === selectedPhone)?.lead?.id"
              id="wa-view-lead-btn"
              @click="router.push({ name: 'LeadDetail', params: { id: groupedConversations.find(g => g.phone === selectedPhone).lead.id } })"
              class="text-xs text-indigo-400 hover:text-indigo-300 hover:underline transition-colors"
            >
              Ver lead →
            </button>
          </div>

          <!-- Loading mensajes -->
          <div v-if="loadingMessages" class="flex-1 flex items-center justify-center">
            <div class="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          </div>

          <!-- Mensajes -->
          <div
            v-else
            id="messages-container"
            class="flex-1 overflow-y-auto p-4 flex flex-col gap-3"
          >
            <div
              v-for="msg in selectedMessages"
              :key="msg.id"
              class="flex"
              :class="msg.direction === 'outbound' ? 'justify-end' : 'justify-start'"
            >
              <div
                class="max-w-xs lg:max-w-sm px-3 py-2 rounded-xl text-sm shadow-sm"
                :class="msg.direction === 'outbound'
                  ? 'bg-indigo-600 text-white rounded-br-sm'
                  : 'bg-slate-800 text-slate-100 rounded-bl-sm border border-white/5'"
              >
                <p class="leading-relaxed">{{ msg.message }}</p>
                <div
                  class="flex items-center gap-1 mt-1.5"
                  :class="msg.direction === 'outbound' ? 'justify-end' : 'justify-start'"
                >
                  <span class="text-xs opacity-60">{{ formatTime(msg.created_at) }}</span>
                  <span v-if="msg.ai_generated" class="text-xs opacity-60">· IA ✦</span>
                </div>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>
