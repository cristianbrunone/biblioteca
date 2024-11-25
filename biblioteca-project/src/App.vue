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
            <v-col v-for="(livro, index) in filteredLivrosDisponiveis" :key="index" cols="12" md="4">
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :categoria="livro.categoria"
                @click.native="selecionarLivro(livro.id)" />
            </v-col>
          </v-row>
        </template>

        <template v-if="currentSection === 'reservas'">
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosReservas" :key="index" cols="12" md="4">
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :categoria="livro.categoria" :reservado="true"
                :class="{ highlight: livro.isHighlighted }" />
            </v-col>
          </v-row>
        </template>

        <template v-if="currentSection === 'cadastro'">
          <!-- Formulário de cadastro de livros -->
          <v-form>
            <v-text-field label="Título do Livro" v-model="novoLivro.titulo" />
            <v-text-field label="Autor" v-model="novoLivro.autor" />
            <v-textarea label="Categoria" v-model="novoLivro.categoria" />
            <v-btn @click="cadastrarLivro">Cadastrar Livro</v-btn>
            <v-alert v-if="cadastroLivroSuccess" type="success">Livro cadastrado com sucesso!</v-alert>
            <v-alert v-if="cadastroLivroError" type="error">Erro ao cadastrar o livro. Tente novamente.</v-alert>
          </v-form>
        </template>

        <template v-if="currentSection === 'cadastroUsuarios'">
          <!-- Formulário de cadastro de usuários -->
          <v-form ref="usuarioForm" @submit.prevent="cadastrarUsuario">
            <v-text-field label="Nome do Usuário" v-model="novoUsuario.nome" :rules="nomeRules" />
            <v-text-field label="Idade" v-model="novoUsuario.idade" :rules="idadeRules" />
            <v-text-field label="Telefone" v-model="novoUsuario.contato_responsavel" :rules="contatoRules" />
            <v-btn type="submit">Cadastrar Usuário</v-btn>
          </v-form>

          <!-- Exibição da mensagem de sucesso ou erro -->
          <v-alert v-if="cadastroSuccess" type="success">Usuário cadastrado com sucesso!</v-alert>
          <v-alert v-if="cadastroError" type="error">Erro ao cadastrar o usuário. Tente novamente.</v-alert>
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
              <!-- Passa o ID do livro ao clicar no card -->
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :categoria="livro.categoria"
                @click.native="selecionarLivro(livro.id)" />
            </v-col>
          </v-row>

          <!-- Botão de Emprestar Livro -->
          <v-btn @click="handleEmprestarLivro" color="primary" :disabled="!livroSelecionado">
            Emprestar Livro
          </v-btn>

          <!-- Campo de Busca -->
          <v-dialog v-model="showDropdown" persistent max-width="500px">
            <v-card>
              <v-card-title>
                <span class="headline">Buscar por Contato Responsável</span>
              </v-card-title>
              <v-card-text>
                <v-text-field v-model="searchUserByContatoResponsavel" label="Digite o contato responsável"
                  @input="searchUsuarios" />

                <!-- Lista de usuários filtrados -->
                <v-list dense>
                  <v-list-item-group v-if="filteredUsuarios.length">
                    <v-list-item v-for="usuario in filteredUsuarios" :key="usuario.id"
                      @click="fazerEmprestimo(usuario.id)">
                      <v-list-item-content>
                        <v-list-item-title>{{ usuario.nome }}</v-list-item-title>
                        <v-list-item-subtitle>{{ usuario.contato_responsavel }}</v-list-item-subtitle>
                      </v-list-item-content>
                    </v-list-item>
                  </v-list-item-group>
                  <v-list-item v-if="!filteredUsuarios.length">
                    <v-list-item-content>
                      <v-list-item-title>Nenhum usuário encontrado</v-list-item-title>
                    </v-list-item-content>
                  </v-list-item>
                </v-list>
              </v-card-text>
              <v-card-actions>
                <v-btn @click="showDropdown = false" color="grey">Cancelar</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
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
// Importa las dependencias
import axios from 'axios';
import { ref, onMounted } from 'vue';
import AppFooter from '@/components/AppFooter.vue';
import cardLivro from '@/components/CardLivro.vue';
import { jwtDecode } from 'jwt-decode';

