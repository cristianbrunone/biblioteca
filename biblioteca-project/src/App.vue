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
          <!-- Exibe o item apenas se o usuário for superadmin -->
        <v-list-item v-if="isSuperAdmin" @click="navigateTo('cadastroAdmins')">
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

       <template v-if="isSuperAdmin && currentSection === 'cadastroAdmins'">
          <!-- Formulário de cadastro de admins -->
          <v-form>
            <v-text-field label="Username" v-model="novoAdmin.username" />
            <v-text-field label="Senha" type="password" v-model="novoAdmin.senha" />
            <v-btn @click="cadastrarAdmin">Cadastrar Admin</v-btn>
          </v-form>
        </template>
        
        <template v-else-if="currentSection === 'cadastroAdmins'">
        <v-alert type="error">Você não tem permissão para acessar esta seção.</v-alert>
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

 // Importa como una función predeterminada

import axios from 'axios';
import { ref } from 'vue';
import AppFooter from '@/components/AppFooter.vue';
import cardLivro from '@/components/CardLivro.vue';
import { jwtDecode } from 'jwt-decode';


// Estado de autenticación
const isAuthenticated = ref(localStorage.getItem('adminToken') !== null); // Esto también asigna el valor a `isAuthenticated`.
const loginDialog = ref(false);
const currentSection = ref('emprestimos');

axios.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

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

const isSuperAdmin = ref(false);
onMounted(async () => {
  isSuperAdmin.value = await verificarSuperAdmin();
});


async function verificarSuperAdmin() {
  const token = localStorage.getItem('adminToken'); // Obtener el token de localStorage
  
  if (!token) {
    console.error('[ERROR] Token no encontrado');
    isSuperAdmin.value = false; // Usuario no autenticado
    return false;
  }

  try {
    const decoded = jwtDecode(token); // Usar jwtDecode correctamente
    isSuperAdmin.value = decoded.role === 'superadmin'; // Verificar el rol
    console.log('[INFO] ¿Es Superadmin?', isSuperAdmin.value);
    return isSuperAdmin.value;
  } catch (error) {
    console.error('[ERROR] Fallo al verificar rol del usuario:', error.message);
    isSuperAdmin.value = false;
    return false;
  }
}


function navigateTo(section) {
  const seccionesProtegidas = ['emprestimos', 'disponiveis', 'reservas', 'cadastro', 'cadastroUsuarios', 'cadastroAdmins'];

  // Verifica si el usuario no está autenticado y si la sección es una protegida
  if (!isAuthenticated.value && seccionesProtegidas.includes(section)) {
    loginDialog.value = true; // Mostrar diálogo de login
  } else {
    currentSection.value = section; // Navegar a la sección
  }
}

async function cadastrarAdmin() {
  try {
    if (!novoAdmin.value.username || !novoAdmin.value.senha) {
      console.log('Preencha todos os campos');
      return;
    }

    const token = localStorage.getItem('adminToken');
    if (!token) {
      console.log('Você não está autenticado');
      return;
    }

    const response = await axios.post(
      'http://localhost:3000/api/admin/register',
      {
        username: novoAdmin.value.username,
        password: novoAdmin.value.senha,
        role: 'admin', 
      },
      {
        headers: {
          Authorization: `Bearer ${token}`, // Incluye el token del superadmin
        },
      }
    );

    console.log('Admin cadastrado com sucesso:', response.data);
    novoAdmin.value = { username: '', senha: '' }; // Limpar formulário
  } catch (error) {
    console.error('Erro ao cadastrar admin:', error.response?.data || error.message);
  }
}


function handleLogin() {
  console.log('[INFO] Intentando iniciar sesión con:', adminLogin.value);

  axios.post('http://localhost:3000/api/admin/authenticate', {
    username: adminLogin.value.username,
    password: adminLogin.value.password,
  })
    .then(async (response) => {
      console.log('[INFO] Login exitoso, token recibido:', response.data.token);
      localStorage.setItem('adminToken', response.data.token);

      isAuthenticated.value = true;
      loginDialog.value = false;

      // Verificar si es superadmin después del login
      await verificarSuperAdmin();
    })
    .catch((error) => {
      console.error('[ERROR] Error al iniciar sesión:', error.response?.data || error.message);
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
