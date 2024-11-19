<template>
  <v-app>
    <!-- Drawer Permanente -->
    <v-navigation-drawer app permanent>

      <v-list>
        <v-list-item @click="navigateTo('emprestimos')">
          <v-list-item-title>Empréstimos</v-list-item-title>
        </v-list-item>
        <v-list-item @click="navigateTo('disponiveis')">
          <v-list-item-title>Livros Disponíveis</v-list-item-title>
        </v-list-item>
        <v-list-item @click="navigateTo('reservas')">
          <v-list-item-title>Reservas</v-list-item-title>
        </v-list-item>
        <v-list-item @click="navigateTo('cadastro')">
          <v-list-item-title>Cadastro de Livros</v-list-item-title>
        </v-list-item>
        <v-list-item @click="navigateTo('cadastroUsuarios')">
          <v-list-item-title>Cadastro de Usuários</v-list-item-title>
        </v-list-item>
        <v-list-item @click="navigateTo('cadastroAdmins')">
          <v-list-item-title>Cadastro de Admins</v-list-item-title>
        </v-list-item>
        <!-- Nuevo ítem para cerrar sesión -->
        <v-list-item @click="logoutDialog = true">
          <v-list-item-title>Cerrar sesión</v-list-item-title>
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
        v-model="searchQuery" label="Buscar por título" solo clearable @input="searchBooks" />
    </v-app-bar>

    <!-- Conteúdo principal -->
    <v-main>
      <v-container>
        <!-- Mostrar conteúdo dependendo da seção selecionada -->
        <template v-if="currentSection === 'emprestimos'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosEmprestimo" :key="index" cols="12" md="4">
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :descricao="livro.descricao"
                :data-emprestimo="livro.dataEmprestimo" :class="{ highlight: livro.isHighlighted }" />
            </v-col>
          </v-row>
        </template>

        <template v-if="currentSection === 'reservas'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosReservas" :key="index" cols="12" md="4">
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :descricao="livro.descricao" :reservado="true"
                :class="{ highlight: livro.isHighlighted }" />
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

        <template v-if="currentSection === 'cadastroAdmins'">
          <!-- Formulário de cadastro de admins -->
          <v-form>
            <v-text-field label="Username" v-model="novoAdmin.username" />
            <v-text-field label="Senha" type="password" v-model="novoAdmin.senha" />
            <v-btn @click="cadastrarAdmin">Cadastrar Admin</v-btn>
          </v-form>
        </template>


        <template v-if="currentSection === 'disponiveis'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosDisponiveis" :key="index" cols="12" md="4">
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :descricao="livro.descricao"
                :class="{ highlight: livro.isHighlighted }" />
            </v-col>
          </v-row>
        </template>
      </v-container>
    </v-main>
    <!-- Diálogo de Login -->
    <v-dialog v-model="loginDialog" persistent max-width="400">
      <v-card>
        <v-card-title>Login de Admin</v-card-title>
        <v-card-text>
          <v-text-field v-model="adminLogin.username" label="Username" />
          <v-text-field v-model="adminLogin.password" label="Senha" type="password" />
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" @click="handleLogin">Login</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!-- Pie de página -->

    <v-dialog v-model="logoutDialog" persistent max-width="400">
      <v-card>
        <v-card-title>Cerrar sesión</v-card-title>
        <v-card-text>
          ¿Estás seguro de que deseas cerrar sesión?
        </v-card-text>
        <v-card-actions>
          <v-btn text @click="logoutDialog = false">Cancelar</v-btn>
          <v-btn color="primary" @click="confirmLogout">Confirmar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>


    <AppFooter />
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import AppFooter from '@/components/AppFooter.vue';
import cardLivro from '@/components/CardLivro.vue';



// Estado de autenticación
const isAuthenticated = ref(localStorage.getItem('adminToken') !== null); // Esto también asigna el valor a `isAuthenticated`.
const loginDialog = ref(false);
const currentSection = ref('emprestimos');

// Datos de login
const adminLogin = ref({
  username: '',
  password: '',
});

// Datos para cadastro de admins
const novoAdmin = ref({
  username: '',
  senha: '',
});




function navigateTo(section) {
  const seccionesProtegidas = ['emprestimos', 'disponiveis', 'reservas', 'cadastro', 'cadastroUsuarios', 'cadastroAdmins'];

  // Verifica si el usuario no está autenticado y si la sección es una protegida
  if (!isAuthenticated.value && seccionesProtegidas.includes(section)) {
    loginDialog.value = true; // Mostrar diálogo de login
  } else {
    currentSection.value = section; // Navegar a la sección
  }
}



// Función para cadastrar admin
function cadastrarAdmin() {
  if (novoAdmin.value.nome && novoAdmin.value.username && novoAdmin.value.senha) {
    console.log('Admin cadastrado:', novoAdmin.value);
    novoAdmin.value = { username: '', senha: '' };
  } else {
    console.log('Preencha todos os campos');
  }
}

import axios from 'axios';

function handleLogin() {
  // Log de los datos que se están enviando
  console.log("Datos enviados para login:", {
    username: adminLogin.value.username,
    password: adminLogin.value.password
  });

  axios.post('http://localhost:3000/api/admin/authenticate', {
    username: adminLogin.value.username,
    password: adminLogin.value.password,
  })
    .then((response) => {
      console.log("Respuesta del backend:", response); // Verificar la respuesta del backend
      localStorage.setItem('adminToken', response.data.token);
      isAuthenticated.value = true;
      loginDialog.value = false;
    })
    .catch((error) => {
      console.error("Error al iniciar sesión:", error.response || error); // Verifica el error completo
      alert('Credenciales inválidas');
    });
}

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

const logoutDialog = ref(false);


function confirmLogout() {
  // Cerrar sesión y redirigir
  localStorage.removeItem('adminToken'); // Eliminar el token al hacer logout
  isAuthenticated.value = false;
  currentSection.value = 'emprestimos'; // O la sección que desees
  logoutDialog.value = false; // Cerrar el diálogo
}


</script>

<style>
.highlight {
  border: 2px solid #FF5733;
  padding: 4px;
  border-radius: 8px;
}
</style>
