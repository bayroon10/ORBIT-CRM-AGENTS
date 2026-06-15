<template>
  <div>
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-20 -right-20 w-80 h-80 rounded-full opacity-10 bg-blue-400 blur-3xl"></div>
      <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 class="text-3xl font-bold text-white">Nueva Cotización</h1>
          <p class="text-blue-200 mt-1">Configura los detalles de la propuesta comercial.</p>
        </div>
      </div>
    </div>
    
    <div class="bg-white p-6 rounded-xl border border-border">
      <p class="text-text-secondary">Formulario de cotización e ítems de línea irán aquí.</p>
      <div class="mt-6 flex space-x-3">
        <button @click="$router.push('/quotes')" class="border border-border hover:bg-surface-container px-4 py-2 rounded-lg text-sm font-medium transition-colors">
          Cancelar
        </button>
        <button class="bg-primary hover:bg-primary-variant text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
          Guardar Cotización
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import OrbitPageHeader from '../components/OrbitPageHeader.vue'
</script>
