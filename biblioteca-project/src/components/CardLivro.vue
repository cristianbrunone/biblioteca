<template>
  <v-card class="ma-0" max-width="300" outlined>
    <v-img :src="'https://picsum.photos/1920/1080?random=' + Math.random()" height="200" class="white--text no-margin">
      <v-row class="fill-height" align="center" justify="center">
        <v-col class="text-center">
        </v-col>
      </v-row>
    </v-img>

    <v-card-title class="headline font-weight-bold">{{ titulo }}</v-card-title>
    <v-card-subtitle class="subheading">{{ autor }}</v-card-subtitle>
    <v-card-text>
      <p>{{ categoria }}</p>

      <!-- Detalhes do Empréstimo (somente na seção 'emprestimos') -->
      <template v-if="dataEmprestimo && inEmprestimos">
        <v-row>
          <v-col>
            <p><strong>Data de Devolução:</strong> {{ dataDevolucao }}</p>
            <p><strong>Emprestado para:</strong> {{ responsavel }}</p>
          </v-col>
        </v-row>
        <v-row>
          <v-col>
            <v-btn color="success" @click="realizarDevolucao" block>
              Devolver Livro
            </v-btn>
          </v-col>
        </v-row>
      </template>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref, computed } from "vue";

const props = defineProps({
  titulo: String,
  autor: String,
  categoria: String,
  dataEmprestimo: Date,
  responsavel: String,
  inEmprestimos: {
    type: Boolean,
    required: true, // Define se está na seção 'emprestimos'
  },
});

const tempoEmprestimo = 7;

const dataDevolucao = computed(() => {
  if (props.dataEmprestimo) {
    const emprestimoDate = new Date(props.dataEmprestimo);
    emprestimoDate.setDate(emprestimoDate.getDate() + tempoEmprestimo);
    return emprestimoDate.toLocaleDateString();
  }
  return null;
});

function solicitarEmprestimo() {
  console.log("Livro emprestado!");
}

function realizarDevolucao() {
  console.log("Livro devolvido!");
}
</script>

<style scoped>
.v-img {
  border-radius: 8px 8px 0 0;
}

.v-card {
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}
</style>