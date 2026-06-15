<template>
  <div class="flex flex-col h-full">
    <div class="relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 px-8 py-10 mb-8 shadow-xl shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #ffffff 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-10" style="background: radial-gradient(circle, #3b82f6, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <span class="px-2.5 py-1 bg-blue-500/20 text-blue-300 text-xs font-semibold rounded-full border border-blue-500/30 uppercase tracking-wide">Gestión</span>
          </div>
          <h1 class="text-3xl font-bold text-white mb-2 tracking-tight">Tareas</h1>
          <p class="text-gray-400 text-sm">Gestión de pendientes, llamadas y correos.</p>
        </div>
        <button 
          @click="openModal"
          class="bg-primary hover:bg-primary-variant btn-glow text-white px-5 py-2.5 rounded-lg text-sm font-medium transition-all"
        >
          Nueva Tarea
        </button>
      </div>
    </div>
    
    <!-- Error State -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/10 shrink-0">
      {{ error }}
    </div>

    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-gray-100 flex justify-between items-center shrink-0">
        <div class="relative w-72">
          <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Buscar tarea..." 
            class="w-full pl-10 pr-4 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
          />
          <div class="absolute left-3 top-2.5 text-text-secondary">
            <!-- Search Icon -->
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando pendientes...</p>
      </div>

      <!-- Listado de Tareas -->
      <div v-else-if="filteredTasks.length > 0" class="overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-gray-50 text-gray-500 font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-gray-100">Tarea</th>
              <th class="px-6 py-4 border-b border-gray-100">Relacionado con</th>
              <th class="px-6 py-4 border-b border-gray-100 text-center">Estado</th>
              <th class="px-6 py-4 border-b border-gray-100 text-center">Prioridad</th>
              <th class="px-6 py-4 border-b border-gray-100">Vencimiento</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="task in filteredTasks" :key="task.id" class="hover:bg-gray-50/80 transition-colors group">
              
              <!-- Tarea Título -->
              <td class="px-6 py-4">
                <div class="font-medium" :class="{'text-text-secondary line-through': isCompleted(task.status), 'text-text-main': !isCompleted(task.status)}">
                  {{ task.title }}
                </div>
              </td>

              <!-- Relación (Lead / Deal) -->
              <td class="px-6 py-4">
                <div class="flex flex-col gap-1">
                  <!-- Deal -->
                  <div v-if="task.deals || task.deal_id" class="flex items-center gap-1.5 text-xs text-text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="9" y1="21" x2="9" y2="9"></line></svg>
                    <span class="truncate" :class="{'italic': !task.deals}">
                      {{ task.deals?.title || 'Negocio privado' }}
                    </span>
                  </div>
                  <!-- Lead -->
                  <div v-if="task.leads || task.lead_id" class="flex items-center gap-1.5 text-xs text-text-secondary">
                    <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                    <span class="truncate" :class="{'italic': !task.leads}">
                      {{ task.leads?.full_name || 'Contacto privado' }}
                    </span>
                  </div>
                  <div v-if="!task.deals && !task.deal_id && !task.leads && !task.lead_id" class="text-xs text-gray-400">
                    Sin relación
                  </div>
                </div>
              </td>

              <!-- Estado -->
              <td class="px-6 py-4 text-center">
                <span 
                  class="px-3 py-1 text-xs font-semibold rounded-full inline-block"
                  :class="getStatusClass(task.status)"
                >
                  {{ formatStatus(task.status) }}
                </span>
              </td>

              <!-- Prioridad -->
              <td class="px-6 py-4 text-center">
                <span 
                  class="px-3 py-1 text-xs font-semibold rounded-full inline-block"
                  :class="getPriorityClass(task.priority)"
                >
                  {{ task.priority || 'Media' }}
                </span>
              </td>

              <!-- Due Date -->
              <td class="px-6 py-4">
                <div 
                  class="flex items-center gap-2 text-sm"
                  :class="getDueDateColor(task.due_date, task.status)"
                >
                  <svg v-if="isPastDue(task.due_date) && !isCompleted(task.status)" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                  <span>{{ formatDate(task.due_date) }}</span>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-else class="py-16 flex-1 flex items-center justify-center">
        <OrbitEmptyState 
          :title="searchQuery ? 'No hay resultados' : 'Estás al día'" 
          :description="searchQuery ? 'Ninguna tarea coincide con tu búsqueda.' : 'No tienes tareas pendientes programadas en el sistema.'"
        />
      </div>
    </div>

    <!-- Modal Nueva Tarea -->
    <OrbitModal v-model="showTaskModal" title="Nueva Tarea">
      <form @submit.prevent="saveTask" class="space-y-4">
        <div v-if="taskError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm border border-danger/10">
          {{ taskError }}
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Título -->
          <div class="md:col-span-2">
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-title">
              Título <span class="text-danger">*</span>
            </label>
            <input 
              v-model="newTask.title"
              id="task-title"
              type="text" 
              required
              placeholder="Ej: Llamar a cliente para seguimiento" 
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            />
          </div>

          <!-- Descripción -->
          <div class="md:col-span-2">
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-desc">
              Descripción
            </label>
            <textarea 
              v-model="newTask.description"
              id="task-desc"
              rows="3"
              placeholder="Detalles adicionales de la tarea..." 
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            ></textarea>
          </div>

          <!-- Prioridad -->
          <div>
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-priority">
              Prioridad
            </label>
            <select 
              v-model="newTask.priority"
              id="task-priority"
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            >
              <option value="Alta">Alta</option>
              <option value="Media">Media</option>
              <option value="Baja">Baja</option>
            </select>
          </div>

          <!-- Fecha Límite -->
          <div>
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-due">
              Fecha Límite
            </label>
            <input 
              v-model="newTask.due_date"
              id="task-due"
              type="date" 
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            />
          </div>

          <!-- Asignado a -->
          <div class="md:col-span-2">
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-assignee">
              Asignado a
            </label>
            <select 
              v-model="newTask.assigned_to"
              id="task-assignee"
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            >
              <option value="">Seleccionar responsable...</option>
              <option v-for="profile in profiles" :key="profile.id" :value="profile.id">
                {{ profile.full_name }}
              </option>
            </select>
          </div>

          <!-- Relacionado con Tipo -->
          <div>
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-rel-type">
              Relacionado con
            </label>
            <select 
              v-model="newTask.related_type"
              id="task-rel-type"
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            >
              <option value="lead">Contacto (Lead)</option>
              <option value="deal">Negocio (Deal)</option>
            </select>
          </div>

          <!-- Relacionado con Registro -->
          <div>
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-rel-id">
              Registro relacionado
            </label>
            <select 
              v-model="newTask.related_id"
              id="task-rel-id"
              class="w-full px-3 py-2 bg-surface border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            >
              <option value="">Seleccionar registro...</option>
              <option v-for="option in relatedOptions" :key="option.id" :value="option.id">
                {{ option.label }}
              </option>
            </select>
          </div>
        </div>

        <!-- Botones -->
        <div class="mt-6 flex justify-end gap-3 pt-4 border-t border-gray-100">
          <button 
            type="button" 
            @click="showTaskModal = false"
            class="px-4 py-2 border border-border text-text-secondary hover:text-text-main rounded-lg text-sm font-medium transition-colors"
          >
            Cancelar
          </button>
          <button 
            type="submit"
            :disabled="savingTask"
            class="bg-primary hover:bg-primary-variant btn-glow text-white px-5 py-2 rounded-lg text-sm font-medium transition-all disabled:opacity-50 flex items-center gap-2"
          >
            <span v-if="savingTask" class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></span>
            {{ savingTask ? 'Guardando...' : 'Guardar' }}
          </button>
        </div>
      </form>
    </OrbitModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import OrbitPageHeader from '../components/OrbitPageHeader.vue'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'

