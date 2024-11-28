<template>
  <v-app>
    <v-navigation-drawer app permanent>
      <v-list>
        <!-- Título del panel -->
        <v-list-item>
          <v-list-item-title class="text-h6 font-weight-bold mb-3 mt-2">Painel de operação</v-list-item-title>
        </v-list-item>

        <v-divider></v-divider> <!-- Línea divisoria para separar el título de los ítems -->

             <!-- Ítem de Login -->
          
        <!-- Ítem de Login -->
       <v-list-item v-if="!isAuthenticated" @click="navigateTo('login')"
      :class="{ 'v-list-item--active': currentSection === 'login' }" class="my-0">
      <v-list-item-icon>
        <v-icon>mdi-book-open</v-icon>
      </v-list-item-icon>
      <v-list-item-title>Login</v-list-item-title>
    </v-list-item>
             
        <!-- Ítem de Empréstimos -->
    <template v-if="isAuthenticated">
        <v-list-item @click="navigateTo('emprestimos')"
          :class="{ 'v-list-item--active': currentSection === 'emprestimos' }" class="my-0">
          <v-list-item-icon>
            <v-icon>mdi-book-open</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Empréstimos</v-list-item-title>
        </v-list-item>


         <v-list-item v-if="isSuperAdmin" @click="navigateTo('emprestimosAtivosInativos')" :class="{ 'v-list-item--active': currentSection === 'emprestimosAtivosInativos' }">
          <v-list-item-icon><v-icon>mdi-table</v-icon></v-list-item-icon>
          <v-list-item-title>Empréstimos Ativos/Inativos</v-list-item-title>
        </v-list-item>

        <!-- Ítem de Livros Disponíveis -->
        <v-list-item @click="navigateTo('disponiveis')"
          :class="{ 'v-list-item--active': currentSection === 'disponiveis' }" class="my-4">
          <v-list-item-icon>
            <v-icon>mdi-book</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Livros Disponíveis</v-list-item-title>
        </v-list-item>

        <!-- Ítem de Reservas -->
        <v-list-item @click="navigateTo('reservas')" :class="{ 'v-list-item--active': currentSection === 'reservas' }"
          class="my-2">
          <v-list-item-icon>
            <v-icon>mdi-bookmark-check</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Reservas</v-list-item-title>
        </v-list-item>

        <!-- Ítem de Cadastro de Livros -->
        <v-list-item @click="navigateTo('cadastro')" :class="{ 'v-list-item--active': currentSection === 'cadastro' }"
          class="my-2">
          <v-list-item-icon>
            <v-icon>mdi-book-plus</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Cadastro de Livros</v-list-item-title>
        </v-list-item>

        <!-- Ítem de Cadastro de Usuários -->
        <v-list-item @click="navigateTo('cadastroUsuarios')"
          :class="{ 'v-list-item--active': currentSection === 'cadastroUsuarios' }" class="my-4">
          <v-list-item-icon>
            <v-icon>mdi-account-plus</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Cadastro de Usuários</v-list-item-title>
        </v-list-item>

        <!-- Ítem de Cadastro de Admins (para superadmin) -->
        <v-list-item v-if="isSuperAdmin" @click="navigateTo('cadastroAdmins')"
          :class="{ 'v-list-item--active': currentSection === 'cadastroAdmins' }" class="my-4">
          <v-list-item-icon>
            <v-icon>mdi-shield-account</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Cadastro de Admins</v-list-item-title>
        </v-list-item>

        <!-- Ítem para listar todos os usuários (somente para superadmin) -->
        <v-list-item v-if="isSuperAdmin" @click="navigateTo('usuarios')"
          :class="{ 'v-list-item--active': currentSection === 'usuarios' }" class="my-4">
          <v-list-item-icon>
            <v-icon>mdi-account-group</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Lista de Usuários</v-list-item-title>
        </v-list-item>
          </template>  

        <!-- Ítem para cerrar sesión -->
        <v-list-item @click="logoutDialog = true" class="my-4">
          <v-list-item-icon>
            <v-icon>mdi-logout</v-icon>
          </v-list-item-icon>
          <v-list-item-title>Cerrar sesión</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>



    <!-- Barra de navegação -->
  <v-app-bar :color="isSuperAdmin ? 'purple' : 'primary'" app>
  <v-toolbar-title class="text-center" style="flex-grow: 1;">
    Biblioteca ONG
    <span v-if="isSuperAdmin"> - Olá Admin</span>
   </v-toolbar-title>
  </v-app-bar>


    <!-- Conteúdo principal -->
    <v-main>
      <v-container>
        <!-- Mostrar conteúdo dependendo da seção selecionada -->
        <template v-if="currentSection === 'emprestimos'">
          <!-- Alert de sucesso -->
          <v-alert v-if="sucessoFinalizacao" type="success" dismissible>
            Empréstimo finalizado com sucesso!
          </v-alert>

          <!-- Alert de erro -->
          <v-alert v-if="erroFinalizacao" type="error" dismissible>
            Erro ao finalizar empréstimo. Tente novamente.
          </v-alert>

          <v-row>
            <v-col v-for="(emprestimo, index) in emprestimosAtivos" :key="index" cols="12" md="4">
              <v-card class="elevation-12" :style="cardStyle">
                <v-card-title class="headline font-weight-bold">{{ emprestimo.nome_livro || "Livro não disponível" }}</v-card-title>
                <v-card-subtitle class="subheading mb-2">{{ emprestimo.nome_usuario }}</v-card-subtitle>
                <v-card-text class="text--primary">
                  <div><strong>Data de Empréstimo:</strong> {{ emprestimo.data_emprestimo }}</div>
                  <div><strong>Data de Devolução:</strong> {{ emprestimo.data_devolucao }}</div>
                </v-card-text>
                <v-card-actions>
                  <!-- Botão de Finalizar -->
                  <v-btn @click="finalizarEmprestimo(emprestimo.id_emprestimo)" color="red"
                    class="text-weight-bold">Finalizar Empréstimo</v-btn>
                </v-card-actions>
              </v-card>
            </v-col>
          </v-row>
        </template>
        <template v-if="currentSection === 'usuarios'">
          <v-row>
            <v-col v-for="(usuario, index) in usuarios" :key="index" cols="12" md="4">
              <v-card class="elevation-8 my-5" :style="cardStyle">
                <v-card-title class="headline font-weight-bold text-h6" style="color: #333;">
                  {{ usuario.nome }}
                </v-card-title>
                <v-card-subtitle class="body-2 font-weight-medium" style="color: #555;">
                  Usuário ONG
                </v-card-subtitle>
                <v-divider></v-divider>
                <v-card-text class="text--secondary" style="color: #666;">
                  <div><strong>Idade:</strong> {{ usuario.idade }} anos</div>
                  <div><strong>Contato:</strong> {{ usuario.contato_responsavel }}</div>
                </v-card-text>
                <v-divider></v-divider>
                <v-card-actions>
                  <v-btn text color="red" @click="confirmDelete(usuario.id)">Excluir</v-btn>
                </v-card-actions>
              </v-card>
            </v-col>
          </v-row>
          <v-dialog v-model="deleteDialog" max-width="500">
            <v-card>
              <v-card-title class="headline">Confirmar exclusão</v-card-title>
              <v-card-text>Tem certeza de que deseja excluir este usuário? Esta ação não pode ser
                desfeita.</v-card-text>
              <v-card-actions>
                <v-btn text color="red" @click="deleteUser()">Sim, excluir</v-btn>
                <v-btn text color="gray" @click="deleteDialog = false">Cancelar</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
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
          <v-form ref="livroForm" @submit.prevent="cadastrarLivro" :rules="livroFormRules">
            <v-text-field label="Título do Livro" v-model="novoLivro.titulo" :rules="livroTitleRules"
              :error-messages="livroTitleError" />
            <v-text-field label="Autor" v-model="novoLivro.autor" :rules="livroAuthorRules"
              :error-messages="livroAuthorError" />
            <v-textarea label="Categoria" v-model="novoLivro.categoria" :rules="livroCategoryRules"
              :error-messages="livroCategoryError" />
            <v-btn type="submit">Cadastrar Livro</v-btn>
            <v-alert v-if="cadastroLivroSuccess" type="success">Livro cadastrado com sucesso!</v-alert>
            <v-alert v-if="cadastroLivroError" type="error">Erro ao cadastrar o livro. Tente novamente.</v-alert>
          </v-form>
        </template>

         <template v-if="currentSection === 'login'">
          <!-- Formulário de cadastro de livros -->
          <v-card>
        <v-card-title>Login de Admin</v-card-title>
        <v-card-text>
          <v-text-field v-model="adminLogin.username" label="Username" />
          <v-text-field v-model="adminLogin.password" label="Password" type="password" />
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" @click="handleLogin">Login</v-btn>
        </v-card-actions>
      </v-card>
        </template>

        <template v-if="currentSection === 'cadastroUsuarios'">
          <!-- Formulário de cadastro de usuários -->
          <v-form ref="usuarioForm" @submit.prevent="cadastrarUsuario">
            <v-text-field label="Nome do Usuário" v-model="novoUsuario.nome" :rules="nomeRules"
              :error-messages="nomeError" />
            <v-text-field label="Idade" v-model="novoUsuario.idade" :rules="idadeRules" :error-messages="idadeError" />
            <v-text-field label="Telefone" v-model="novoUsuario.contato_responsavel" :rules="contatoRules"
              :error-messages="contatoError" />
            <v-btn type="submit">Cadastrar Usuário</v-btn>
          </v-form>

          <!-- Exibição da mensagem de sucesso ou erro -->
          <v-alert v-if="cadastroSuccess" type="success">Usuário cadastrado com sucesso!</v-alert>
          <v-alert v-if="cadastroError" type="error">Erro ao cadastrar o usuário. Tente novamente.</v-alert>
        </template>


        <template v-if="isSuperAdmin && currentSection === 'cadastroAdmins'">
          <!-- Formulário de cadastro de admins -->
          <v-form ref="adminForm" @submit.prevent="cadastrarAdmin">
            <v-text-field label="Username" v-model="novoAdmin.username" :rules="adminUsernameRules"
              :error-messages="adminUsernameError" />
            <v-text-field label="Password" type="password" v-model="novoAdmin.password" :rules="adminPasswordRules"
              :error-messages="adminPasswordError" />
            <!-- Dropdown para selecionar o role -->
            <v-select label="Role" v-model="novoAdmin.role" :items="rolesDisponiveis" :rules="[roleSelecionada]" />
            <v-btn type="submit">Cadastrar Admin</v-btn>
          </v-form>
        </template>



        <template v-else-if="currentSection === 'cadastroAdmins'">
          <v-alert type="error">Você não tem permissão para acessar esta seção.</v-alert>
        </template>
        <template v-if="currentSection === 'disponiveis'">
          <!-- Cards de Livros Disponíveis -->
          <v-row>
            <v-col v-for="(livro, index) in filteredLivrosDisponiveis" :key="index" cols="12" md="4">
              <!-- Card do Livro -->
              <card-livro :titulo="livro.titulo" :autor="livro.autor" :categoria="livro.categoria"
                @click.native="selecionarLivro(livro.id)" />

              <!-- Botão de Emprestar Livro -->
              <v-btn class="mt-3 mx-auto" color="primary" :disabled="!livro.id" @click="handleEmprestarLivro(livro.id)"
                style="max-width: 100%;">
                <v-icon left>mdi-book-open</v-icon>
                Emprestar
              </v-btn>
            </v-col>
          </v-row>

          <!-- Campo de Busca -->
          <v-dialog v-model="showDropdown" persistent max-width="500px">
            <v-card>
              <!-- Título do Diálogo -->
              <v-card-title class="d-flex justify-space-between align-center">
                <div class="d-flex align-center">
                  <v-icon left color="primary" size="36">mdi-magnify</v-icon>
                  <span class="headline ml-2">Buscar por Contato Responsável</span>
                </div>

                <!-- Ícone de fechamento -->
                <v-icon class="cursor-pointer" @click="showDropdown = false" color="grey" size="36">
                  mdi-close
                </v-icon>
              </v-card-title>

              <!-- Corpo do Diálogo -->
              <v-card-text>
                <v-text-field v-model="searchUserByContatoResponsavel" label="Digite o contato responsável" outlined
                  clearable @input="searchUsuarios" />

                <!-- Lista de usuários filtrados -->
                <v-list dense>
                  <template v-if="filteredUsuarios.length">
                    <v-list-item-group>
                      <v-list-item v-for="usuario in filteredUsuarios" :key="usuario.id"
                        @click="fazerEmprestimo(usuario.id)">
                        <v-list-item-icon>
                          <v-icon color="primary">mdi-account</v-icon>
                        </v-list-item-icon>
                        <v-list-item-content>
                          <v-list-item-title>{{ usuario.nome }}</v-list-item-title>
                          <v-list-item-subtitle>{{ usuario.contato_responsavel }}</v-list-item-subtitle>
                        </v-list-item-content>
                      </v-list-item>
                    </v-list-item-group>
                  </template>
                  <template v-else>
                    <v-list-item>
                      <v-list-item-content>
                        <v-list-item-title class="text-center">
                          Nenhum usuário encontrado
                        </v-list-item-title>
                      </v-list-item-content>
                    </v-list-item>
                  </template>
                </v-list>
              </v-card-text>
            </v-card>
          </v-dialog>

          <!-- Exibir alertas de sucesso e erro -->
          <v-alert v-if="sucessoFinalizacao" type="success" dismissible>
            Empréstimo finalizado com sucesso!
          </v-alert>
          <v-alert v-if="erroFinalizacao" type="error" dismissible>
            Ocorreu um erro ao finalizar o empréstimo. Tente novamente.
          </v-alert>
        </template>

          <!-- Exibindo empréstimos ativos e inativos -->
      <template v-if="currentSection === 'emprestimosAtivosInativos'">
  <v-row>
    <v-col cols="12">
      <!-- Botão para imprimir -->
      <v-btn @click="exportToPDF" color="primary" fab>
        <v-icon>mdi-printer</v-icon>
      </v-btn>

      <!-- Tabela de empréstimos -->
      <v-data-table
        :headers="tableHeaders"
        :items="emprestimosAtivosInativos"
        item-value="id_emprestimo"
        class="elevation-1 mt-5"
      >
        <template v-slot:item.data_emprestimo="{ item }">
          <span>{{ item.data_emprestimo }}</span>
        </template>

        <template v-slot:item.data_devolucao="{ item }">
          <span>{{ item.data_devolucao }}</span>
        </template>

        <template v-slot:item.status="{ item }">
          <span>{{ item.status }}</span>
        </template>
      </v-data-table>
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
          <v-text-field v-model="adminLogin.password" label="Password" type="password" />
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
import { jsPDF } from "jspdf";

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
const novoAdmin = ref({ username: '', password: '', role: '' });
const novoUsuario = ref({ nome: '', idade: '', contato_responsavel: '' });
const novoLivro = ref({ titulo: '', autor: '', categoria: '' });

