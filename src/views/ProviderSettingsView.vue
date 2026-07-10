<template>
  <div class="flex flex-col h-full relative overflow-x-hidden">
    <!-- Hero Header -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-white/10 shadow-2xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Sistema</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-slate-50 mb-2 tracking-tight">Configuración</h1>
          <p class="text-slate-400 text-sm">Ajustes generales, preferencias e información del espacio de trabajo.</p>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0 flex justify-between items-center">
      <span>{{ error }}</span>
      <button @click="error = null" class="text-danger hover:text-danger/80">×</button>
    </div>

    <div class="flex flex-col md:flex-row gap-8 flex-1 pb-16">
      
      <!-- Nav Lateral -->
      <aside class="w-full md:w-64 shrink-0 flex flex-col gap-2">
        <button 
          @click="router.push({ name: 'Settings' })"
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-slate-400 hover:bg-slate-800/50 hover:text-slate-50 border border-transparent transition-all"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
            General
          </div>
        </button>

        <button 
          @click="router.push({ name: 'SettingsUsers' })"
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-slate-400 hover:bg-slate-800/50 hover:text-slate-50 border border-transparent transition-all"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            Usuarios y Permisos
          </div>
        </button>

        <button 
          class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium transition-all bg-primary-500/20 text-primary-300 border border-primary-500/30"
        >
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
            Integraciones
          </div>
        </button>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-slate-400 opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>
            Notificaciones
          </div>
          <span class="text-[10px] bg-slate-900/50 border border-white/10 px-2 py-0.5 rounded-full font-bold uppercase text-slate-500">Pronto</span>
        </div>

        <div class="flex items-center justify-between px-4 py-3 rounded-xl text-sm font-medium text-slate-400 opacity-60 cursor-not-allowed border border-transparent">
          <div class="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
            Seguridad
          </div>
          <span class="text-[10px] bg-slate-900/50 border border-white/10 px-2 py-0.5 rounded-full font-bold uppercase text-slate-500">Pronto</span>
        </div>

        <!-- Plan Info Card -->
        <div class="mt-6 p-5 rounded-2xl bg-slate-800/50 border border-white/10 relative overflow-hidden">
          <div class="absolute -right-4 -top-4 w-16 h-16 bg-primary/20 rounded-full blur-xl pointer-events-none"></div>
          <div class="flex items-center gap-2 mb-2 relative z-10">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary-300"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
            <span class="text-xs font-bold text-primary-300 uppercase tracking-wide">Plan Profesional</span>
          </div>
          <p class="text-xs text-slate-400 leading-relaxed mb-4 relative z-10">
            Tienes acceso a todas las funcionalidades avanzadas. El próximo ciclo de facturación es el 15 de Noviembre.
          </p>
          <button class="w-full py-1.5 text-xs font-medium text-primary-300 hover:bg-primary/10 rounded-lg transition-colors border border-primary/20 relative z-10">
            Gestionar Plan
          </button>
        </div>
      </aside>

      <!-- Panel de Contenido -->
      <BaseCard :padded="false" class="flex-1 flex flex-col h-fit overflow-hidden max-w-4xl">
        <div class="p-6 border-b border-white/10 flex flex-col sm:flex-row sm:items-center justify-between bg-slate-900/50 gap-4">
          <div>
            <h2 class="text-xl font-bold text-slate-50">Integraciones (Providers)</h2>
            <p class="text-sm text-slate-400 mt-1">Gestiona las API keys para servicios externos (OpenAI, Gemini, n8n, etc).</p>
          </div>
          <BaseButton class="shrink-0" @click="showAddModal = true">
            <template #icon>
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            </template>
            Agregar Credencial
          </BaseButton>
        </div>

        <div class="px-6 py-2 border-b border-white/10 flex gap-6 bg-slate-900/50">
          <button class="py-3 border-b-2 border-primary text-primary-300 font-semibold text-sm">Credenciales Activas</button>
          <button class="py-3 border-b-2 border-transparent text-slate-400 hover:text-slate-50 font-medium text-sm transition-colors">Logs de Uso</button>
        </div>

        <div class="flex-1 flex flex-col">
          <!-- Loading State -->
          <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            <p class="text-sm text-slate-400">Cargando integraciones...</p>
          </div>

          <!-- Empty State -->
          <div v-else-if="providers.length === 0" class="py-16 flex-1 flex items-center justify-center">
            <div class="text-center">
              <div class="bg-slate-800/50 w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-white/10">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-slate-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
              </div>
              <h3 class="text-lg font-bold text-slate-50 mb-2">No hay integraciones</h3>
              <p class="text-slate-400 text-sm max-w-sm mx-auto mb-6">No has agregado ninguna API Key. Agrega una credencial para automatizar flujos con IA y webhooks.</p>
              <BaseButton @click="showAddModal = true">Agregar Credencial</BaseButton>
            </div>
          </div>

          <!-- Data Table -->
          <div v-else class="overflow-y-auto flex-1 p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div v-for="item in providers" :key="item.id" class="p-4 rounded-xl border border-white/10 bg-slate-900/40 backdrop-blur-sm hover:border-primary/30 transition-colors group">
                <div class="flex justify-between items-start mb-4">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-lg bg-slate-800/50 border border-white/10 flex items-center justify-center shrink-0">
                      <svg v-if="item.provider === 'OpenAI'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-emerald-400"><path d="M12 2v20"></path><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                      <svg v-else-if="item.provider === 'Gemini'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-400"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                      <svg v-else-if="item.provider === 'Claude'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-orange-400"><circle cx="12" cy="12" r="10"></circle><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>
                      <svg v-else-if="item.provider === 'WhatsApp'" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-green-500"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                      <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-primary-300"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
                    </div>
                    <div>
                      <h4 class="font-bold text-slate-50 text-sm">{{ item.provider }}</h4>
                      <p class="text-xs text-slate-400">{{ item.label || 'Sin etiqueta' }}</p>
                    </div>
                  </div>
                  <div class="flex items-center gap-2">
                    <BaseBadge :variant="item.is_active ? 'success' : 'default'">{{ item.is_active ? 'Activo' : 'Inactivo' }}</BaseBadge>
                    <button @click="deleteProvider(item.id)" class="p-1.5 text-slate-400 hover:text-danger rounded hover:bg-danger/10 transition-colors opacity-0 group-hover:opacity-100" title="Eliminar">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                    </button>
                  </div>
                </div>

                <div class="bg-slate-900/50 rounded-lg p-3 border border-white/5">
                  <div class="flex items-center justify-between">
                    <div class="text-xs text-slate-500 font-medium uppercase tracking-wider mb-1">Clave (Oculta por seguridad)</div>
                  </div>
                  <div class="font-mono text-sm text-slate-400 mt-1 tracking-widest break-all">
                    {{ item.masked_credential || '••••••••••••' }}
                  </div>
                </div>
                
                <div class="mt-4 flex items-center justify-between text-xs text-slate-500">
                  <span>Creado: {{ formatDate(item.created_at) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- === SECCIÓN WHATSAPP === -->
          <div class="px-6 pb-6">
            <div class="mt-6 pt-6 border-t border-white/10">
              <div class="flex items-center gap-3 mb-1">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-green-500"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                <h3 class="text-sm font-semibold text-slate-50">WhatsApp Business</h3>
              </div>
              <p class="text-xs text-slate-400 mb-4 ml-7">
                Conecta tu número para que el agente IA responda mensajes automáticamente.
              </p>

              <!-- Estado de conexión -->
              <div class="flex items-center gap-2 mb-4 ml-7">
                <div
                  class="w-2 h-2 rounded-full"
                  :class="whatsappConnected ? 'bg-green-500' : 'bg-slate-600'"
                ></div>
                <span class="text-xs text-slate-400">
                  {{ whatsappConnected ? 'Conectado y activo' : 'No configurado' }}
                </span>
              </div>

              <!-- Formulario de credenciales -->
              <div class="space-y-3 max-w-md">
                <div>
                  <label class="text-xs text-slate-400 block mb-1">Access Token de Meta</label>
                  <input
                    id="wa-access-token-input"
                    v-model="waAccessToken"
                    type="password"
                    placeholder="EAAxxxxxxx..."
                    class="w-full px-3 py-2 text-sm bg-slate-900/40 border border-white/10 rounded-lg text-slate-50 placeholder:text-slate-600 focus:outline-none focus:border-indigo-500/50 transition-colors"
                  />
                </div>
                <div>
                  <label class="text-xs text-slate-400 block mb-1">Phone Number ID</label>
                  <input
                    id="wa-phone-number-id-input"
                    v-model="waPhoneNumberId"
                    type="text"
                    placeholder="1234567890"
                    class="w-full px-3 py-2 text-sm bg-slate-900/40 border border-white/10 rounded-lg text-slate-50 placeholder:text-slate-600 focus:outline-none focus:border-indigo-500/50 transition-colors"
                  />
                </div>
                <div>
                  <label class="text-xs text-slate-400 block mb-1">Verify Token (para webhook)</label>
                  <input
                    id="wa-verify-token-input"
                    v-model="waVerifyToken"
                    type="text"
                    placeholder="orbit_whatsapp_verify"
                    class="w-full px-3 py-2 text-sm bg-slate-900/40 border border-white/10 rounded-lg text-slate-50 placeholder:text-slate-600 focus:outline-none focus:border-indigo-500/50 transition-colors"
                  />
                </div>

                <!-- Webhook URL para Meta -->
                <div class="p-3 bg-indigo-500/5 border border-indigo-500/20 rounded-lg">
                  <p class="text-xs text-slate-400 mb-1">URL del Webhook (configurar en Meta Developer)</p>
                  <code class="text-xs text-indigo-400 break-all select-all">
                    https://alfalfa-excusably-zestfully.ngrok-free.dev/webhook/whatsapp-agent
                  </code>
                </div>

                <div class="flex gap-2 pt-1">
                  <button
                    id="wa-save-config-btn"
                    @click="saveWhatsAppConfig"
                    :disabled="savingWa"
                    class="px-4 py-2 text-sm font-medium bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {{ savingWa ? 'Guardando...' : 'Guardar configuración' }}
                  </button>
                  <button
                    id="wa-inbox-link-btn"
                    @click="router.push({ name: 'WhatsAppInbox' })"
                    class="px-4 py-2 text-sm font-medium text-slate-300 bg-slate-800/50 border border-white/10 rounded-lg hover:bg-slate-700/50 transition-colors"
                  >
                    Ver Inbox →
                  </button>
                </div>

                <!-- Feedback -->
                <p v-if="waSaveSuccess" class="text-xs text-green-400">✓ Configuración guardada correctamente</p>
                <p v-if="waSaveError" class="text-xs text-red-400">{{ waSaveError }}</p>
              </div>
            </div>
          </div>
        </div>
      </BaseCard>
    </div>

    <!-- Modal de Creación -->
    <OrbitModal v-model="showAddModal" title="Agregar Credencial">
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1.5">Proveedor *</label>
          <div class="relative">
            <select 
              v-model="newForm.providerSelect"
              class="appearance-none w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-4 py-2.5 text-sm text-slate-50 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all cursor-pointer [&>option]:bg-slate-900 [&>option]:text-slate-50"
            >
              <option value="" disabled>Selecciona un proveedor</option>
              <option value="Gemini">Gemini (Google AI)</option>
              <option value="OpenAI">OpenAI</option>
              <option value="Claude">Claude (Anthropic)</option>
              <option value="WhatsApp">WhatsApp Business API</option>
              <option value="n8n Webhook">n8n Webhook</option>
              <option value="Otro">Otro / Personalizado</option>
            </select>
            <svg class="absolute right-3 top-3 pointer-events-none text-slate-500" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
          </div>
        </div>

        <div v-if="newForm.providerSelect === 'Otro'">
          <label class="block text-sm font-medium text-slate-50 mb-1.5">Nombre del proveedor *</label>
          <input 
            v-model="newForm.customProvider"
            type="text" 
            class="w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-4 py-2.5 text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all"
            placeholder="Ej: Resend, Stripe..."
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1.5">Etiqueta (Opcional)</label>
          <input 
            v-model="newForm.label"
            type="text" 
            class="w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-4 py-2.5 text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all"
            placeholder="Ej: Key de Producción"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-50 mb-1.5">Clave / Token *</label>
          <input 
            v-model="newForm.credentialValue"
            type="password" 
            class="w-full bg-slate-900/40 backdrop-blur-sm border border-white/10 rounded-lg px-4 py-2.5 text-sm text-slate-50 placeholder:text-slate-500 focus:outline-none focus:ring-1 focus:ring-primary/50 focus:border-primary transition-all"
            placeholder="Pega la API Key aquí..."
          />
          <p class="text-xs text-slate-500 mt-2">La clave se cifrará al guardar. Por seguridad, el sistema nunca la devolverá completa al navegador.</p>
        </div>
      </div>
      <template #footer>
        <div class="flex justify-end gap-3 w-full">
          <BaseButton variant="default" @click="showAddModal = false">Cancelar</BaseButton>
          <BaseButton variant="primary" :disabled="!isFormValid || saving" @click="saveProvider">
            {{ saving ? 'Guardando...' : 'Guardar Credencial' }}
          </BaseButton>
        </div>
      </template>
    </OrbitModal>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { whatsappService } from '../services/whatsapp.service'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'
import OrbitModal from '../components/OrbitModal.vue'

const router = useRouter()
const providers = ref([])
const loading = ref(true)
const error = ref(null)
const showAddModal = ref(false)
const saving = ref(false)

const newForm = reactive({
  providerSelect: '',
  customProvider: '',
  label: '',
  credentialValue: ''
})

const isFormValid = computed(() => {
  const hasProvider = newForm.providerSelect === 'Otro' ? !!newForm.customProvider.trim() : !!newForm.providerSelect;
  return hasProvider && !!newForm.credentialValue.trim()
})

const fetchProviders = async () => {
  loading.value = true
  error.value = null
  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) throw new Error('No session active')

    // Importante: explicitamos las columnas seguras
    const { data, error: err } = await supabase
      .from('provider_settings')
      .select('id, provider, label, credential_type, is_active, created_at, last_used_at, user_id')
      .order('created_at', { ascending: false })
      
    if (err) throw err
    
    const providersList = data || []
    
    for (const item of providersList) {
      try {
        const { data: maskedData, error: rpcErr } = await supabase.rpc('get_masked_credential', { setting_id: item.id })
        if (rpcErr) throw rpcErr
        item.masked_credential = maskedData
      } catch (rpcError) {
        console.error('Error fetching masked credential for id', item.id, rpcError)
        item.masked_credential = '— No disponible —'
      }
    }

    providers.value = providersList
  } catch (err) {
    console.error('Error fetching providers:', err)
    error.value = err.message || 'Ocurrió un error al cargar las integraciones.'
  } finally {
    loading.value = false
  }
}

