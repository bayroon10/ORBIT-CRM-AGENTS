<template>
  <main class="w-full max-w-[400px] flex flex-col gap-6 animate-in fade-in duration-700 mx-auto">
    <!-- Header / Logo -->
    <header class="flex flex-col items-center gap-1">
      <h1 class="text-3xl font-bold text-primary">Orbit CRM</h1>
      <p class="text-sm font-medium text-text-secondary">Accede a tu cuenta</p>
    </header>

    <!-- Main Card -->
    <div class="bg-slate-900/40 p-8 rounded-2xl shadow-2xl border border-white/10 backdrop-blur-md relative overflow-hidden">
      <!-- Glow effect inside card -->
      <div class="absolute -top-16 -right-16 w-32 h-32 rounded-full opacity-20 bg-primary blur-3xl pointer-events-none"></div>
      
      <!-- Error State -->
      <div v-if="errorMsg" class="mb-6 flex items-start gap-2 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10">
        <svg class="w-5 h-5 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="leading-snug">{{ errorMsg }}</span>
      </div>

      <form @submit.prevent="handleLogin" class="flex flex-col gap-5">
        <!-- Email Field -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold tracking-wide text-slate-400 uppercase" for="email">Correo electrónico</label>
          <input 
            v-model="email"
            id="email" 
            type="email" 
            required
            autocomplete="username email"
            placeholder="nombre@empresa.com"
            class="w-full h-11 px-4 rounded-lg border border-white/10 bg-slate-950/50 focus:bg-slate-900/80 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all text-sm text-slate-50"
            :disabled="loading"
          />
        </div>

        <!-- Password Field -->
        <div class="flex flex-col gap-1.5">
          <div class="flex justify-between items-end">
            <label class="text-xs font-semibold tracking-wide text-slate-400 uppercase" for="password">Contraseña</label>
            <a href="#" class="text-xs font-medium text-primary hover:text-primary-variant transition-colors">¿Problemas para entrar?</a>
          </div>
          <div class="relative">
            <input 
              v-model="password"
              id="password" 
              :type="showPassword ? 'text' : 'password'" 
              required
              autocomplete="current-password"
              placeholder="••••••••"
              class="w-full h-11 px-4 pr-20 rounded-lg border border-white/10 bg-slate-950/50 focus:bg-slate-900/80 focus:border-primary focus:ring-1 focus:ring-primary outline-none transition-all text-sm text-slate-50"
              :disabled="loading"
            />
            <button 
              type="button" 
              @click="showPassword = !showPassword"
              class="absolute right-3 top-1/2 -translate-y-1/2 flex items-center gap-1 text-slate-400 hover:text-primary transition-colors"
            >
              <svg v-if="!showPassword" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
              </svg>
              <svg v-else class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
              </svg>
              <span class="text-xs font-medium">{{ showPassword ? 'Ocultar' : 'Ver' }}</span>
            </button>
          </div>
        </div>

        <!-- Submit Button -->
        <button 
          type="submit" 
          :disabled="loading"
          class="mt-3 w-full h-11 bg-primary btn-glow text-white hover:bg-primary-variant active:scale-[0.98] transition-all rounded-lg font-medium flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed"
        >
          <svg v-if="loading" class="animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span>{{ loading ? 'Conectando...' : 'Iniciar sesión' }}</span>
        </button>
      </form>

      <!-- Footer / Alternatives -->
      <div class="mt-8 flex flex-col gap-4">
        <div class="relative flex items-center">
          <div class="flex-grow border-t border-white/10"></div>
          <span class="mx-4 text-slate-400 text-xs uppercase tracking-widest font-semibold">Solo Acceso Privado</span>
          <div class="flex-grow border-t border-white/10"></div>
        </div>
        <p class="text-center text-xs text-slate-400 mt-2 leading-relaxed">
          Si no tienes credenciales de acceso, por favor contacta al administrador de tu instancia de Orbit CRM.
        </p>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'

const router = useRouter()
const route = useRoute()

const email = ref('')
const password = ref('')
const showPassword = ref(false)
const loading = ref(false)
const errorMsg = ref('')

const handleLogin = async () => {
  errorMsg.value = ''

  const cleanEmail = email.value.trim()
  const cleanPassword = password.value

  if (!cleanEmail || !cleanPassword) {
    errorMsg.value = 'Por favor completa ambos campos.'
    return
  }

  loading.value = true
  
  try {
    const { error } = await supabase.auth.signInWithPassword({
      email: cleanEmail,
      password: cleanPassword,
    })

    if (error) {
      console.error('Supabase auth error:', error)
      // Traducción simplificada y robusta de errores comunes
      if (error.message.includes('Invalid login credentials')) {
        errorMsg.value = 'El correo o la contraseña son incorrectos.'
      } else if (error.message.includes('Email not confirmed')) {
        errorMsg.value = 'Debes confirmar tu correo antes de iniciar sesión.'
      } else {
        errorMsg.value = 'Credenciales incorrectas o error en el servicio de autenticación.'
      }
    } else {
      const redirectPath = route.query.redirect
      
      // Sanitización del path para prevenir vulnerabilidades de redirección abierta (Open Redirect)
      if (redirectPath && typeof redirectPath === 'string' && redirectPath.startsWith('/')) {
        router.replace(redirectPath)
      } else {
        router.replace({ name: 'Dashboard' })
      }
    }
  } catch (err) {
    console.error('Network or unexpected auth error:', err)
    errorMsg.value = 'Error de conexión. Por favor verifica tu acceso a internet.'
  } finally {
    loading.value = false
  }
}
</script>