// Filtro de libros
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

// Regras de validação para livros
const livroTitleRules = [
  v => !!v || 'Título é obrigatório',
  v => (v && v.length <= 100) || 'Título deve ter no máximo 100 caracteres'
];
const livroAuthorRules = [
  v => !!v || 'Autor é obrigatório',
  v => (v && v.length <= 50) || 'Autor deve ter no máximo 50 caracteres'
];
const livroCategoryRules = [
  v => !!v || 'Categoria é obrigatória',
  v => (v && v.length <= 30) || 'Categoria deve ter no máximo 30 caracteres'
];

// Estado de erro (opcional) para exibir mensagens personalizadas
const livroTitleError = ref('');
const livroAuthorError = ref('');
const livroCategoryError = ref('');



// Valores disponíveis no dropdown
const rolesDisponiveis = ['admin', 'superadmin'];

// Regras de validação
const adminUsernameRules = [(v) => !!v || 'O username é obrigatório'];
const adminPasswordRules = [(v) => !!v || 'A senha é obrigatória'];
const roleSelecionada = (v) => !!v || 'Selecione um papel (role)';


// Usuarios
const usuarios = ref([]);
const filteredUsuarios = ref([]);

const livroSelecionado = ref(null); // Estado para armazenar o ID do livro

function selecionarLivro(id) {
  livroSelecionado.value = id; // Armazena o ID do livro selecionado
  console.log('Livro selecionado:', id); // Log para depuração
}


