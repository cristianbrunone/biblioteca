<template>
  <v-app>
    <!-- Drawer Permanente -->
    <v-navigation-drawer app permanent>
      <v-list>
        <v-list-item @click="currentSection = 'emprestimos'">
          <v-list-item-title>Empréstimos</v-list-item-title>
        </v-list-item>
        <v-list-item @click="currentSection = 'disponiveis'">
          <v-list-item-title>Livros Disponíveis</v-list-item-title>
        </v-list-item>
        <v-list-item @click="currentSection = 'reservas'">
          <v-list-item-title>Reservas</v-list-item-title>
        </v-list-item>
        <v-list-item @click="currentSection = 'cadastro'">
          <v-list-item-title>Cadastro de Livros</v-list-item-title>
        </v-list-item>
        <v-list-item @click="currentSection = 'cadastroUsuarios'">
          <v-list-item-title>Cadastro de Usuários</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>

    <!-- Barra de navegação -->
    <v-app-bar app>
      <v-toolbar-title>Aplicação de Livros</v-toolbar-title>

      <!-- Barra de Busca - exibe apenas nas seções de busca -->
      <v-spacer></v-spacer>
      <v-text-field
        v-if="currentSection === 'emprestimos' || currentSection === 'disponiveis' || currentSection === 'reservas'"
        v-model="searchQuery"
        label="Buscar por título"
        solo
        clearable
        @input="searchBooks"
      />
    </v-app-bar>

    <!-- Conteúdo principal -->
    <v-main>
      <v-container>
        <!-- Mostrar conteúdo dependendo da seção selecionada -->
        <template v-if="currentSection === 'emprestimos'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosEmprestimo" :key="index" cols="12" md="4">
              <card-livro 
                :titulo="livro.titulo"
                :autor="livro.autor"
                :descricao="livro.descricao"
                :data-emprestimo="livro.dataEmprestimo"
                :class="{ highlight: livro.isHighlighted }"
              />
            </v-col>
          </v-row>
        </template>

        <template v-if="currentSection === 'reservas'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosReservas" :key="index" cols="12" md="4">
              <card-livro 
                :titulo="livro.titulo"
                :autor="livro.autor"
                :descricao="livro.descricao"
                :reservado="true"
                :class="{ highlight: livro.isHighlighted }" 
              />
            </v-col>
          </v-row>
        </template>

        <template v-if="currentSection === 'cadastro'">
          <!-- Formulário de cadastro de livros -->
          <v-form>
            <v-text-field label="Título do Livro" v-model="novoLivro.titulo" />
            <v-text-field label="Autor" v-model="novoLivro.autor" />
            <v-textarea label="Descrição" v-model="novoLivro.descricao" />
            <v-btn @click="cadastrarLivro">Cadastrar Livro</v-btn>
          </v-form>
        </template>

        <template v-if="currentSection === 'cadastroUsuarios'">
          <!-- Formulário de cadastro de usuários -->
          <v-form>
            <v-text-field label="Nome do Usuário" v-model="novoUsuario.nome" />
            <v-text-field label="Email" v-model="novoUsuario.email" />
            <v-text-field label="Senha" type="password" v-model="novoUsuario.senha" />
            <v-text-field label="Telefone" v-model="novoUsuario.telefone" />
            <v-btn @click="cadastrarUsuario">Cadastrar Usuário</v-btn>
          </v-form>
        </template>

        <template v-if="currentSection === 'disponiveis'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosDisponiveis" :key="index" cols="12" md="4">
              <card-livro 
                :titulo="livro.titulo"
                :autor="livro.autor"
                :descricao="livro.descricao"
                :class="{ highlight: livro.isHighlighted }"
              />
            </v-col>
          </v-row>
        </template>
      </v-container>
    </v-main>

    <!-- Pie de página -->
    <AppFooter />
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import AppFooter from '@/components/AppFooter.vue';
import cardLivro from '@/components/CardLivro.vue'; 

// Seção selecionada
const currentSection = ref('emprestimos');

