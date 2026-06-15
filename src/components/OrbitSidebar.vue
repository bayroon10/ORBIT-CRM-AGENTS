<template>
  <aside class="w-64 bg-gray-950 text-white flex flex-col h-full shrink-0 shadow-xl">

    <!-- SECCIÓN 1 — Logo/Brand -->
    <div class="h-16 flex items-center gap-3 px-5 border-b border-white/10">
      <div class="bg-blue-500/20 rounded-lg p-1.5">
        <svg xmlns="http://www.w3.org/2000/svg" class="w-7 h-7 text-blue-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="7" height="7"></rect>
          <rect x="14" y="3" width="7" height="7"></rect>
          <rect x="14" y="14" width="7" height="7"></rect>
          <rect x="3" y="14" width="7" height="7"></rect>
        </svg>
      </div>
      <span class="text-lg">
        <span class="font-bold text-white">Orbit</span><span class="font-light text-blue-400">CRM</span>
      </span>
    </div>

    <!-- SECCIÓN 2 — Nav principal -->
    <nav class="flex-1 overflow-y-auto px-3 py-4">

      <!-- GRUPO: PRINCIPAL -->
      <div class="text-[10px] font-semibold text-gray-500 uppercase tracking-widest px-3 mb-2">
        Principal
      </div>

      <router-link
        to="/"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
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
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
          <circle cx="12" cy="7" r="4"></circle>
        </svg>
        <span>Prospectos</span>
      </router-link>

      <router-link
        to="/deals"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
          <polyline points="9 22 9 12 15 12 15 22"></polyline>
        </svg>
        <span>Negocios</span>
      </router-link>

      <router-link
        to="/companies"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
          <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
        </svg>
        <span>Empresas</span>
      </router-link>

      <!-- GRUPO: GESTIÓN -->
      <div class="text-[10px] font-semibold text-gray-500 uppercase tracking-widest px-3 mt-6 mb-2">
        Gestión
      </div>

      <router-link
        to="/tasks"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="9 11 12 14 22 4"></polyline>
          <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path>
        </svg>
        <span>Tareas</span>
      </router-link>

      <router-link
        to="/quotes"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
          <polyline points="14 2 14 8 20 8"></polyline>
          <line x1="16" y1="13" x2="8" y2="13"></line>
          <line x1="16" y1="17" x2="8" y2="17"></line>
          <polyline points="10 9 9 9 8 9"></polyline>
        </svg>
        <span>Cotizaciones</span>
      </router-link>

      <router-link
        to="/sales"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
          <polyline points="17 6 23 6 23 12"></polyline>
        </svg>
        <span>Ventas</span>
      </router-link>

      <router-link
        to="/activity"
        class="nav-link flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <polyline points="12 6 12 12 16 14"></polyline>
        </svg>
        <span>Actividad</span>
      </router-link>

    </nav>

    <!-- SECCIÓN 3 — Footer -->
    <div class="border-t border-white/10 px-3 py-4">
      <router-link
        to="/settings"
        class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all duration-150 text-gray-400 hover:text-white hover:bg-white/8"
        active-class="text-white bg-blue-600/20 font-medium"
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

<style scoped>
/* Dot indicador activo animado */
.router-link-active .active-dot {
  animation: pulse-dot 2s ease infinite;
}
</style>
