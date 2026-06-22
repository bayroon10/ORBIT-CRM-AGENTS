<template>
  <div class="flex flex-col h-full">
    <!-- ── Hero Header ── -->
    <div class="relative overflow-hidden rounded-xl bg-gradient-to-br from-slate-900 via-indigo-950 to-slate-900 px-8 py-10 mb-8 border border-primary/20 shadow-lg shrink-0">
      <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle, #818cf8 1px, transparent 1px); background-size: 24px 24px;"></div>
      <div class="absolute -top-16 -right-16 w-64 h-64 rounded-full opacity-15" style="background: radial-gradient(circle, #6366f1, transparent 70%);"></div>
      <div class="relative z-10 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-3">
            <BaseBadge variant="primary">Gestión</BaseBadge>
          </div>
          <h1 class="text-3xl font-bold text-text-main mb-2 tracking-tight">Tareas</h1>
          <p class="text-text-secondary text-sm">Gestión de pendientes, llamadas y correos.</p>
        </div>
        <BaseButton @click="openModal" size="lg">Nueva Tarea</BaseButton>
      </div>
    </div>

    <!-- ── Error State ── -->
    <div v-if="error" class="mb-6 bg-danger-bg text-danger p-4 rounded-lg text-sm border border-danger/20 shrink-0">
      {{ error }}
    </div>

    <!-- ── Table Card ── -->
    <BaseCard :padded="false" class="flex flex-col flex-1 overflow-hidden">
      <!-- Filtros / Buscador -->
      <div class="p-4 border-b border-border flex justify-between items-center shrink-0">
        <div class="relative w-72">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar tarea..."
            class="w-full pl-10 pr-4 py-2 bg-surface border border-border rounded-lg text-sm text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
          <div class="absolute left-3 top-2.5 text-text-muted">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="p-8 flex flex-col items-center justify-center space-y-4 flex-1">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <p class="text-sm text-text-secondary">Cargando pendientes...</p>
      </div>

      <!-- Table -->
      <div v-else-if="filteredTasks.length > 0" class="overflow-y-auto flex-1">
        <table class="w-full text-left text-sm">
          <thead class="bg-surface-container text-text-muted font-semibold sticky top-0 z-10">
            <tr>
              <th class="px-6 py-4 border-b border-border">Tarea</th>
              <th class="px-6 py-4 border-b border-border">Relacionado con</th>
              <th class="px-6 py-4 border-b border-border text-center">Estado</th>
              <th class="px-6 py-4 border-b border-border text-center">Prioridad</th>
              <th class="px-6 py-4 border-b border-border text-center">Vencimiento</th>
              <th class="px-6 py-4 border-b border-border text-right">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-border">
            <tr v-for="task in filteredTasks" :key="task.id" class="hover:bg-surface-container/60 transition-colors group">

              <!-- Tarea Título -->
              <td class="px-6 py-4">
                <div
                  class="font-medium"
                  :class="{'text-text-muted line-through': isCompleted(task.status), 'text-text-main': !isCompleted(task.status)}"
                >
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
                  <div v-if="!task.deals && !task.deal_id && !task.leads && !task.lead_id" class="text-xs text-text-muted">
                    Sin relación
                  </div>
                </div>
              </td>

              <!-- Estado -->
              <td class="px-6 py-4 text-center">
                <BaseBadge :variant="getStatusVariant(task.status)">
                  {{ formatStatus(task.status) }}
                </BaseBadge>
              </td>

              <!-- Prioridad -->
              <td class="px-6 py-4 text-center">
                <BaseBadge :variant="getPriorityVariant(task.priority)">
                  {{ task.priority || 'Media' }}
                </BaseBadge>
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

              <!-- Acciones -->
              <td class="px-6 py-4 text-right">
                <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button
                    @click="toggleTaskStatus(task)"
                    class="p-1.5 rounded-md hover:bg-surface border border-transparent hover:border-border transition-colors"
                    :class="isCompleted(task.status) ? 'text-text-muted hover:text-text-main' : 'text-success hover:bg-success/10 hover:border-success/20'"
                    :title="isCompleted(task.status) ? 'Marcar pendiente' : 'Marcar completada'"
                  >
                    <svg v-if="isCompleted(task.status)" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M2.13 15.57a9 9 0 1 0 3.1-8.52L2.5 9"></path></svg>
                    <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                  </button>
                  <button
                    @click="editTask(task)"
                    class="p-1.5 text-text-muted hover:text-primary rounded-md hover:bg-surface border border-transparent hover:border-border transition-colors"
                    title="Editar tarea"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                  </button>
                  <button
                    @click="deleteTask(task.id)"
                    class="p-1.5 text-text-muted hover:text-danger rounded-md hover:bg-surface border border-transparent hover:border-danger/20 transition-colors"
                    title="Eliminar tarea"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                  </button>
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
    </BaseCard>

    <!-- ── Modal Nueva Tarea ── -->
    <OrbitModal v-model="showTaskModal" :title="newTask.id ? 'Editar Tarea' : 'Nueva Tarea'">
      <form @submit.prevent="saveTask" class="space-y-4">
        <div v-if="taskError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm border border-danger/20">
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
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
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
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
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
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
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
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
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
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
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
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
            >
              <option value="none">Ninguno (Tarea suelta)</option>
              <option value="lead">Contacto (Lead)</option>
              <option value="deal">Negocio (Deal)</option>
            </select>
          </div>

          <!-- Relacionado con Registro -->
          <div v-if="newTask.related_type !== 'none'">
            <label class="block text-xs font-semibold text-text-secondary uppercase mb-1.5" for="task-rel-id">
              Registro relacionado
            </label>
            <select
              v-model="newTask.related_id"
              id="task-rel-id"
              class="w-full px-3 py-2 bg-surface border border-border-strong rounded-lg text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
            >
              <option value="">Seleccionar registro...</option>
              <option v-for="option in relatedOptions" :key="option.id" :value="option.id">
                {{ option.label }}
              </option>
            </select>
          </div>
        </div>

        <!-- Botones -->
        <div class="mt-6 flex justify-end gap-3 pt-4 border-t border-border">
          <BaseButton variant="secondary" type="button" @click="showTaskModal = false">Cancelar</BaseButton>
          <BaseButton type="submit" :loading="savingTask">
            {{ savingTask ? 'Guardando...' : 'Guardar' }}
          </BaseButton>
        </div>
      </form>
    </OrbitModal>

    <!-- ── Modal Confirmar Eliminar ── -->
    <OrbitModal v-model="showDeleteModal" title="Eliminar Tarea">
      <div class="space-y-4">
        <p class="text-sm text-text-secondary">
          ¿Estás seguro que deseas eliminar esta tarea? Esta acción no se puede deshacer.
        </p>
        <div v-if="deleteError" class="bg-danger-bg text-danger p-3 rounded-lg text-sm border border-danger/20">
          {{ deleteError }}
        </div>
        <div class="flex justify-end gap-3 pt-4 border-t border-border">
          <BaseButton variant="secondary" @click="showDeleteModal = false">Cancelar</BaseButton>
          <BaseButton variant="danger" :loading="deletingTask" @click="confirmDeleteTask">
            {{ deletingTask ? 'Eliminando...' : 'Eliminar' }}
          </BaseButton>
        </div>
      </div>
    </OrbitModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase'
