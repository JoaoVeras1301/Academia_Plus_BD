const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const authMiddleware = require('../middlewares/auth');

// Todas as rotas de usuários exigem permissão de ADMINISTRADOR
router.use(authMiddleware(['ADMINISTRADOR']));

router.get('/', usuarioController.listarUsuarios);
router.get('/grupos', usuarioController.listarGrupos);
router.post('/', usuarioController.cadastrarUsuario);
router.put('/:id', usuarioController.editarUsuario);
router.patch('/:id/status', usuarioController.alternarStatusUsuario);

module.exports = router;
