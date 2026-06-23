<template>
  <!--
    BaseButton — botón consistente del design system.
    Props:
      • variant: 'primary' | 'secondary' | 'ghost' | 'danger'
      • size:    'sm' | 'md' | 'lg'
      • loading: Boolean — muestra spinner y deshabilita
      • disabled: Boolean
      • type:    'button' | 'submit' | 'reset'
  -->
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="[
      'inline-flex items-center justify-center gap-2 font-medium transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-surface disabled:opacity-50 disabled:cursor-not-allowed',
      sizeClass,
      variantClass,
      (variant === 'primary') && 'btn-glow',
    ]"
  >
    <!-- Spinner -->
    <span
      v-if="loading"
      class="w-4 h-4 rounded-full border-2 border-current border-t-transparent animate-spin"
    />
    <slot />
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant:  { type: String, default: 'primary' },
  size:     { type: String, default: 'md' },
  loading:  { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  type:     { type: String, default: 'button' },
})

const sizeClass = computed(() => {
  const map = {
    sm: 'px-3 py-1.5 text-xs rounded-md',
    md: 'px-4 py-2 text-sm rounded-lg',
    lg: 'px-6 py-2.5 text-sm rounded-lg',
  }
  return map[props.size] || map.md
})

const variantClass = computed(() => {
  const map = {
    primary:   'bg-primary hover:bg-primary-600 text-white shadow-lg',
    secondary: 'bg-slate-800/50 backdrop-blur-md border border-white/10 text-slate-50 hover:bg-slate-700/50',
    ghost:     'text-slate-400 hover:text-white hover:bg-slate-800/50',
    danger:    'bg-danger/15 border border-danger/30 text-danger hover:bg-danger/25 backdrop-blur-md',
  }
  return map[props.variant] || map.primary
})
</script>