import OrbitEmptyState from '../components/OrbitEmptyState.vue'
import OrbitModal from '../components/OrbitModal.vue'
import BaseCard from '../components/BaseCard.vue'
import BaseBadge from '../components/BaseBadge.vue'
import BaseButton from '../components/BaseButton.vue'

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

const showDeleteModal = ref(false)
const taskToDelete = ref(null)
const deletingTask = ref(false)
const deleteError = ref(null)

const newTask = ref({
  id: null,
  title: '',
  description: '',
  priority: 'Media',
  due_date: '',
  assigned_to: '',
  related_type: 'none',
  related_id: ''
})

// Mapea priority a variante de BaseBadge
const getPriorityVariant = (priority) => {
  const norm = priority?.toLowerCase() || 'media'
  if (norm === 'alta') return 'danger'
  if (norm === 'baja') return 'success'
  return 'warning'
}

// Mapea status a variante de BaseBadge
const getStatusVariant = (status) => {
  const norm = status?.toLowerCase() || ''
  if (norm.includes('pendiente')) return 'warning'
  if (norm.includes('completad')) return 'success'
  if (norm.includes('progres'))   return 'primary'
  return 'muted'
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
      relatedOptions.value = (data || []).map(item => ({ id: item.id, label: item.name }))
    } else if (type === 'deal') {
      const { data, error: err } = await supabase
        .from('deals')
        .select('id, name:title')
        .order('title', { ascending: true })
      if (err) throw err
      relatedOptions.value = (data || []).map(item => ({ id: item.id, label: item.name }))
    }
  } catch (err) {
    console.error('Error al cargar relacionados:', err)
  }
}

