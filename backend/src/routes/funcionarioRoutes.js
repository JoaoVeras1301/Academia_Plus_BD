const express = require('express');
const router = express.Router();
const funcionarioController = require('../controllers/funcionarioController');
const authMiddleware = require('../middlewares/auth');

// Rotas exclusivas para o perfil ADMINISTRADOR
router.get('/', authMiddleware(['ADMINISTRADOR']), funcionarioController.listarFuncionarios);
router.get('/:id', authMiddleware(['ADMINISTRADOR']), funcionarioController.obterFuncionario);
router.post('/', authMiddleware(['ADMINISTRADOR']), funcionarioController.cadastrarFuncionario);
router.put('/:id', authMiddleware(['ADMINISTRADOR']), funcionarioController.editarFuncionario);
router.patch('/:id/status', authMiddleware(['ADMINISTRADOR']), funcionarioController.alternarStatusFuncionario);

module.exports = router;
