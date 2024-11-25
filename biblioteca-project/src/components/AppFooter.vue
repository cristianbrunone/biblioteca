<template>
  <v-footer height="70" app class="bg-light-gray">
    <!-- Contenedor flex para centrar el contenido -->
    <div class="d-flex justify-center align-center text-center py-4">
      <span>&copy; 2016-{{ (new Date()).getFullYear() }} <span class="d-none d-sm-inline-block">Biblioteca
          ONG</span></span>
      —
      <a class="text-decoration-none on-surface" href="https://vuetifyjs.com/about/licensing/" rel="noopener noreferrer"
        target="_blank">
        MIT License
      </a>
    </div>
  </v-footer>
</template>

<script setup>
// No es necesario ningún cambio en el script
</script>

<style scoped lang="scss">
/* Usamos un color gris claro como fondo */
.bg-light-gray {
  background-color: #f5f5f5;
  /* Color gris claro */
}

.on-surface {
  color: rgba(0, 0, 0, 0.6);

  &:hover {
    color: rgba(25, 118, 210, 1);
  }
}

.text-caption {
  font-size: 14px;
  line-height: 1.5;
  font-weight: 400;
}
</style>
