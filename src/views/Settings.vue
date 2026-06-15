<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10" style="background: radial-gradient(circle, #3b82f6, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">Sistema</span>
          </div>
          <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Configuración</h1>
          <p class="text-gray-400 text-sm">Ajustes generales, preferencias e información del espacio de trabajo.</p>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 shrink-0">
      {{ error }}
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      <p class="text-sm text-text-secondary">Cargando configuración...</p>
    </div>

    <div v-else class="flex flex-col md:flex-row gap-8 flex-1 pb-16">
      
      <!-- Nav Lateral -->
      <aside class="w-full md:w-64 shrink-0 flex flex-col gap-2">
        <button 
          @click="activeTab = 'General'"
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-all"
          :class="activeTab === 'General' ? 'bg-primary/10 text-primary border border-primary/20' : 'text-text-secondary hover:bg-surface hover:text-text-main border border-transparent'"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            General
          </div>
        </button>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
            Integraciones
          </div>
          <span class="text-[10px] bg-surface-container-high px-2 py-0.5 rounded-full font-bold uppercase">Pronto</span>
        </div>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
            Notificaciones
          </div>
          <span class="text-[10px] bg-surface-container-high px-2 py-0.5 rounded-full font-bold uppercase">Pronto</span>
        </div>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
            Seguridad
          </div>
          <span class="text-[10px] bg-surface-container-high px-2 py-0.5 rounded-full font-bold uppercase">Pronto</span>
        </div>

        <!-- Plan Info Card -->
        <div class="mt-6 p-5 rounded-2xl bg-gradient-to-br from-indigo-50 to-blue-50 border border-blue-100/50 relative overflow-hidden">
          <div class="absolute -right-4 -top-4 w-16 h-16 bg-blue-500/10 rounded-full blur-xl pointer-events-none"></div>
          <div class="flex items-center gap-2 mb-2 relative z-10">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
            <span class="text-xs font-bold text-primary uppercase tracking-wide">Plan Profesional</span>
          </div>
          <p class="text-xs text-text-secondary leading-relaxed mb-4 relative z-10">
            Tienes acceso a todas las funcionalidades avanzadas. El próximo ciclo de facturación es el 15 de Noviembre.
          </p>
          <button class="w-full py-1.5 text-xs font-medium text-primary hover:bg-primary/5 rounded-lg transition-colors border border-primary/20 relative z-10">
            Gestionar Plan
          </button>
        </div>
      </aside>

      <!-- Panel de Contenido -->
      <div class="flex-1 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden flex flex-col h-fit max-w-3xl">
        <div class="p-6 border-b border-gray-100 flex items-center justify-between bg-surface/30">
          <div>
            <h2 class="text-xl font-bold text-text-main">Ajustes Generales</h2>
            <p class="text-sm text-text-secondary mt-1">Configura las preferencias de tu espacio de trabajo.</p>
          </div>
          <button 
            @click="saveSettings"
            class="bg-primary hover:bg-primary-variant btn-glow text-white px-5 py-2.5 rounded-lg text-sm font-medium transition-all shadow-sm"
          >
            Guardar cambios
          </button>
        </div>

        <div class="p-6 space-y-8">
          <!-- Sección: Perfil del Espacio -->
          <div>
            <h3 class="text-base font-semibold text-text-main mb-4 flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-text-secondary"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
              Perfil del Espacio
            </h3>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="col-span-1 md:col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1.5">Nombre del sistema *</label>
                <input 
                  v-model="form.systemName"
                  type="text" 
                  class="w-full bg-white border border-border rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
                  placeholder="Ej: Orbit CRM"
                />
              </div>
            </div>
          </div>

          <hr class="border-gray-100" />

          <!-- Sección: Preferencias Regionales -->
          <div>
            <h3 class="text-base font-semibold text-text-main mb-4 flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-text-secondary"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
              Preferencias Regionales
            </h3>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-text-main mb-1.5">Zona horaria</label>
                <div class="relative">
                  <select 
                    v-model="form.timezone"
                    class="appearance-none w-full bg-white border border-border rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all cursor-pointer"
                  >
                    <option value="America/Santiago">(GMT-04:00) Santiago</option>
                    <option value="America/Bogota">(GMT-05:00) Bogotá, Lima, Quito</option>
                    <option value="America/Mexico_City">(GMT-06:00) Ciudad de México</option>
                    <option value="America/Buenos_Aires">(GMT-03:00) Buenos Aires</option>
                  </select>
                  <svg class="absolute right-3 top-3 pointer-events-none text-text-secondary" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-text-main mb-1.5">Idioma y Formato</label>
                <div class="relative">
                  <select 
                    v-model="form.locale"
                    class="appearance-none w-full bg-white border border-border rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all cursor-pointer"
                    disabled
                  >
                    <option value="es-CL">Español (Chile) - es-CL</option>
                  </select>
                  <svg class="absolute right-3 top-3 pointer-events-none text-text-secondary opacity-50" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </div>
                <p class="text-xs text-text-secondary mt-1.5">El formato de moneda y fechas utiliza la configuración local es-CL.</p>
              </div>
            </div>
          </div>
          
          <hr class="border-gray-100" />
          
          <!-- Mensaje Exitoso -->
          <Transition
            enter-active-class="transition ease-out duration-200"
            enter-from-class="opacity-0 translate-y-1"
            enter-to-class="opacity-100 translate-y-0"
            leave-active-class="transition ease-in duration-150"
            leave-from-class="opacity-100 translate-y-0"
            leave-to-class="opacity-0 translate-y-1"
          >
            <div v-if="saveSuccess" class="bg-success/10 border border-success/20 text-success px-4 py-3 rounded-lg text-sm flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
              Configuración guardada correctamente.
            </div>
          </Transition>

        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'

const activeTab = ref('General')
const loading = ref(true)
const error = ref(null)
const saveSuccess = ref(false)

const form = reactive({
  systemName: 'Orbit CRM',
  timezone: 'America/Santiago',
  locale: 'es-CL'
})

onMounted(() => {
  // Simulamos carga de config
  setTimeout(() => {
    loading.value = false
  }, 400)
})

const saveSettings = () => {
  saveSuccess.value = false
  setTimeout(() => {
    saveSuccess.value = true
    setTimeout(() => {
      saveSuccess.value = false
    }, 3000)
  }, 300)
}
</script>