// Cabeçalhos da tabela
const headers = [
  { text: 'Nome do Livro', align: 'start', key: 'nome_livro' },
  { text: 'Usuário', align: 'start', key: 'nome_usuario' },
  { text: 'Data de Empréstimo', align: 'start', key: 'data_emprestimo' },
  { text: 'Data de Devolução', align: 'start', key: 'data_devolucao' },
  { text: 'Status', align: 'start', key: 'status' },
];


function formatDate(date) {
  const parsedDate = new Date(date);
  if (isNaN(parsedDate)) {
    console.error("Data inválida:", date);
    return null;
  }
  return parsedDate.toLocaleDateString('pt-BR');
}


const emprestimosAtivosInativos = ref([]);

// Función para obtener empréstimos ativos
async function carregarEmprestimosAtivosInativos() {
  try {
    const response = await axios.get('http://localhost:3000/api/emprestimos/ativoseinativos', {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('adminToken')}`,
      },
    });
    
    // Formatar as datas antes de atribuir aos emprestimosAtivosInativos
    emprestimosAtivosInativos.value = response.data.map((emprestimo) => ({
      ...emprestimo,
      data_emprestimo: formatDate(emprestimo.data_emprestimo),
      data_devolucao: formatDate(emprestimo.data_devolucao),
    }));
    
    sucessoCarregarEmprestimos.value = true;
    erroCarregarEmprestimos.value = false;
  } catch (error) {
    erroCarregarEmprestimos.value = true;
    sucessoCarregarEmprestimos.value = false;
  }
}


// Função para exportar os dados para PDF
// Função para exportar os dados para PDF
function exportToPDF() {
  const doc = new jsPDF();
  const pageWidth = doc.internal.pageSize.getWidth();
  const pageHeight = doc.internal.pageSize.getHeight();
  const margin = 14;
  const lineHeight = 10;
  const tableTopMargin = 60;

  // Cabeçalho
  doc.setFontSize(18);
  doc.setFont("helvetica", "bold");
  doc.text("Relatório de Empréstimos", pageWidth / 2, 20, { align: "center" });

  doc.setFontSize(14);
  doc.setFont("helvetica", "italic");
  doc.text("Biblioteca Cristian", pageWidth / 2, 30, { align: "center" });

  // Subtítulo com a data
  doc.setFontSize(12);
  doc.setFont("helvetica", "normal");
  doc.text(`Data do Relatório: ${new Date().toLocaleDateString()}`, margin, 45);

  // Linha divisória
  doc.setDrawColor(0, 0, 0); // Preto para linha
  doc.setLineWidth(0.5);
  doc.line(margin, 50, pageWidth - margin, 50);

  // Tabela - Cabeçalho
  let yPosition = tableTopMargin;
  doc.setFont("helvetica", "bold");
  doc.setTextColor(0, 0, 0); // Preto para o texto

  // Texto do cabeçalho sem bordas
  doc.text("ID", margin + 5, yPosition);
  doc.text("Data Empréstimo", margin + 35, yPosition);
  doc.text("Data Devolução", margin + 100, yPosition);
  doc.text("Status", margin + 160, yPosition);

  yPosition += lineHeight;

  // Tabela - Dados
  doc.setFont("helvetica", "normal");
  doc.setTextColor(0, 0, 0); // Preto para os dados
  emprestimosAtivosInativos.value.forEach((emprestimo, index) => {
    // Checar quebra de página
    if (yPosition > pageHeight - 30) {
      doc.addPage();
      yPosition = 20;

      // Repetir cabeçalho em nova página
      doc.setFont("helvetica", "bold");
      doc.text("ID", margin + 5, yPosition);
      doc.text("Data Empréstimo", margin + 35, yPosition);
      doc.text("Data Devolução", margin + 100, yPosition);
      doc.text("Status", margin + 160, yPosition);

      yPosition += lineHeight;
    }

    // Adicionar dados da tabela (sem bordas ou cores de fundo)
    doc.text(emprestimo.id_emprestimo.toString(), margin + 5, yPosition);
    doc.text(emprestimo.data_emprestimo, margin + 35, yPosition);
    doc.text(emprestimo.data_devolucao, margin + 100, yPosition);
    doc.text(emprestimo.status, margin + 160, yPosition);

    yPosition += lineHeight;
  });

  // Rodapé
  const totalPages = doc.internal.getNumberOfPages();
  for (let i = 1; i <= totalPages; i++) {
    doc.setPage(i);
    doc.setFontSize(10);

    // Texto "Desenvolvido por Cristian Brunone"
    const footerText = "Desenvolvido por Cristian Brunone - 2024";
    const textY = pageHeight - 10;

    // Adicionar linha ocupando toda a largura do documento
    doc.setDrawColor(0, 0, 0); // Cor da linha em preto
    doc.line(margin, textY - 6, pageWidth - margin, textY - 6); // Linha horizontal

    // Adicionar o texto
    doc.text(footerText, pageWidth / 2, textY, { align: "center" });
  }

  // Salvar o PDF
  doc.save("relatorio_emprestimos_biblioteca_cristian.pdf");
}








// Carregar dados ao montar o componente
onMounted(async () => {
  await verificarSuperAdmin();
  if (isSuperAdmin.value) {
    await carregarEmprestimosAtivosInativos();
  }
});


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

const sucessoFinalizacao = ref(false);  // Variável para controle do sucesso
const erroFinalizacao = ref(false);     // Variável para controle do erro

// Função para finalizar o empréstimo
async function finalizarEmprestimo(id_emprestimo) {
  try {
    const response = await axios.put(`http://localhost:3000/api/emprestimos/${id_emprestimo}/finalizar`, null, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('adminToken')}`,
      },
    });

    // Exibe o alerta de sucesso
    sucessoFinalizacao.value = true;
    erroFinalizacao.value = false;

    // Atualiza a UI (remover o empréstimo finalizado)
    filteredLivrosDisponiveis.value = filteredLivrosDisponiveis.value.filter(livro => livro.id !== id_emprestimo);
  } catch (error) {
    console.error('Erro ao finalizar empréstimo:', error.message);

    // Exibe o alerta de erro
    erroFinalizacao.value = true;
    sucessoFinalizacao.value = false;
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
    console.log('Usuários carregados:', response.data);
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
      const seccionesProtegidas = ["emprestimos", "disponiveis"];
      if (!isAuthenticated.value && seccionesProtegidas.includes(section)) {
        alert("Por favor, faça login primeiro!");
        currentSection.value = "login";
      } else {
        currentSection.value = section;

        if (section === "emprestimos") carregarEmprestimos();
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

    // Limpia los campos del formulario
    novoUsuario.value = { nome: '', idade: '', contato_responsavel: '' };

    // Muestra la alerta de éxito
    cadastroSuccess.value = true;
    cadastroError.value = false;  // Resetea el estado de error

    // Opcionalmente, ocultar el mensaje después de un tiempo
    setTimeout(() => {
      cadastroSuccess.value = false;
    }, 5000);

  } catch (error) {
    console.error('Erro ao cadastrar usuário:', error.message);

    // Muestra la alerta de error
    cadastroError.value = true;
    cadastroSuccess.value = false;  // Resetea el estado de éxito
  }
}


