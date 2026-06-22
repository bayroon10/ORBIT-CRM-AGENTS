<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-primary/20 shadow-lg shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Sistema</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-text-main mb-2 tracking-tight">Configuración</h1>
          <p class="text-text-secondary text-sm">Ajustes generales, preferencias e información del espacio de trabajo.</p>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0">
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
          :class="activeTab === 'General' ? 'bg-primary/10 text-primary-300 border border-primary/20' : 'text-text-secondary hover:bg-surface-card hover:text-text-main border border-transparent'"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            General
          </div>
        </button>

        <router-link 
          to="/settings/providers"
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary hover:bg-surface-card hover:text-text-main border border-transparent transition-all"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
            Integraciones
          </div>
        </router-link>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
            Notificaciones
          </div>
          <span class="text-[10px] bg-surface-container px-2 py-0.5 rounded-full font-bold uppercase text-text-muted">Pronto</span>
        </div>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
            Seguridad
          </div>
          <span class="text-[10px] bg-surface-container px-2 py-0.5 rounded-full font-bold uppercase text-text-muted">Pronto</span>
        </div>

        <!-- Plan Info Card -->
        <div class="mt-6 p-5 rounded-2xl bg-gradient-to-br from-primary/10 to-primary/5 border border-primary/20 relative overflow-hidden">
          <div class="absolute -right-4 -top-4 w-16 h-16 bg-primary/20 rounded-full blur-xl pointer-events-none"></div>
          <div class="flex items-center gap-2 mb-2 relative z-10">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary-300"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
            <span class="text-xs font-bold text-primary-300 uppercase tracking-wide">Plan Profesional</span>
          </div>
          <p class="text-xs text-text-secondary leading-relaxed mb-4 relative z-10">
            Tienes acceso a todas las funcionalidades avanzadas. El próximo ciclo de facturación es el 15 de Noviembre.
          </p>
          <button class="w-full py-1.5 text-xs font-medium text-primary-300 hover:bg-primary/10 rounded-lg transition-colors border border-primary/20 relative z-10">
            Gestionar Plan
          </button>
        </div>
      </aside>

      <!-- Panel de Contenido -->
      <BaseCard :padded="false" class="flex-1 flex flex-col h-fit max-w-3xl overflow-hidden">
        <div class="p-6 border-b border-border flex items-center justify-between bg-surface-container">
          <div>
            <h2 class="text-xl font-bold text-text-main">Ajustes Generales</h2>
            <p class="text-sm text-text-secondary mt-1">Configura las preferencias de tu espacio de trabajo.</p>
          </div>
          <BaseButton @click="saveSettings">Guardar cambios</BaseButton>
        </div>

        <div class="p-6 space-y-8">
          <!-- Sección: Perfil del Espacio -->
          <div>
            <h3 class="text-base font-semibold text-text-main mb-4 flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-text-muted"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
              Perfil del Espacio
            </h3>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="col-span-1 md:col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1.5">Nombre del sistema *</label>
                <input 
                  v-model="form.systemName"
                  type="text" 
                  class="w-full bg-surface border border-border rounded-lg px-4 py-2.5 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
                  placeholder="Ej: Orbit CRM"
                />
              </div>
            </div>
          </div>

          <hr class="border-border" />

          <!-- Sección: Preferencias Regionales -->
          <div>
            <h3 class="text-base font-semibold text-text-main mb-4 flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-text-muted"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
              Preferencias Regionales
            </h3>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-text-main mb-1.5">Zona horaria</label>
                <div class="relative">
                  <select 
                    v-model="form.timezone"
                    class="appearance-none w-full bg-surface border border-border rounded-lg px-4 py-2.5 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all cursor-pointer"
                  >
                    <option value="America/Santiago">(GMT-04:00) Santiago</option>
                    <option value="America/Bogota">(GMT-05:00) Bogotá, Lima, Quito</option>
                    <option value="America/Mexico_City">(GMT-06:00) Ciudad de México</option>
                    <option value="America/Buenos_Aires">(GMT-03:00) Buenos Aires</option>
                  </select>
                  <svg class="absolute right-3 top-3 pointer-events-none text-text-muted" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-text-main mb-1.5">Idioma y Formato</label>
                <div class="relative">
                  <select 
                    v-model="form.locale"
                    class="appearance-none w-full bg-surface-container border border-border rounded-lg px-4 py-2.5 text-sm text-text-secondary focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all cursor-not-allowed"
                    disabled
                  >
                    <option value="es-CL">Español (Chile) - es-CL</option>
                  </select>
                  <svg class="absolute right-3 top-3 pointer-events-none text-text-muted opacity-50" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                </div>
                <p class="text-xs text-text-muted mt-1.5">El formato de moneda y fechas utiliza la configuración local es-CL.</p>
              </div>
            </div>
          </div>
          
          <hr class="border-border" />
          
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
      </BaseCard>

    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const activeTab = ref('General')
const loading = ref(true)
const error = ref(null)
const saveSuccess = ref(false)
const settingsId = ref(null)

const form = reactive({
  systemName: 'Orbit CRM',
  timezone: 'America/Santiago',
  locale: 'es-CL'
})

onMounted(async () => {
  loading.value = true
  error.value = null
  
  try {
    const { data, error: fetchError } = await supabase
      .from('workspace_settings')
      .select('*')
      .limit(1)
      .single()
      
    if (fetchError) {
      if (fetchError.code !== 'PGRST116') {
        throw fetchError
      }
      // Si no existe, podemos mantener los valores por defecto
    } else if (data) {
      settingsId.value = data.id
      form.systemName = data.system_name || form.systemName
      form.timezone = data.timezone || form.timezone
      form.locale = data.locale || form.locale
    }
  } catch (err) {
    console.error('Error fetching settings:', err)
    error.value = 'Ocurrió un error al cargar la configuración.'
  } finally {
    loading.value = false
  }
})

const saveSettings = async () => {
  error.value = null
  saveSuccess.value = false
  
  if (!form.systemName.trim()) {
    error.value = 'El nombre del sistema es obligatorio.'
    return
  }

  try {
    const payload = {
      system_name: form.systemName,
      timezone: form.timezone,
      locale: form.locale,
      updated_at: new Date().toISOString()
    }
    
    let dbError = null
    
    if (settingsId.value) {
      const { error: err } = await supabase
        .from('workspace_settings')
        .update(payload)
        .eq('id', settingsId.value)
      dbError = err
    } else {
      // Si por alguna razon no habia ID, esto fallaria por politicas, pero en RLS admin no puede insertar.
      error.value = 'No se encontró el ID de configuración (falta migración en DB).'
      return
    }

    if (dbError) throw dbError

    saveSuccess.value = true
    setTimeout(() => {
      saveSuccess.value = false
    }, 3000)
    
  } catch (err) {
    console.error('Error saving settings:', err)
    // Para RLS: code 42501 (Insufficient Privilege) o si es que postgrest solo devuelve 0 rows
    error.value = 'No tienes permisos suficientes para modificar la configuración general o hubo un problema al guardar.'
  }
}
</script>
