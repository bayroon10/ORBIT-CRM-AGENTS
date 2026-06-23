<template>
  <!--
    BaseBadge — etiqueta de estado/categoría.
    Props:
      • variant: 'default' | 'primary' | 'success' | 'danger' | 'warning' | 'muted'
      • size:    'sm' | 'md'   (default 'sm')
      • dot:     Boolean — prefija un punto coloreado (útil para estado online/activo)
  -->
  <span :class="['inline-flex items-center gap-1.5 font-semibold rounded-full', sizeClass, variantClass]">
    <span v-if="dot" :class="['w-1.5 h-1.5 rounded-full', dotColorClass]" />
    <slot />
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
    // 'default' | 'primary' | 'success' | 'danger' | 'warning' | 'muted'
  },
  size: {
    type: String,
    default: 'sm',
  },
  dot: {
    type: Boolean,
    default: false,
  },
})

const sizeClass = computed(() => {
  return props.size === 'md'
    ? 'px-3 py-1 text-xs'
    : 'px-2.5 py-0.5 text-[11px]'
})

const variantClass = computed(() => {
  const map = {
    default: 'bg-slate-800/50 backdrop-blur-sm text-slate-400 border border-white/10',
    primary: 'bg-primary/20 backdrop-blur-sm text-primary-300 border border-primary/30',
    success: 'bg-success/15 backdrop-blur-sm text-success border border-success/20',
    danger:  'bg-danger/15 backdrop-blur-sm text-danger border border-danger/20',
    warning: 'bg-warning/15 backdrop-blur-sm text-warning border border-warning/20',
    muted:   'bg-slate-900/50 backdrop-blur-sm text-slate-500 border border-white/5',
  }
  return map[props.variant] || map.default
})

const dotColorClass = computed(() => {
  const map = {
    default: 'bg-text-secondary',
    primary: 'bg-primary',
    success: 'bg-success',
    danger:  'bg-danger',
    warning: 'bg-warning',
    muted:   'bg-text-muted',
  }
  return map[props.variant] || map.default
})
</script>
