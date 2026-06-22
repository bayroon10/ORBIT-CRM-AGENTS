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

    <div class="flex flex-col md:flex-row gap-8 flex-1 pb-16">
      
      <!-- Nav Lateral -->
      <aside class="w-full md:w-64 shrink-0 flex flex-col gap-2">
        <button 
          @click="router.push({ name: 'Settings' })"
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-text-secondary hover:bg-surface-card hover:text-text-main border border-transparent transition-all"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            General
          </div>
        </button>

        <button 
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-all bg-primary/10 text-primary-300 border border-primary/20"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            Usuarios y Permisos
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
      <BaseCard :padded="false" class="flex-1 flex flex-col h-fit overflow-hidden">
        <div class="p-6 border-b border-border flex flex-col sm:flex-row sm:items-center justify-between bg-surface-container gap-4">
          <div>
            <h2 class="text-xl font-bold text-text-main">Usuarios y Permisos</h2>
            <p class="text-sm text-text-secondary mt-1">Gestiona el acceso de tu equipo al sistema.</p>
          </div>
          <BaseButton class="shrink-0">
            <template #icon>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="23" y1="11" x2="17" y2="11"></line></svg>
            </template>
            Invitar Usuario
          </BaseButton>
        </div>

        <div class="px-6 py-2 border-b border-border flex gap-6 bg-surface-container">
          <button class="py-3 border-b-2 border-primary text-primary-300 font-semibold text-sm">Usuarios Activos</button>
          <button class="py-3 border-b-2 border-transparent text-text-secondary hover:text-text-main font-medium text-sm transition-colors">Roles y Definiciones</button>
        </div>

        <div class="flex-1 flex flex-col">
          <!-- Toolbar -->
          <div class="p-4 border-b border-border flex justify-between items-center bg-surface shrink-0">
            <div class="relative w-64">
              <input 
                type="text" 
                placeholder="Buscar usuarios..." 
                class="w-full pl-10 pr-4 py-2 bg-surface-card border border-border rounded-lg text-sm text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
              />
              <div class="absolute left-3 top-2.5 text-text-muted">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
              </div>
            </div>
            <button class="flex items-center gap-2 px-3 py-2 border border-border rounded-lg text-text-secondary hover:bg-surface-card hover:text-text-main text-sm font-medium transition-colors">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg>
              Filtros
            </button>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            <p class="text-sm text-text-secondary">Cargando usuarios...</p>
          </div>

          <!-- Empty State -->
          <div v-else-if="users.length === 0" class="py-16 flex-1 flex items-center justify-center">
            <OrbitEmptyState 
              title="No hay usuarios" 
              description="No se encontraron usuarios registrados en el sistema."
            />
          </div>

          <!-- Data Table -->
          <div v-else class="overflow-y-auto flex-1">
            <table class="w-full text-left text-sm">
              <thead class="bg-surface-container text-text-muted font-semibold sticky top-0 z-10">
                <tr>
                  <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs">Usuario</th>
                  <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs">Rol Asignado</th>
                  <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs">Estado</th>
                  <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs">Último Acceso</th>
                  <th class="px-6 py-4 border-b border-border uppercase tracking-wider text-xs text-right">Acciones</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-border">
                <tr v-for="user in users" :key="user.id" class="hover:bg-surface-container/60 transition-colors group">
                  <td class="px-6 py-4">
                    <div class="flex items-center gap-3">
                      <div class="w-8 h-8 rounded-full bg-surface-card flex items-center justify-center border border-border text-xs font-bold text-text-muted">
                        {{ getInitials(user.full_name) }}
                      </div>
                      <div>
                        <div class="font-semibold text-text-main">{{ user.full_name || 'Usuario sin nombre' }}</div>
                        <div class="text-xs text-text-secondary">{{ user.email || '—' }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4">
                    <BaseBadge :variant="getRoleVariant(user.role)">
                      {{ translateRole(user.role) }}
                    </BaseBadge>
                  </td>
                  <td class="px-6 py-4">
                    <span class="flex items-center gap-1.5 text-xs font-medium text-success">
                      <span class="w-2 h-2 rounded-full bg-success"></span>
                      Activo
                    </span>
                  </td>
                  <td class="px-6 py-4 text-text-secondary whitespace-nowrap">
                    {{ formatDate(user.updated_at || user.created_at) }}
                  </td>
                  <td class="px-6 py-4 text-right">
                    <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button class="p-1.5 text-text-muted hover:text-primary-300 rounded hover:bg-surface-card transition-colors" title="Editar">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                      </button>
                      <button class="p-1.5 text-text-muted hover:text-danger rounded hover:bg-danger/10 transition-colors" title="Eliminar">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

      </BaseCard>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

const router = useRouter()
const users = ref([])
const loading = ref(true)
const error = ref(null)

const fetchUsers = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('profiles')
      .select('*')
      .order('full_name', { ascending: true })
      
    if (err) throw err
    users.value = data || []
  } catch (err) {
    console.error('Error fetching users:', err)
    error.value = 'Ocurrió un error al cargar los usuarios.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchUsers()
})

const getInitials = (name) => {
  if (!name) return 'U'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const translateRole = (role) => {
  const map = {
    'admin': 'Administrador',
    'seller': 'Vendedor'
  }
  return map[role?.toLowerCase()] || (role || 'Usuario')
}

const getRoleVariant = (role) => {
  const r = role?.toLowerCase()
  if (r === 'admin') return 'primary'
  return 'default'
}

const formatDate = (dateString) => {
  if (!dateString) return 'Nunca'
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(new Date(dateString))
}
</script>