// === WhatsApp refs ===
const whatsappConnected = ref(false)
const waAccessToken = ref('')
const waPhoneNumberId = ref('')
const waVerifyToken = ref('orbit_whatsapp_verify')
const savingWa = ref(false)
const waSaveSuccess = ref(false)
const waSaveError = ref(null)

async function loadWhatsAppConfig() {
  try {
    const cred = await whatsappService.getWhatsAppCredential()
    if (cred) {
      whatsappConnected.value = cred.is_active
      // Extraer phone_number_id y verify_token del label si fue guardado así
      const labelParts = (cred.label || '').match(/Phone ID: (\S+) \| Verify: (\S+)/)
      if (labelParts) {
        waPhoneNumberId.value = labelParts[1]
        waVerifyToken.value = labelParts[2]
      }
      // No pre-cargar el token por seguridad
    }
  } catch (e) {
    console.error('Error cargando config WhatsApp:', e)
  }
}

async function saveWhatsAppConfig() {
  if (!waAccessToken.value || !waPhoneNumberId.value) {
    waSaveError.value = 'Access Token y Phone Number ID son requeridos'
    return
  }
  try {
    savingWa.value = true
    waSaveError.value = null
    waSaveSuccess.value = false
    await whatsappService.saveWhatsAppCredential(
      waAccessToken.value,
      waPhoneNumberId.value,
      waVerifyToken.value
    )
    waSaveSuccess.value = true
    whatsappConnected.value = true
    waAccessToken.value = '' // Limpiar por seguridad
    setTimeout(() => { waSaveSuccess.value = false }, 3000)
    await fetchProviders()
  } catch (e) {
    waSaveError.value = e.message
  } finally {
    savingWa.value = false
  }
}

