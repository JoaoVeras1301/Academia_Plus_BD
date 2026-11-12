const express = require('express');
const router = express.Router();
const pagamentoController = require('../controllers/pagamentoController');
const authMiddleware = require('../middlewares/auth');

router.get('/', authMiddleware(), pagamentoController.listarPagamentos);
router.post('/', authMiddleware(), pagamentoController.registrarPagamento);

module.exports = router;