// Função para cadastrar admin
async function cadastrarAdmin() {
  if (!novoAdmin.value.username || !novoAdmin.value.password || !novoAdmin.value.role) {
    console.error('Preencha todos os campos obrigatórios');
    return;
  }

  const token = localStorage.getItem('adminToken');
  if (!token) {
    console.error('Token não encontrado');
    return;
  }

  const payload = { ...novoAdmin.value };
  const headers = { Authorization: `Bearer ${token}` };

  // Log para verificar o payload e os headers
  console.log('Payload enviado:', payload);
  console.log('Headers enviados:', headers);

  try {
    // Envia o objeto completo, incluindo o role selecionado
    console.log('Payload antes de enviar:', JSON.stringify(payload));

    await axios.post(
      'http://localhost:3000/api/admin/register',
      payload,
      { headers }
    );

    // Reseta os campos após o cadastro
    novoAdmin.value = { username: '', password: '', role: '' };
  } catch (error) {
    console.error('Erro ao cadastrar admin:', error.message);
    if (error.response) {
      console.error('Detalhes do erro:', error.response.data);
    }
  }
}

function getAdminName() {
  const token = localStorage.getItem('adminToken');
  if (token) {
    try {
      const decodedToken = jwt_decode(token); // Decodifica o token JWT
      return decodedToken.name || 'Nome não encontrado'; // Retorna o nome do admin
    } catch (error) {
      console.error('Erro ao decodificar o token:', error);
      return 'Erro ao obter o nome';
    }
  } else {
    console.error('Token não encontrado');
    return 'Token não encontrado';
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

    // Remove o livro emprestado de filteredLivrosDisponiveis
    filteredLivrosDisponiveis.value = filteredLivrosDisponiveis.value.filter(livro => livro.id !== livroSelecionado.value);

    livroSelecionado.value = null; // Limpa o ID do livro após o empréstimo
    showDropdown.value = false; // Fecha o modal
  } catch (error) {
    console.error('Erro ao realizar o empréstimo:', error.response?.data || error.message);
    alert('Erro ao realizar o empréstimo. Tente novamente.');
  }
}

