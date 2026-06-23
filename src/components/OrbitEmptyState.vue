<template>
  <div class="text-center py-12 bg-slate-900/40 backdrop-blur-md rounded-xl border border-dashed border-white/10">
    <div class="mx-auto w-12 h-12 text-slate-400 mb-4 flex items-center justify-center bg-slate-800/50 rounded-xl border border-white/10">
      <slot name="icon">
        <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
        </svg>
      </slot>
    </div>
    <h3 class="text-base font-semibold text-slate-50">{{ title }}</h3>
    <p class="mt-1 text-sm text-slate-400">{{ description }}</p>
    <div class="mt-6">
      <slot name="action"></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: String,
  description: String,
})
</script>
