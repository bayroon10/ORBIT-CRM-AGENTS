<template>
  <div class="pointer-events-auto flex items-center gap-4 bg-surface-container border border-primary/50 shadow-glow rounded-xl p-4 w-80 relative overflow-hidden group">
    <!-- Glow effect overlay -->
    <div class="absolute inset-0 bg-gradient-to-r from-primary/20 to-transparent opacity-50"></div>
    
    <!-- Score Badge -->
    <div class="relative shrink-0 flex flex-col items-center justify-center w-12 h-12 rounded-full bg-surface-card border-2 border-primary shadow-glow">
      <span class="text-[10px] text-text-secondary uppercase tracking-wider leading-none mt-1">Score</span>
      <span class="text-primary font-bold leading-none">{{ alert.score }}</span>
    </div>

    <!-- Content -->
    <div class="relative flex-1 min-w-0">
      <h4 class="text-sm font-semibold text-text-main truncate">{{ alert.name }}</h4>
      <p class="text-xs text-text-secondary line-clamp-1 mt-0.5">{{ alert.message }}</p>
    </div>

    <!-- Action -->
    <button 
      @click="$emit('close')" 
      class="relative shrink-0 p-1 rounded-md text-text-secondary hover:bg-surface-card hover:text-text-main transition-colors"
      title="Cerrar"
    >
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    </button>
  </div>
</template>

<script setup>
defineProps({
  alert: {
    type: Object,
    required: true
  }
})
defineEmits(['close'])
</script>
