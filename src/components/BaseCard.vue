<template>
  <!--
    BaseCard — contenedor de superficie elevada.
    Props:
      • padded  (Boolean, default true)  – aplica padding interno p-5
      • hover   (Boolean, default false) – activa efecto card-3d hover
      • flush   (Boolean, default false) – sin borde redondeado ni sombra (para listas/tablas)
  -->
  <div
    :class="[
      'relative bg-slate-900/40 backdrop-blur-md border border-white/10 rounded-xl overflow-hidden',
      padded && 'p-5',
      hover  && 'card-3d cursor-pointer',
      !flush && 'shadow-2xl',
    ]"
  >
    <slot />
  </div>
</template>

<script setup>
defineProps({
  padded: { type: Boolean, default: true },
  hover:  { type: Boolean, default: false },
  flush:  { type: Boolean, default: false },
})
</script>
