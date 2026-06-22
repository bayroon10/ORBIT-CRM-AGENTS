<template>
  <header class="h-16 bg-surface-container border-b border-border flex items-center justify-between px-6 shrink-0">
    <!-- Breadcrumb -->
    <div class="text-text-secondary text-sm">
      <span>Orbit CRM</span>
      <span class="mx-2 text-border-strong">/</span>
      <span class="font-medium text-text-main">{{ currentRouteName }}</span>
    </div>

    <!-- Right Side: User Avatar & Logout -->
    <div class="flex items-center gap-3">
      <div
        class="w-8 h-8 bg-primary/20 border border-primary/30 text-primary-300 rounded-full flex items-center justify-center font-semibold text-sm cursor-default"
        :title="userEmail"
      >
        {{ userInitials }}
      </div>
      <button
        @click="handleLogout"
        class="text-sm text-text-secondary hover:text-danger font-medium transition-colors px-2 py-1 rounded-lg hover:bg-danger/10"
      >
        Salir
      </button>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const route = useRoute()
const router = useRouter()

const userEmail = ref('')
const userInitials = ref('U')

const routeNames = {
  Dashboard:    'Inicio',
  Leads:        'Prospectos',
  LeadDetail:   'Detalle de Prospecto',
  Deals:        'Negocios',
  DealDetail:   'Detalle de Negocio',
  Companies:    'Empresas',
  Tasks:        'Tareas',
  Activity:     'Actividad',
  Quotes:       'Cotizaciones',
  QuoteForm:    'Nueva Cotización',
  Sales:        'Ventas',
  Settings:     'Configuración',
  SettingsUsers:'Usuarios',
}

const currentRouteName = computed(() => routeNames[route.name] || route.name || '')

const fetchUser = async () => {
  try {
    const { data, error } = await supabase.auth.getUser()
    if (error || !data?.user) return
    const user = data.user
    userEmail.value = user.email || ''
    const fullName = user.user_metadata?.full_name
    if (fullName) {
      const words = fullName.trim().split(/\s+/)
      if (words.length >= 2) {
        userInitials.value = (words[0][0] + words[1][0]).toUpperCase()
      } else if (words.length === 1 && words[0].length > 0) {
        userInitials.value = words[0].substring(0, 2).toUpperCase()
      }
    } else if (userEmail.value) {
      const prefix = userEmail.value.split('@')[0]
      userInitials.value = prefix.length >= 2
        ? prefix.substring(0, 2).toUpperCase()
        : prefix.toUpperCase()
    }
  } catch (err) {
    console.error('Error fetching user:', err)
  }
}

const handleLogout = async () => {
  await supabase.auth.signOut()
  router.push({ name: 'Login' })
}

onMounted(() => fetchUser())
</script>