// Estado de autenticación
const isAuthenticated = ref(localStorage.getItem('adminToken') !== null);
const isSuperAdmin = ref(false);
const loginDialog = ref(false);
const logoutDialog = ref(false);
const currentSection = ref('emprestimos');
// Estado do dropdown de usuários
const showDropdown = ref(false);
// Estado do campo de busca
const searchUserByContatoResponsavel = ref('');

// Datos de login y autenticación
const adminLogin = ref({ username: '', password: '' });
const novoAdmin = ref({ username: '', senha: '' });
const novoUsuario = ref({ nome: '', idade: '', contato_responsavel: '' });
const novoLivro = ref({ titulo: '', autor: '', categoria: '' });

// Filtro de libros
const searchQuery = ref('');
const filteredLivrosEmprestimo = ref([]);
const filteredLivrosReservas = ref([]);
const filteredLivrosDisponiveis = ref([]);

// Estado de operaciones
const cadastroSuccess = ref(false);
const cadastroError = ref(false);
const cadastroLivroSuccess = ref(false);
const cadastroLivroError = ref(false);

// Reglas de validación
const nomeRules = [v => !!v || 'Nome é obrigatório'];
const idadeRules = [v => !!v || 'Idade é obrigatória', v => (v && !isNaN(v)) || 'Idade deve ser um número válido'];
const contatoRules = [v => !!v || 'Telefone é obrigatório', v => /^(?:\+?\d{1,3})?\d{8,15}$/.test(v) || 'Telefone inválido'];

// Usuarios
const usuarios = ref([]);
const filteredUsuarios = ref([]);

const livroSelecionado = ref(null); // Estado para armazenar o ID do livro

function selecionarLivro(id) {
  livroSelecionado.value = id; // Armazena o ID do livro selecionado
  console.log('Livro selecionado:', id); // Log para depuração
}



// Métodos relacionados con la autenticación
async function verificarSuperAdmin() {
  const token = localStorage.getItem('adminToken');
  if (!token) {
    isSuperAdmin.value = false;
    return false;
  }

  try {
    const decoded = jwtDecode(token);
    isSuperAdmin.value = decoded.role === 'superadmin';
    return isSuperAdmin.value;
  } catch {
    isSuperAdmin.value = false;
    return false;
  }
}

async function handleLogin() {
  try {
    const response = await axios.post('http://localhost:3000/api/admin/authenticate', adminLogin.value);
    const token = response.data.token;
    console.log('Token obtenido:', token); // Log del token
    localStorage.setItem('adminToken', token);
    isAuthenticated.value = true;
    loginDialog.value = false;
    await verificarSuperAdmin();
  } catch {
    alert('Credenciales inválidas');
  }
}

async function handleEmprestarLivro() {
  if (!livroSelecionado.value) {
    alert('Por favor, selecione um livro para continuar.');
    return;
  }

  // Abre o dropdown de seleção de usuário
  if (!showDropdown.value) {
    await carregarUsuarios();
  }
  showDropdown.value = true;
}



function searchUsuarios() {
  const query = searchUserByContatoResponsavel.value.toLowerCase();
  filteredUsuarios.value = usuarios.value.filter(usuario =>
    usuario.contato_responsavel.toLowerCase().includes(query)
  );
}

// Métodos de carga
async function carregarUsuarios() {
  const token = localStorage.getItem('adminToken');
  if (!token) return;

  try {
    const response = await axios.get('http://localhost:3000/api/usuarios', {
      headers: { Authorization: `Bearer ${token}` },
    });
    console.log('Usuários carregados:', response.data); // Verifique a estrutura aqui
    usuarios.value = response.data;
  } catch (error) {
    console.error('Erro ao carregar usuários:', error.message);
  }
}


async function getLivrosDisponiveis() {
  const token = localStorage.getItem('adminToken');
  if (!token) return;

  try {
    const response = await axios.get('http://localhost:3000/api/livros/disponiveis', {
      headers: { Authorization: `Bearer ${token}` },
    });
    filteredLivrosDisponiveis.value = response.data;
  } catch (error) {
    console.error('Erro ao carregar os livros disponíveis:', error.message);
  }
}

// Métodos de secciones
function navigateTo(section) {
  const seccionesProtegidas = ['emprestimos', 'disponiveis', 'reservas', 'cadastro', 'cadastroUsuarios', 'cadastroAdmins'];
  if (!isAuthenticated.value && seccionesProtegidas.includes(section)) {
    loginDialog.value = true;
  } else {
    currentSection.value = section;
  }
}

