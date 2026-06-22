<template>
  <div class="agent-status-panel bg-surface rounded-xl border border-border p-5 mb-8">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-bold text-text-main flex items-center gap-2">
        <svg class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        Centro de Agentes de IA
      </h3>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <!-- Deal Risk Agent -->
      <div class="bg-surface-container rounded-lg p-4 border border-border flex flex-col">
        <div class="flex items-start justify-between mb-2">
          <div>
            <h4 class="font-semibold text-text-main">Deal Risk Agent</h4>
            <p class="text-xs text-text-secondary">Monitoreo de riesgo en tiempo real</p>
          </div>
          <BaseBadge :variant="agentStatus.dealRisk ? 'success' : 'default'">
            {{ agentStatus.dealRisk ? 'Activo' : 'Inactivo' }}
          </BaseBadge>
        </div>
        <div class="mt-auto pt-3 flex items-center justify-between text-xs border-t border-border mt-3">
          <span class="text-text-muted">Última ejecución:</span>
          <span class="text-text-main font-medium">{{ lastRuns.dealRisk || '—' }}</span>
        </div>
      </div>

      <!-- Weekly Summary Agent -->
      <div class="bg-surface-container rounded-lg p-4 border border-border flex flex-col">
        <div class="flex items-start justify-between mb-2">
          <div>
            <h4 class="font-semibold text-text-main">Weekly Summary Agent</h4>
            <p class="text-xs text-text-secondary">Reporte ejecutivo semanal</p>
          </div>
          <BaseBadge :variant="agentStatus.weeklySummary ? 'success' : 'default'">
            {{ agentStatus.weeklySummary ? 'Activo' : 'Inactivo' }}
          </BaseBadge>
        </div>
        <div class="mt-auto pt-3 flex items-center justify-between text-xs border-t border-border mt-3">
          <span class="text-text-muted">Última ejecución:</span>
          <span class="text-text-main font-medium">{{ lastRuns.weeklySummary || '—' }}</span>
        </div>
      </div>

      <!-- Queue Watcher -->
      <div class="bg-surface-container rounded-lg p-4 border border-border flex flex-col">
        <div class="flex items-start justify-between mb-2">
          <div>
            <h4 class="font-semibold text-text-main">Queue Watcher</h4>
            <p class="text-xs text-text-secondary">Reintento de automatizaciones</p>
          </div>
          <BaseBadge :variant="agentStatus.queueWatcher ? 'success' : 'default'">
            {{ agentStatus.queueWatcher ? 'Activo' : 'Inactivo' }}
          </BaseBadge>
        </div>
        <div class="mt-auto pt-3 flex items-center justify-between text-xs border-t border-border mt-3">
          <span class="text-text-muted">Última ejecución:</span>
          <span class="text-text-main font-medium">{{ lastRuns.queueWatcher || '—' }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import BaseBadge from './BaseBadge.vue'

// Local state for UI
const agentStatus = ref({
  dealRisk: true,
  weeklySummary: true,
  queueWatcher: true
})

const lastRuns = ref({
  dealRisk: null,
  weeklySummary: null,
  queueWatcher: null
})

const fetchLogs = async () => {
  try {
    // Attempt to read from automation_logs to infer last execution times
    const { data, error } = await supabase
      .from('automation_logs')
      .select('automation_name, created_at')
      .order('created_at', { ascending: false })
      .limit(10)

    if (error) {
      console.warn('Could not load automation_logs', error)
      return
    }

    if (data && data.length > 0) {
      // Find latest for each
      const dr = data.find(l => l.automation_name === 'Deal Risk')
      if (dr) lastRuns.value.dealRisk = new Date(dr.created_at).toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })

      const ws = data.find(l => l.automation_name === 'Weekly Summary')
      if (ws) lastRuns.value.weeklySummary = new Date(ws.created_at).toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })
    }
  } catch (e) {
    console.error('Error fetching logs', e)
  }
}

onMounted(() => {
  fetchLogs()
})
</script>
