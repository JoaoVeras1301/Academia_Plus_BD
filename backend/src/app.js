const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const alunoRoutes = require('./routes/alunoRoutes');
const funcionarioRoutes = require('./routes/funcionarioRoutes');
const planoRoutes = require('./routes/planoRoutes');
const matriculaRoutes = require('./routes/matriculaRoutes');
const mensalidadeRoutes = require('./routes/mensalidadeRoutes');
const pagamentoRoutes = require('./routes/pagamentoRoutes');
const usuarioRoutes = require('./routes/usuarioRoutes');
const demonstracaoRoutes = require('./routes/demonstracaoRoutes');

const app = express();

// Middlewares essenciais
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir frontend estático de forma integrada
const frontendPath = path.resolve(__dirname, '../../frontend');
app.use(express.static(frontendPath));

// Rotas da API REST
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        sistema: 'Academia+', 
        timestamp: new Date().toISOString() 
    });
});

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/alunos', alunoRoutes);
app.use('/api/funcionarios', funcionarioRoutes);
app.use('/api/planos', planoRoutes);
app.use('/api/matriculas', matriculaRoutes);
app.use('/api/mensalidades', mensalidadeRoutes);
app.use('/api/pagamentos', pagamentoRoutes);
app.use('/api/usuarios', usuarioRoutes);
app.use('/api/demonstracao', demonstracaoRoutes);

// Tratamento de rotas inexistentes na API
app.use('/api/*', (req, res) => {
    res.status(404).json({ error: 'Endpoint da API não encontrado.' });
});

// Middleware global de tratamento de erros
app.use((err, req, res, next) => {
    console.error('Erro não tratado na aplicação:', err.stack);
    res.status(500).json({ 
        error: 'Erro interno no servidor da aplicação.',
        detalhe: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

module.exports = app;
