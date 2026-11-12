/**
 * ACADEMIA+ | SCRIPT CENTRAL DE INTERFACE E INTEGRAÇÃO DE API
 */

const API_BASE_URL = window.location.origin.includes(':3000') 
    ? window.location.origin + '/api' 
    : 'http://localhost:3000/api';

// Recupera informações de sessão
function getSession() {
    const token = localStorage.getItem('token');
    const usuarioStr = localStorage.getItem('usuario');
    let usuario = null;
    try {
        usuario = usuarioStr ? JSON.parse(usuarioStr) : null;
    } catch (e) {
        usuario = null;
    }
    return { token, usuario };
}

// Verifica autenticação e redireciona se necessário
function checkAuth(requiredRoles = []) {
    const { token, usuario } = getSession();

    if (!token || !usuario) {
        // Redireciona para o login
        const isPagesDir = window.location.pathname.includes('/pages/');
        window.location.href = isPagesDir ? '../login.html' : 'login.html';
        return false;
    }

    // Validação de perfil/grupo
    if (requiredRoles.length > 0) {
        const userRole = (usuario.grupo || '').toUpperCase();
        const allowed = requiredRoles.map(r => r.toUpperCase()).includes(userRole);
        if (!allowed) {
            alert('Acesso negado: Seu perfil não possui permissão para acessar esta página.');
            const isPagesDir = window.location.pathname.includes('/pages/');
            window.location.href = isPagesDir ? '../index.html' : 'index.html';
            return false;
        }
    }

    return true;
}

// Inicializa a interface com os dados do usuário autenticado
function setupUI() {
    const { usuario } = getSession();
    if (!usuario) return;

    // Atualiza nome e papel do usuário
    const userNameEls = document.querySelectorAll('.user-name');
    const userRoleEls = document.querySelectorAll('.user-role');
    const userAvatarEls = document.querySelectorAll('.user-avatar');

    userNameEls.forEach(el => el.textContent = usuario.nome || 'Usuário');
    userRoleEls.forEach(el => el.textContent = usuario.grupo || 'Operador');
    userAvatarEls.forEach(el => {
        el.textContent = (usuario.nome || 'U').charAt(0).toUpperCase();
    });

    // Controle de acesso no frontend (oculta menus que o perfil não pode acessar)
    const adminOnlyEls = document.querySelectorAll('[data-role="ADMINISTRADOR"]');
    if ((usuario.grupo || '').toUpperCase() !== 'ADMINISTRADOR') {
        adminOnlyEls.forEach(el => el.style.display = 'none');
    }

    // Configura botões de logout
    const logoutBtns = document.querySelectorAll('.btn-logout');
    logoutBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            if (confirm('Deseja realmente encerrar a sessão?')) {
                localStorage.removeItem('token');
                localStorage.removeItem('usuario');
                const isPagesDir = window.location.pathname.includes('/pages/');
                window.location.href = isPagesDir ? '../login.html' : 'login.html';
            }
        });
    });
}

// Wrapper centralizado de chamadas HTTP à API REST
async function apiFetch(endpoint, options = {}) {
    const { token } = getSession();
    const url = endpoint.startsWith('http') ? endpoint : `${API_BASE_URL}${endpoint}`;

    const headers = {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        ...(options.headers || {})
    };

    try {
        const response = await fetch(url, { ...options, headers });
        
        if (response.status === 401) {
            localStorage.removeItem('token');
            localStorage.removeItem('usuario');
            alert('Sessão expirada. Faça login novamente.');
            const isPagesDir = window.location.pathname.includes('/pages/');
            window.location.href = isPagesDir ? '../login.html' : 'login.html';
            return null;
        }

        const data = await response.json();
        if (!response.ok) {
            throw new Error(data.error || 'Erro na requisição ao servidor');
        }

        return data;
    } catch (error) {
        console.error(`Erro na chamada API (${endpoint}):`, error);
        throw error;
    }
}

// Máscaras de formulário
function formatCPF(val) {
    return val.replace(/\D/g, '')
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d{1,2})$/, '$1-$2')
        .slice(0, 14);
}

function formatTelefone(val) {
    return val.replace(/\D/g, '')
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{5})(\d{4})$/, '$1-$2')
        .slice(0, 15);
}

function formatMoeda(valor) {
    const num = parseFloat(valor) || 0;
    return num.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}

function formatData(dataISO) {
    if (!dataISO) return '-';
    const d = new Date(dataISO);
    return isNaN(d.getTime()) ? dataISO : d.toLocaleDateString('pt-BR');
}

// Execução ao carregar o DOM
document.addEventListener('DOMContentLoaded', () => {
    // Se não estiver na página de login, valida sessão
    if (!window.location.pathname.endsWith('login.html')) {
        if (checkAuth()) {
            setupUI();
        }
    }
});