function confirmLogout() {
  localStorage.removeItem('adminToken');
  isAuthenticated.value = false;
  currentSection.value = 'emprestimos';
  logoutDialog.value = false;
}

// Métodos de CRUD
async function cadastrarUsuario() {
  if (!novoUsuario.value.nome || !novoUsuario.value.idade || !novoUsuario.value.contato_responsavel) {
    console.error('Preencha todos os campos obrigatórios');
    return;
  }

  const token = localStorage.getItem('adminToken');
  if (!token) return;

  try {
    await axios.post('http://localhost:3000/api/usuario/register', novoUsuario.value, { headers: { Authorization: `Bearer ${token}` } });
    novoUsuario.value = { nome: '', idade: '', contato_responsavel: '' };
  } catch (error) {
    console.error('Erro ao cadastrar usuário:', error.message);
  }
}

async function cadastrarAdmin() {
  if (!novoAdmin.value.username || !novoAdmin.value.senha) return;

  const token = localStorage.getItem('adminToken');
  if (!token) return;

  try {
    await axios.post('http://localhost:3000/api/admin/register', { ...novoAdmin.value, role: 'admin' }, { headers: { Authorization: `Bearer ${token}` } });
    novoAdmin.value = { username: '', senha: '' };
  } catch (error) {
    console.error('Erro ao cadastrar admin:', error.message);
  }
}

async function cadastrarLivro() {
  if (!novoLivro.value.titulo || !novoLivro.value.autor || !novoLivro.value.categoria) {
    console.error('Preencha todos os campos obrigatórios');
    return;
  }

  const token = localStorage.getItem('adminToken');
  if (!token) return;

  try {
    await axios.post('http://localhost:3000/api/livro/register', novoLivro.value, { headers: { Authorization: `Bearer ${token}` } });
    novoLivro.value = { titulo: '', autor: '', categoria: '' };
    cadastroLivroSuccess.value = true;
  } catch (error) {
    cadastroLivroError.value = true;
  }
}

async function fazerEmprestimo(usuarioId) {
  if (!livroSelecionado.value || !usuarioId) {
    console.error('ID do livro ou usuário ausente.');
    alert('Selecione um livro e um usuário antes de continuar.');
    return;
  }

  console.log('Dados para empréstimo:', { livroId: livroSelecionado.value, usuarioId });

  const token = localStorage.getItem('adminToken');
  if (!token) {
    alert('Usuário não autenticado.');
    return;
  }

  try {
    const response = await axios.post(
      'http://localhost:3000/api/emprestimos',
      {
        id_livro: livroSelecionado.value,
        id_usuario: usuarioId,
      },
      { headers: { Authorization: `Bearer ${token}` } }
    );

    alert('Empréstimo realizado com sucesso!');
    console.log('Resposta da API:', response.data);
    livroSelecionado.value = null; // Limpa o ID do livro após o empréstimo
    showDropdown.value = false; // Fecha o modal
  } catch (error) {
    console.error('Erro ao realizar o empréstimo:', error.response?.data || error.message);
    alert('Erro ao realizar o empréstimo. Tente novamente.');
  }
}




// Métodos de búsqueda
function searchBooks() {
  const query = searchQuery.value.toLowerCase();
  let livros = [];

  if (currentSection.value === 'emprestimos') {
    livros = filteredLivrosEmprestimo.value;
  } else if (currentSection.value === 'reservas') {
    livros = filteredLivrosReservas.value;
  } else if (currentSection.value === 'disponiveis') {
    livros = filteredLivrosDisponiveis.value;
  }

  livros.forEach(livro => livro.isHighlighted = false);
  if (searchQuery.value) {
    livros.forEach(livro => {
      livro.isHighlighted = true;
      setTimeout(() => livro.isHighlighted = false, 2000);
    });
  }
}

// Cargar datos cuando el componente se monta
onMounted(async () => {
  if (localStorage.getItem('adminToken')) {
    isAuthenticated.value = true;
    await verificarSuperAdmin();
  } else {
    isAuthenticated.value = false;
    isSuperAdmin.value = false;
  }
  await carregarUsuarios();
  await getLivrosDisponiveis();
});
</script>



<style>
.highlight {
  border: 2px solid #FF5733;
  padding: 4px;
  border-radius: 8px;
}
</style>
