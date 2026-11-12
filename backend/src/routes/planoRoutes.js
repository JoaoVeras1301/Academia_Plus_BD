const express = require('express');
const router = express.Router();
const planoController = require('../controllers/planoController');
const authMiddleware = require('../middlewares/auth');

// Consulta de planos liberada para todos os operadores autenticados
router.get('/', authMiddleware(), planoController.listarPlanos);
router.get('/:id', authMiddleware(), planoController.obterPlano);

// Cadastros e alterações restritos a ADMINISTRADOR
router.post('/', authMiddleware(['ADMINISTRADOR']), planoController.cadastrarPlano);
router.put('/:id', authMiddleware(['ADMINISTRADOR']), planoController.editarPlano);
router.patch('/:id/status', authMiddleware(['ADMINISTRADOR']), planoController.alternarStatusPlano);

module.exports = router;
