import gsap from 'gsap'

export default {
  install(app) {
    app.directive('fade-in', {
      mounted(el, binding) {
        const { delay = 0, duration = 0.4, scale = 1, ease = 'power2.out' } = binding.value || {}
        gsap.fromTo(el,
          { opacity: 0, scale },
          { opacity: 1, scale: 1, duration, delay, ease }
        )
      },
      unmounted(el) {
        gsap.killTweensOf(el)
      }
    })

    app.directive('slide-up', {
      mounted(el, binding) {
        const { delay = 0, duration = 0.5, y = 30, scale = 1, ease = 'power3.out' } = binding.value || {}
        gsap.fromTo(el,
          { opacity: 0, y, scale },
          { opacity: 1, y: 0, scale: 1, duration, delay, ease }
        )
      },
      unmounted(el) {
        gsap.killTweensOf(el)
      }
    })
  }
}