const emprestimosAtivos = ref([]);

// Función para obtener empréstimos ativos
const getEmprestimosAtivos = async () => {
  try {
    const response = await axios.get('http://localhost:3000/api/emprestimos/ativos', {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('adminToken')}`,
      },
    });
    emprestimosAtivos.value = response.data;
  } catch (error) {
    console.error('Erro ao obter empréstimos ativos:', error);
  }
};




const deleteDialog = ref(false); // Controle da caixa de diálogo
const userToDelete = ref(null); // Armazena o ID do usuário a ser excluído

// Método para abrir a caixa de diálogo
function confirmDelete(userId) {
  userToDelete.value = userId;
  deleteDialog.value = true;
}

// Método para excluir o usuário
async function deleteUser() {
  const token = localStorage.getItem('adminToken'); // Recupera o token para autenticação
  try {
    await axios.delete(`http://localhost:3000/api/usuario/${userToDelete.value}`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    // Atualiza a lista de usuários
    usuarios.value = usuarios.value.filter(usuario => usuario.id !== userToDelete.value);
    alert('Usuário excluído com sucesso.');
  } catch (error) {
    console.error('Erro ao excluir usuário:', error.message);
    alert('Erro ao excluir o usuário.');
  } finally {
    deleteDialog.value = false; // Fecha a caixa de diálogo
  }
}





// Actualizar la lista al cambiar de sección
watch(currentSection, (newSection) => {
  if (newSection === 'emprestimos') {
    getEmprestimosAtivos();
  }
});


onMounted(async () => {
  // Verifica si el usuario está autenticado y tiene un token válido
  if (localStorage.getItem('adminToken')) {
    isAuthenticated.value = true;
    await verificarSuperAdmin();
  } else {
    isAuthenticated.value = false;
    isSuperAdmin.value = false;
  }

  // Carga los datos iniciales
  await carregarUsuarios();
  await getLivrosDisponiveis();

  // Llama a la función de préstamos activos
  getEmprestimosAtivos();

  // Actualiza los empréstimos a cada 5 segundos
  setInterval(getEmprestimosAtivos, 5000);

  // Si la sección activa es 'emprestimos', obtenemos los empréstimos
  if (currentSection.value === 'emprestimos') {
    getEmprestimosAtivos();
  }
});



</script>



<style>
.highlight {
  border: 2px solid #FF5733;
  padding: 4px;
  border-radius: 8px;
}

.v-card {
  border-radius: 16px;
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
  /* Sombra más profunda */
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.v-card:hover {
  transform: translateY(-5px);
  /* Efecto de elevación al pasar el mouse */
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.3);
  /* Sombra al hacer hover */
}

.v-card-title {
  font-weight: bold;
  font-size: 1.2rem;
}

.v-card-subtitle {
  font-size: 1rem;
  color: #757575;
}

.v-card-text {
  font-size: 0.95rem;
  color: #424242;
}

.v-btn {
  border-radius: 8px;
  font-weight: bold;
  text-transform: uppercase;
}

.v-list-item--active {
  background-color: #1976D2;
  /* Color personalizado */
  color: white;
  /* Cambiar el color del texto */
}
</style>
