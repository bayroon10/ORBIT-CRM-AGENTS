<template>
  <div class="fixed top-6 right-6 z-[9999] flex flex-col gap-3 pointer-events-none">
    <TransitionGroup 
      @enter="onEnter" 
      @leave="onLeave" 
      css="false"
    >
      <OrbitToast 
        v-for="alert in alerts" 
        :key="alert.id" 
        :alert="alert" 
        @close="removeAlert(alert.id)" 
      />
    </TransitionGroup>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'
import { gsap } from 'gsap'
import { useRealtimeAlerts } from '../composables/useRealtimeAlerts'
import OrbitToast from './OrbitToast.vue'

const { alerts, initRealtime, cleanupRealtime, removeAlert } = useRealtimeAlerts()

onMounted(() => {
  initRealtime()
})

onUnmounted(() => {
  cleanupRealtime()
})

const onEnter = (el, done) => {
  gsap.fromTo(el, 
    { x: 100, opacity: 0, scale: 0.8 }, 
    { x: 0, opacity: 1, scale: 1, duration: 0.6, ease: 'elastic.out(1, 0.7)', onComplete: done }
  )
}

const onLeave = (el, done) => {
  gsap.to(el, 
    { opacity: 0, scale: 0.9, y: -20, duration: 0.3, ease: 'power2.in', onComplete: done }
  )
}
</script>
