const express = require('express');
const router = express.Router();
const alunoController = require('../controllers/alunoController');
const authMiddleware = require('../middlewares/auth');

// Rotas liberadas para ADMINISTRADOR e FUNCIONARIO
router.get('/', authMiddleware(), alunoController.listarAlunos);
router.get('/:id', authMiddleware(), alunoController.obterAluno);
router.post('/', authMiddleware(), alunoController.cadastrarAluno);
router.put('/:id', authMiddleware(), alunoController.editarAluno);
router.patch('/:id/status', authMiddleware(), alunoController.alternarStatusAluno);

module.exports = router;