onMounted(() => {
  fetchProviders()
  loadWhatsAppConfig()
})

const saveProvider = async () => {
  if (!isFormValid.value) return
  
  saving.value = true
  error.value = null
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Usuario no autenticado')

    const providerName = newForm.providerSelect === 'Otro' ? newForm.customProvider : newForm.providerSelect
    const credentialType = providerName === 'n8n Webhook' ? 'webhook_url' : 'api_key'

    const payload = {
      user_id: user.id,
      provider: providerName,
      label: newForm.label.trim(),
      credential_type: credentialType,
      credential_value: newForm.credentialValue.trim(),
      is_active: true
    }

    const { error: err } = await supabase
      .from('provider_settings')
      .insert([payload])

    if (err) throw err

    showAddModal.value = false
    newForm.providerSelect = ''
    newForm.customProvider = ''
    newForm.label = ''
    newForm.credentialValue = ''
    
    await fetchProviders()
  } catch (err) {
    console.error('Error saving provider:', err)
    error.value = 'Ocurrió un error al guardar la credencial. Verifica tus permisos.'
    showAddModal.value = false
  } finally {
    saving.value = false
  }
}

const deleteProvider = async (id) => {
  if (!confirm('¿Estás seguro de eliminar esta credencial? Las automatizaciones que la usen podrían fallar.')) return
  
  error.value = null
  try {
    const { error: err } = await supabase
      .from('provider_settings')
      .delete()
      .eq('id', id)
      
    if (err) throw err
    providers.value = providers.value.filter(p => p.id !== id)
  } catch (err) {
    console.error('Error deleting provider:', err)
    error.value = 'No se pudo eliminar la credencial.'
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '—'
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(new Date(dateString))
}
</script>
