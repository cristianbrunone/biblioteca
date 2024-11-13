<template>
  <v-card class="ma-0" max-width="300" outlined>
    <!-- Imagem aleatória para o livro que preenche toda a parte superior -->
    <v-img
      :src="'https://picsum.photos/1920/1080?random=' + Math.random()"
      height="200"
      class="white--text no-margin"
    >
      <v-row class="fill-height" align="center" justify="center">
        <v-col class="text-center">
          <v-btn color="primary" v-if="!dataEmprestimo" @click="solicitarEmprestimo" rounded>
            Emprestar Livro
          </v-btn>
        </v-col>
      </v-row>
    </v-img>

    <!-- Tag 'Reservado' -->
    <v-chip v-if="reservado" color="red" text-color="white" class="ma-2" label>
      Reservado
    </v-chip>

    <v-card-title class="headline font-weight-bold">{{ titulo }}</v-card-title>
    <v-card-subtitle class="subheading">{{ autor }}</v-card-subtitle>
    <v-card-text>
      <p>{{ descricao }}</p>
      <!-- Exibe o tempo de devolução se for um livro emprestado -->
      <template v-if="dataEmprestimo">
        <v-row>
          <v-col>
            <p><strong>Data de Devolução:</strong> {{ dataDevolucao }}</p>
          </v-col>
        </v-row>
      </template>
    </v-card-text>
  </v-card>
</template>

<script setup>
const props = defineProps({
  titulo: {
    type: String,
    required: true,
  },
  autor: {
    type: String,
    required: true,
  },
  descricao: {
    type: String,
    required: false,
    default: 'Descrição do livro...',
  },
  dataEmprestimo: {
    type: Date,
    required: false,
    default: null,
  },
  reservado: {
    type: Boolean,
    required: false,
    default: false, // A propriedade para verificar se o livro está reservado
  },
});

const tempoEmprestimo = 7; // Empréstimo de 7 dias (exemplo)

const dataDevolucao = computed(() => {
  if (props.dataEmprestimo) {
    const emprestimoDate = new Date(props.dataEmprestimo);
    emprestimoDate.setDate(emprestimoDate.getDate() + tempoEmprestimo);
    return emprestimoDate.toLocaleDateString(); // Formatar a data de devolução
  }
  return null;
});

function solicitarEmprestimo() {
  console.log("Livro emprestado!");
}
</script>

<style scoped>
/* Remover qualquer margem ou padding que poderia afetar a imagem */
.v-img {
  border-radius: 8px 8px 0 0; /* Arredondar o topo da imagem */
  margin: 0; /* Garantir que não haja margem */
  padding: 0; /* Garantir que não haja padding */
}

.v-card {
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); /* Sombra suave para um toque moderno */
}

.v-card-title {
  font-size: 1.25rem; /* Ajuste da fonte do título */
}

.v-card-subtitle {
  font-size: 1rem;
  color: #555; /* Cor mais suave para o autor */
}

.v-btn {
  font-size: 0.9rem;
}
</style>
