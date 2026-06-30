<template>
  <aside class="w-64 bg-slate-900/40 backdrop-blur-md border-r border-white/10 text-slate-50 flex flex-col h-full shrink-0">

    <!-- SECCIÓN 1 — Logo/Brand -->
    <div class="h-16 flex items-center gap-3 px-5 border-b border-white/10 shrink-0">
      <div class="bg-primary/20 rounded-lg p-1.5">
        <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-primary-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="7" height="7"></rect>
          <rect x="14" y="3" width="7" height="7"></rect>
          <rect x="14" y="14" width="7" height="7"></rect>
          <rect x="3" y="14" width="7" height="7"></rect>
        </svg>
      </div>
      <span class="text-lg">
        <span class="font-bold text-slate-50">Orbit</span><span class="font-light text-primary-300">CRM</span>
      </span>
    </div>

    <!-- SECCIÓN 2 — Nav principal -->
    <nav class="flex-1 overflow-y-auto px-3 py-4">

      <!-- GRUPO: PRINCIPAL -->
      <div class="text-2xs font-semibold text-text-muted uppercase tracking-widest px-3 mb-2">
        Principal
      </div>

      <router-link
        to="/"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="7" height="7"></rect>
          <rect x="14" y="3" width="7" height="7"></rect>
          <rect x="14" y="14" width="7" height="7"></rect>
          <rect x="3" y="14" width="7" height="7"></rect>
        </svg>
        <span>Dashboard</span>
      </router-link>

      <router-link
        to="/leads"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
          <circle cx="12" cy="7" r="4"></circle>
        </svg>
        <span>Prospectos</span>
      </router-link>

      <router-link
        to="/deals"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
          <polyline points="9 22 9 12 15 12 15 22"></polyline>
        </svg>
        <span>Negocios</span>
      </router-link>

      <router-link
        to="/companies"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
          <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
        </svg>
        <span>Empresas</span>
      </router-link>

      <!-- GRUPO: GESTIÓN -->
      <div class="text-2xs font-semibold text-text-muted uppercase tracking-widest px-3 mt-6 mb-2">
        Gestión
      </div>

      <router-link
        to="/tasks"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="9 11 12 14 22 4"></polyline>
          <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path>
        </svg>
        <span>Tareas</span>
      </router-link>

      <router-link
        to="/quotes"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
          <polyline points="14 2 14 8 20 8"></polyline>
          <line x1="16" y1="13" x2="8" y2="13"></line>
          <line x1="16" y1="17" x2="8" y2="17"></line>
        </svg>
        <span>Cotizaciones</span>
      </router-link>

      <router-link
        to="/sales"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
          <polyline points="17 6 23 6 23 12"></polyline>
        </svg>
        <span>Ventas</span>
      </router-link>

      <router-link
        to="/activity"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <polyline points="12 6 12 12 16 14"></polyline>
        </svg>
        <span>Actividad</span>
      </router-link>

      <router-link
        v-if="isAdmin"
        to="/settings/providers"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon>
        </svg>
        <span>Integraciones</span>
      </router-link>

      <router-link
        v-if="isAdmin"
        to="/automation-center"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><rect x="9" y="9" width="6" height="6"></rect><line x1="9" y1="1" x2="9" y2="4"></line><line x1="15" y1="1" x2="15" y2="4"></line><line x1="9" y1="20" x2="9" y2="23"></line><line x1="15" y1="20" x2="15" y2="23"></line><line x1="20" y1="9" x2="23" y2="9"></line><line x1="20" y1="14" x2="23" y2="14"></line><line x1="1" y1="9" x2="4" y2="9"></line><line x1="1" y1="14" x2="4" y2="14"></line>
        </svg>
        <span>Automatizaciones</span>
      </router-link>

      <router-link
        v-if="isAdmin"
        to="/whatsapp"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.13 12.6 19.79 19.79 0 0 1 1.06 4a2 2 0 0 1 1.72-2.18h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
        </svg>
        <span>WhatsApp</span>
      </router-link>

    </nav>

    <!-- SECCIÓN 3 — Footer -->
    <div class="border-t border-white/10 px-3 py-4 shrink-0">
      <router-link
        v-if="isAdmin"
        to="/settings"
        class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-slate-400 hover:text-white hover:bg-slate-800/50"
        active-class="text-white bg-white/5 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="3"></circle>
          <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
        </svg>
        <span>Configuración</span>
      </router-link>
    </div>

  </aside>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { isAdmin as checkIsAdmin } from '../constants/roles'
import { AuthService } from '../services/auth.service'

const isAdmin = ref(false)

onMounted(async () => {
  // Fuente única de verdad: profiles.role (T-SEC-03)
  const role = await AuthService.getUserRole()
  isAdmin.value = checkIsAdmin(role)
})
</script>

<style scoped>
.router-link-active .active-dot {
  animation: pulse-dot 2s ease infinite;
}
</style>
