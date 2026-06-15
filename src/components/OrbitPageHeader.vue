<template>
  <div class="mb-6 flex items-center justify-between">
    <div>
      <h1 class="text-2xl font-semibold text-text-main">{{ title }}</h1>
      <p v-if="description" class="text-sm text-text-secondary mt-1">{{ description }}</p>
    </div>
    <div class="flex space-x-3">
      <slot name="actions"></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  }
})
</script>
