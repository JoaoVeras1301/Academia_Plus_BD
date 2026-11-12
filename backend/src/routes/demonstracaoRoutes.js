const express = require('express');
const router = express.Router();
const demonstracaoController = require('../controllers/demonstracaoController');
const authMiddleware = require('../middlewares/auth');

// Acesso restrito a administradores e avaliadores acadêmicos
router.use(authMiddleware(['ADMINISTRADOR']));

// Transações TCL (COMMIT / ROLLBACK)
router.post('/tcl/sucesso', demonstracaoController.demonstrarTCLSucesso);
router.post('/tcl/falha', demonstracaoController.demonstrarTCLFalha);

// Consulta às Views
router.get('/views/alunos-ativos', demonstracaoController.consultarViewAlunos);
router.get('/views/mensalidades-pendentes', demonstracaoController.consultarViewMensalidades);

// Execução de Functions
router.get('/functions/teste', demonstracaoController.testarFunctions);

// Comprovação de Triggers
router.get('/triggers/auditoria', demonstracaoController.demonstrarTriggers);

// Uso de Índices com EXPLAIN
router.get('/indices', demonstracaoController.demonstrarIndices);

// Verificação de Usuários e Permissões do SGBD
router.get('/permissoes', demonstracaoController.demonstrarPermissoes);

module.exports = router;
