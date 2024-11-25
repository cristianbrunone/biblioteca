<template>
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
            <v-list-item v-if="isSuperAdmin" @click="navigateTo('cadastroAdmins')">
                <v-list-item-title>Cadastro de Admins</v-list-item-title>
            </v-list-item>
            <v-list-item @click="openLogoutDialog">
                <v-list-item-title>Cerrar sesión</v-list-item-title>
            </v-list-item>
        </v-list>
    </v-navigation-drawer>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const props = defineProps({
    isSuperAdmin: Boolean,
    navigateTo: Function,
    logoutDialog: Boolean,
});

const emit = defineEmits(['updateLogoutDialog']);

function openLogoutDialog() {
    emit('updateLogoutDialog', true);
}
</script>
