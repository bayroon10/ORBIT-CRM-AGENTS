<template>
  <div class="metric-card card-3d animate-fadeInUp relative overflow-hidden bg-white rounded-2xl p-6 border border-gray-100 shadow-sm cursor-default group">
    <!-- Línea de acento superior -->
    <div class="absolute top-0 left-0 right-0 h-0.5 rounded-t-2xl transition-all duration-300"
      :class="{
        'bg-gradient-to-r from-blue-400 to-blue-600': color === 'blue' || !color,
        'bg-gradient-to-r from-violet-400 to-violet-600': color === 'purple',
        'bg-gradient-to-r from-orange-400 to-orange-500': color === 'orange',
        'bg-gradient-to-r from-emerald-400 to-emerald-600': color === 'green'
      }">
    </div>

    <div class="flex items-start justify-between mb-5">
      <p class="text-xs font-semibold uppercase tracking-wider text-gray-400">{{ title }}</p>
      <!-- Ícono -->
      <div class="w-10 h-10 rounded-xl flex items-center justify-center transition-transform duration-200 group-hover:scale-110"
        :class="{
          'bg-blue-50': color === 'blue' || !color,
          'bg-violet-50': color === 'purple',
          'bg-orange-50': color === 'orange',
          'bg-emerald-50': color === 'green'
        }">
        <!-- users -->
        <svg v-if="icon === 'users'" class="w-5 h-5" :class="{'text-blue-500': color==='blue'||!color,'text-violet-500':color==='purple','text-orange-500':color==='orange','text-emerald-500':color==='green'}" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path stroke-linecap="round" stroke-linejoin="round" d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        <!-- briefcase -->
        <svg v-else-if="icon === 'briefcase'" class="w-5 h-5" :class="{'text-blue-500': color==='blue'||!color,'text-violet-500':color==='purple','text-orange-500':color==='orange','text-emerald-500':color==='green'}" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="14" rx="2"/><path stroke-linecap="round" stroke-linejoin="round" d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2M12 12v4M10 14h4"/></svg>
        <!-- document -->
        <svg v-else-if="icon === 'document'" class="w-5 h-5" :class="{'text-blue-500': color==='blue'||!color,'text-violet-500':color==='purple','text-orange-500':color==='orange','text-emerald-500':color==='green'}" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14,2 14,8 20,8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        <!-- chart -->
        <svg v-else class="w-5 h-5" :class="{'text-blue-500': color==='blue'||!color,'text-violet-500':color==='purple','text-orange-500':color==='orange','text-emerald-500':color==='green'}" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24"><polyline points="22,12 18,12 15,21 9,3 6,12 2,12"/></svg>
      </div>
    </div>

    <!-- Valor principal -->
    <div class="metric-counter animate-countUp text-3xl font-bold tracking-tight text-gray-900 mb-1"
      :data-target="typeof value === 'number' ? value : 0">
      {{ value }}
    </div>

    <!-- Trend -->
    <div v-if="trend !== undefined && trend !== null" class="flex items-center gap-1 mt-2">
      <span class="text-xs font-semibold"
        :class="trend > 0 ? 'text-emerald-500' : trend < 0 ? 'text-red-400' : 'text-gray-400'">
        {{ trend > 0 ? '↑ +' : trend < 0 ? '↓ ' : '→ ' }}{{ trend !== 0 ? Math.abs(trend) + '%' : 'Sin cambios' }}
      </span>
      <span class="text-xs text-gray-400">vs mes anterior</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: String,
  value: [String, Number],
  trend: Number,
  icon: String,
  color: String
})

const iconBgClass = computed(() => {
  const map = {
    blue: 'bg-blue-50',
    green: 'bg-emerald-50',
    orange: 'bg-orange-50',
    purple: 'bg-violet-50'
  }
  return map[props.color] || 'bg-blue-50'
})

const iconColorClass = computed(() => {
  const map = {
    blue: 'text-blue-600',
    green: 'text-emerald-600',
    orange: 'text-orange-500',
    purple: 'text-violet-600'
  }
  return map[props.color] || 'text-blue-600'
})

const trendColorClass = computed(() => {
  if (props.trend > 0) return 'text-emerald-600'
  if (props.trend < 0) return 'text-red-500'
  return 'text-gray-400'
})

const trendLabel = computed(() => {
  if (props.trend > 0) return `↑ +${props.trend}% vs mes anterior`
  if (props.trend < 0) return `↓ ${props.trend}% vs mes anterior`
  return '→ Sin cambios'
})
</script>