const tasks = ref([])
const loading = ref(true)
const error = ref(null)
const searchQuery = ref('')

// Modal state & data
const showTaskModal = ref(false)
const savingTask = ref(false)
const taskError = ref(null)
const profiles = ref([])
const relatedOptions = ref([])

const newTask = ref({
  title: '',
  description: '',
  priority: 'Media',
  due_date: '',
  assigned_to: '',
  related_type: 'lead',
  related_id: ''
})

const getPriorityClass = (priority) => {
  const norm = priority?.toLowerCase() || 'media'
  if (norm === 'alta') return 'bg-red-100 text-red-700'
  if (norm === 'baja') return 'bg-green-100 text-green-700'
  return 'bg-yellow-100 text-yellow-700'
}

const fetchProfiles = async () => {
  try {
    const { data, error: err } = await supabase
      .from('profiles')
      .select('id, full_name')
      .order('full_name', { ascending: true })
    if (err) throw err
    profiles.value = data || []
  } catch (err) {
    console.error('Error al cargar perfiles:', err)
  }
}

const fetchRelatedOptions = async (type) => {
  try {
    if (type === 'lead') {
      const { data, error: err } = await supabase
        .from('leads')
        .select('id, name:full_name')
        .order('full_name', { ascending: true })
      if (err) throw err
      relatedOptions.value = (data || []).map(item => ({
        id: item.id,
        label: item.name
      }))
    } else if (type === 'deal') {
      const { data, error: err } = await supabase
        .from('deals')
        .select('id, name:title')
        .order('title', { ascending: true })
      if (err) throw err
      relatedOptions.value = (data || []).map(item => ({
        id: item.id,
        label: item.name
      }))
    }
  } catch (err) {
    console.error('Error al cargar relacionados:', err)
  }
}

