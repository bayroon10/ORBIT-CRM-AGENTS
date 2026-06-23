<template>
  <div class="flex h-screen bg-surface text-text-main font-sans">
    <OrbitSidebar class="print:!hidden" />
    <div class="flex-1 flex flex-col overflow-hidden print:!overflow-visible">
      <OrbitHeader class="print:!hidden" />
      <main ref="mainContent" class="flex-1 overflow-x-hidden overflow-y-auto bg-surface p-6">
        <div class="mx-auto max-w-7xl relative">
          <router-view v-slot="{ Component, route }">
            <Transition
              :name="'page'"
              mode="out-in"
              @enter="onPageEnter"
              @leave="onPageLeave"
            >
              <component :is="Component" :key="route.path" />
            </Transition>
          </router-view>
        </div>
      </main>
    </div>
    
    <!-- Contenedor global de notificaciones realtime -->
    <OrbitToastContainer class="print:!hidden" />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { gsap } from 'gsap'
import OrbitSidebar from '../components/OrbitSidebar.vue'
import OrbitHeader from '../components/OrbitHeader.vue'
import OrbitToastContainer from '../components/OrbitToastContainer.vue'

const route = useRoute()
const mainContent = ref(null)

// Restablecer el scroll del contenedor principal al navegar entre rutas
watch(() => route.path, () => {
  if (mainContent.value) {
    mainContent.value.scrollTop = 0
  }
})

const onPageEnter = (el, done) => {
  gsap.fromTo(el,
    { opacity: 0, y: 12 },
    {
      opacity: 1, y: 0,
      duration: 0.35,
      ease: 'power2.out',
      onComplete: done
    }
  )
}

const onPageLeave = (el, done) => {
  gsap.to(el, {
    opacity: 0,
    y: -8,
    duration: 0.2,
    ease: 'power2.in',
    onComplete: done
  })
}
</script>

<style scoped>
.page-enter-active,
.page-leave-active {
  position: absolute;
  width: 100%;
}
</style>