// Dados de exemplo para "Empréstimos", "Reservas" e "Livros Disponiveis"
const livrosEmprestimo = ref([
  { titulo: 'O Alquimista', autor: 'Paulo Coelho', descricao: 'Uma jornada de autodescoberta.', dataEmprestimo: '2024-11-01' },
  { titulo: '1984', autor: 'George Orwell', descricao: 'Uma distopia sobre totalitarismo.', dataEmprestimo: '2024-11-05' },
  { titulo: 'Dom Casmurro', autor: 'Machado de Assis', descricao: 'O clássico da literatura brasileira.', dataEmprestimo: '2024-11-03' }
]);

const livrosReservas = ref([
  { titulo: 'A Cabana', autor: 'William P. Young', descricao: 'Uma história de superação e fé.' },
  { titulo: 'O Hobbit', autor: 'J.R.R. Tolkien', descricao: 'A jornada de Bilbo Bolseiro.' }
]);

const livrosDisponiveis = ref([
  { titulo: '1984', autor: 'George Orwell', descricao: 'Uma distopia sobre totalitarismo.' },
  { titulo: 'Cem Anos de Solidão', autor: 'Gabriel García Márquez', descricao: 'A história da família Buendía.' },
  { titulo: 'O Senhor dos Anéis', autor: 'J.R.R. Tolkien', descricao: 'A jornada épica da Terra Média.' }
]);

// Filtro de livros com base no nome
const searchQuery = ref('');
const filteredLivrosEmprestimo = ref(livrosEmprestimo.value);
const filteredLivrosReservas = ref(livrosReservas.value);
const filteredLivrosDisponiveis = ref(livrosDisponiveis.value);

// Função para filtrar livros com base na busca
function searchBooks() {
  const query = searchQuery.value.toLowerCase();
  let livros = [];

  if (currentSection.value === 'emprestimos') {
    livros = livrosEmprestimo.value;
    filteredLivrosEmprestimo.value = livros.filter(livro => livro.titulo.toLowerCase().includes(query));
  } else if (currentSection.value === 'reservas') {
    livros = livrosReservas.value;
    filteredLivrosReservas.value = livros.filter(livro => livro.titulo.toLowerCase().includes(query));
  } else if (currentSection.value === 'disponiveis') {
    livros = livrosDisponiveis.value;
    filteredLivrosDisponiveis.value = livros.filter(livro => livro.titulo.toLowerCase().includes(query));
  }

  // Aplica a borda temporária nos livros encontrados
  livros.forEach(livro => {
    livro.isHighlighted = false;
  });

  if (searchQuery.value) {
    livros.forEach(livro => {
      livro.isHighlighted = true;
      setTimeout(() => {
        livro.isHighlighted = false;
      }, 2000); // Duração da borda (2 segundos)
    });
  }
}

// Dados para cadastro de livros
const novoLivro = ref({
  titulo: '',
  autor: '',
  descricao: ''
});

// Dados para cadastro de usuários
const novoUsuario = ref({
  nome: '',
  email: '',
  senha: '',
  telefone: ''
});

// Função para cadastrar livro
function cadastrarLivro() {
  if (novoLivro.value.titulo && novoLivro.value.autor && novoLivro.value.descricao) {
    livrosDisponiveis.value.push({ ...novoLivro.value });
    novoLivro.value = { titulo: '', autor: '', descricao: '' }; // Resetar formulário
  }
}

// Função para cadastrar usuário
function cadastrarUsuario() {
  if (novoUsuario.value.nome && novoUsuario.value.email && novoUsuario.value.senha && novoUsuario.value.telefone) {
    console.log('Usuário cadastrado:', novoUsuario.value);
    novoUsuario.value = { nome: '', email: '', senha: '', telefone: '' }; // Resetar formulário
  } else {
    console.log('Preencha todos os campos');
  }
}
</script>

<style>
.highlight {
  border: 2px solid #FF5733;
  padding: 4px;
  border-radius: 8px;
}
</style>
