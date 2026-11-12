const express = require('express');
const router = express.Router();
const mensalidadeController = require('../controllers/mensalidadeController');
const authMiddleware = require('../middlewares/auth');

router.get('/', authMiddleware(), mensalidadeController.listarMensalidades);
router.get('/pendentes-view', authMiddleware(), mensalidadeController.listarViewPendentes);
router.get('/:id', authMiddleware(), mensalidadeController.obterMensalidade);

module.exports = router;
