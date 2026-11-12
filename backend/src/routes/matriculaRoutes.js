const express = require('express');
const router = express.Router();
const matriculaController = require('../controllers/matriculaController');
const authMiddleware = require('../middlewares/auth');

router.get('/', authMiddleware(), matriculaController.listarMatriculas);
router.get('/:id', authMiddleware(), matriculaController.obterMatricula);
router.post('/', authMiddleware(), matriculaController.realizarMatricula);
router.patch('/:id/cancelar', authMiddleware(['ADMINISTRADOR']), matriculaController.cancelarMatricula);

module.exports = router;
