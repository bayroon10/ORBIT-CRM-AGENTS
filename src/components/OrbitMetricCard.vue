<template>
  <div class="metric-card card-3d animate-fadeInUp relative overflow-hidden bg-slate-900/40 backdrop-blur-md rounded-xl p-5 border border-white/10 shadow-2xl cursor-default group">
    <!-- Línea de acento superior — color único indigo -->
    <div class="absolute top-0 left-0 right-0 h-0.5 rounded-t-xl bg-gradient-to-r from-primary/50 via-primary to-primary-300 opacity-80"></div>

    <div class="flex items-start justify-between mb-5">
      <p class="text-2xs font-semibold uppercase tracking-widest text-slate-400">{{ title }}</p>
      <!-- Ícono -->
      <div class="w-9 h-9 rounded-lg bg-primary/15 border border-primary/20 flex items-center justify-center text-primary-300 transition-transform duration-200 group-hover:scale-110">
        <!-- users -->
        <svg v-if="icon === 'users'" class="w-4.5 h-4.5 w-[18px] h-[18px]" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path stroke-linecap="round" stroke-linejoin="round" d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        <!-- briefcase -->
        <svg v-else-if="icon === 'briefcase'" class="w-[18px] h-[18px]" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path stroke-linecap="round" stroke-linejoin="round" d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2M12 12v4M10 14h4"/></svg>
        <!-- document -->
        <svg v-else-if="icon === 'document'" class="w-[18px] h-[18px]" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        <!-- chart (default) -->
        <svg v-else class="w-[18px] h-[18px]" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><polyline points="22,12 18,12 15,21 9,3 6,12 2,12"/></svg>
      </div>
    </div>

    <!-- Valor principal -->
    <div
      class="metric-counter animate-countUp text-3xl font-bold tracking-tight text-slate-50 mb-1"
      :data-target="typeof value === 'number' ? value : 0"
    >
      {{ value }}
    </div>

    <!-- Trend -->
    <div v-if="trend !== undefined && trend !== null" class="flex items-center gap-1 mt-2">
      <span
        class="text-xs font-semibold"
        :class="trend > 0 ? 'text-success' : trend < 0 ? 'text-danger' : 'text-text-muted'"
      >
        {{ trend > 0 ? '↑ +' : trend < 0 ? '↓ ' : '→ ' }}{{ trend !== 0 ? Math.abs(trend) + '%' : 'Sin cambios' }}
      </span>
      <span class="text-xs text-slate-400">vs mes anterior</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: String,
  value: [String, Number],
  trend: Number,
  icon:  String
})
</script>