watch(() => newTask.value.related_type, async (newType, oldType) => {
  if (oldType !== undefined && newType !== oldType) {
    newTask.value.related_id = ''
  }
  if (newType && newType !== 'none') {
    await fetchRelatedOptions(newType)
  }
})

const openModal = async () => {
  newTask.value = {
    id: null,
    title: '',
    description: '',
    priority: 'Media',
    due_date: '',
    assigned_to: '',
    related_type: 'none',
    related_id: ''
  }
  taskError.value = null
  showTaskModal.value = true
  await fetchProfiles()
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
      assigned_to: newTask.value.assigned_to || null,
      lead_id: newTask.value.related_type === 'lead' ? (newTask.value.related_id || null) : null,
      deal_id: newTask.value.related_type === 'deal' ? (newTask.value.related_id || null) : null
    }

    if (newTask.value.id) {
      const { error: err } = await supabase
        .from('tasks')
        .update(payload)
        .eq('id', newTask.value.id)

      if (err) throw err
    } else {
      payload.status = 'pendiente'
      const { error: err } = await supabase
        .from('tasks')
        .insert([payload])

      if (err) throw err
    }

    showTaskModal.value = false
    await fetchTasks()
  } catch (err) {
    console.error('Error al guardar la tarea:', err)
    taskError.value = 'Ocurrió un error al guardar la tarea: ' + (err.message || err)
  } finally {
    savingTask.value = false
  }
}

const toggleTaskStatus = async (task) => {
  const newStatus = isCompleted(task.status) ? 'pendiente' : 'completada'
  try {
    const { error: err } = await supabase.from('tasks').update({ status: newStatus }).eq('id', task.id)
    if (err) throw err
    task.status = newStatus
  } catch (err) {
    console.error('Error al actualizar estado:', err)
    error.value = 'No se pudo actualizar el estado de la tarea.'
  }
}

const editTask = async (task) => {
  taskError.value = null
  
  let relType = 'none'
  let relId = ''
  if (task.lead_id) {
    relType = 'lead'
    relId = task.lead_id
  } else if (task.deal_id) {
    relType = 'deal'
    relId = task.deal_id
  }
  
  newTask.value = {
    id: task.id,
    title: task.title || '',
    description: task.description || '',
    priority: task.priority || 'Media',
    due_date: task.due_date || '',
    assigned_to: task.assigned_to || '',
    related_type: relType,
    related_id: relId
  }
  
  await fetchProfiles()
  if (relType !== 'none') {
    await fetchRelatedOptions(relType)
  }
  
  newTask.value.related_id = relId
  showTaskModal.value = true
}

const deleteTask = (taskId) => {
  taskToDelete.value = taskId
  deleteError.value = null
  showDeleteModal.value = true
}

const confirmDeleteTask = async () => {
  if (!taskToDelete.value) return
  deletingTask.value = true
  deleteError.value = null
  try {
    const { error: err } = await supabase.from('tasks').delete().eq('id', taskToDelete.value)
    if (err) throw err
    showDeleteModal.value = false
    await fetchTasks()
  } catch (err) {
    console.error('Error al eliminar:', err)
    deleteError.value = 'Ocurrió un error al eliminar. ' + (err.message || '')
  } finally {
    deletingTask.value = false
  }
}

// Filtrado Reactivo
const filteredTasks = computed(() => {
  if (!searchQuery.value) return tasks.value
  const query = searchQuery.value.toLowerCase()
  return tasks.value.filter(task =>
    task.title?.toLowerCase().includes(query) ||
    task.leads?.full_name?.toLowerCase().includes(query) ||
    task.deals?.title?.toLowerCase().includes(query)
  )
})

const isCompleted = (status) =>
  status?.toLowerCase() === 'completada' || status?.toLowerCase() === 'completado'

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
  return new Intl.DateTimeFormat('es-CL', { dateStyle: 'medium' }).format(date)
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