watch(() => newTask.value.related_type, async (newType) => {
  newTask.value.related_id = ''
  if (newType) {
    await fetchRelatedOptions(newType)
  }
})

const openModal = async () => {
  newTask.value = {
    title: '',
    description: '',
    priority: 'Media',
    due_date: '',
    assigned_to: '',
    related_type: 'lead',
    related_id: ''
  }
  taskError.value = null
  showTaskModal.value = true
  await fetchProfiles()
  await fetchRelatedOptions(newTask.value.related_type)
}

const saveTask = async () => {
  if (!newTask.value.title.trim()) {
    taskError.value = 'El título de la tarea es obligatorio.'
    return
  }

  savingTask.value = true
  taskError.value = null

  try {
    const payload = {
      title: newTask.value.title.trim(),
      description: newTask.value.description ? newTask.value.description.trim() : null,
      priority: newTask.value.priority,
      due_date: newTask.value.due_date || null,
      status: 'pendiente',
      assigned_to: newTask.value.assigned_to || null,
      lead_id: newTask.value.related_type === 'lead' ? (newTask.value.related_id || null) : null,
      deal_id: newTask.value.related_type === 'deal' ? (newTask.value.related_id || null) : null
    }

    const { error: err } = await supabase
      .from('tasks')
      .insert([payload])

    if (err) throw err

    showTaskModal.value = false
    await fetchTasks()
  } catch (err) {
    console.error('Error al guardar la tarea:', err)
    taskError.value = 'Ocurrió un error al guardar la tarea: ' + (err.message || err)
  } finally {
    savingTask.value = false
  }
}

// Filtrado Reactivo
const filteredTasks = computed(() => {
  if (!searchQuery.value) return tasks.value
  
  const query = searchQuery.value.toLowerCase()
  return tasks.value.filter(task => {
    return (
      task.title?.toLowerCase().includes(query) ||
      task.leads?.full_name?.toLowerCase().includes(query) ||
      task.deals?.title?.toLowerCase().includes(query)
    )
  })
})

const isCompleted = (status) => {
  return status?.toLowerCase() === 'completada' || status?.toLowerCase() === 'completado'
}

// Visual Helpers
const getStatusClass = (status) => {
  const norm = status?.toLowerCase() || ''
  if (norm.includes('pendiente')) return 'bg-yellow-100 text-yellow-700'
  if (norm.includes('completad')) return 'bg-green-100 text-green-700'
  if (norm.includes('progres')) return 'bg-blue-100 text-blue-700'
  return 'bg-gray-100 text-gray-700'
}

const formatStatus = (status) => {
  if (!status) return 'Desconocido'
  return status.charAt(0).toUpperCase() + status.slice(1)
}

const parseDate = (dateString) => {
  if (!dateString || dateString === '' || dateString === 'null') return null
  const hasT = dateString.includes('T')
  const d = new Date(hasT ? dateString : dateString + 'T00:00:00')
  if (isNaN(d.getTime())) return null
  // Supabase a veces retorna 0001-01-01T... para timestamptz null — lo ignoramos
  if (d.getFullYear() < 1900) return null
  return d
}

const isPastDue = (dateString) => {
  const dueDate = parseDate(dateString)
  if (!dueDate) return false
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return dueDate < today
}

const getDueDateColor = (dateString, status) => {
  if (!parseDate(dateString)) return 'text-text-secondary'
  if (isCompleted(status)) return 'text-text-secondary'
  if (isPastDue(dateString)) return 'text-danger font-medium'
  return 'text-text-main'
}

const formatDate = (dateString) => {
  const date = parseDate(dateString)
  if (!date) return 'Sin fecha'
  return new Intl.DateTimeFormat('es-CL', {
    dateStyle: 'medium'
  }).format(date)
}

// Data Fetching
const fetchTasks = async () => {
  loading.value = true
  error.value = null
  try {
    const { data, error: err } = await supabase
      .from('tasks')
      .select(`
        id, 
        title, 
        due_date, 
        status, 
        created_at,
        lead_id,
        deal_id,
        priority,
        leads(full_name),
        deals(title)
      `)
      // Ordenar: primero las no completadas y por fecha de vencimiento más próxima
      .order('due_date', { ascending: true, nullsFirst: false })
      
    if (err) throw err
    
    tasks.value = data || []
  } catch (err) {
    console.error('Error al cargar tasks:', err)
    error.value = 'Ocurrió un error al cargar tus tareas pendientes.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchTasks()
})
</script>
