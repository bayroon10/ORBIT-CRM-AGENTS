<template>
  <Teleport to="body">
    <Transition name="modal">
      <div
        v-if="modelValue"
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4"
        @click.self="close"
      >
        <div class="bg-surface-container rounded-xl shadow-lg border border-border-strong max-w-lg w-full flex flex-col max-h-[90vh]">

          <!-- Header -->
          <div class="flex items-center justify-between px-6 py-4 border-b border-border shrink-0">
            <h3 class="text-base font-semibold text-text-main">{{ title }}</h3>
            <button
              @click="close"
              class="text-text-muted hover:text-text-main transition-colors focus:outline-none rounded-lg p-1 hover:bg-surface-card"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>

          <!-- Body -->
          <div class="px-6 py-4 overflow-y-auto">
            <slot></slot>
          </div>

          <!-- Footer -->
          <div v-if="$slots.footer" class="px-6 py-4 border-t border-border bg-surface/50 rounded-b-xl shrink-0">
            <slot name="footer"></slot>
          </div>

        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true,
  },
  title: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['update:modelValue'])
const close = () => emit('update:modelValue', false)
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.modal-enter-active > div,
.modal-leave-active > div {
  transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}
.modal-enter-from > div,
.modal-leave-to > div {
  opacity: 0;
  transform: translateY(-8px) scale(0.98);
}
</style>
