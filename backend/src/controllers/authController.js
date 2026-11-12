const db = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
    const { email, senha } = req.body;

    if (!email || !senha) {
        return res.status(400).json({ error: 'Informe e-mail e senha.' });
    }

    try {
        const [rows] = await db.execute(
            `SELECT u.id_usuario, u.nome, u.email, u.senha_hash, u.ativo, 
                    g.id_grupo, g.nome AS grupo
             FROM usuarios u
             JOIN grupos_usuarios g ON u.id_grupo = g.id_grupo
             WHERE u.email = ?`,
            [email.trim().toLowerCase()]
        );

        if (rows.length === 0) {
            return res.status(401).json({ error: 'Credenciais inválidas.' });
        }

        const usuario = rows[0];

        if (!usuario.ativo) {
            return res.status(403).json({ error: 'Usuário desativado. Entre em contato com a administração.' });
        }

        const senhaValida = await bcrypt.compare(senha, usuario.senha_hash);
        if (!senhaValida) {
            return res.status(401).json({ error: 'Credenciais inválidas.' });
        }

        const secret = process.env.JWT_SECRET || 'chave_secreta_padrao_academia_plus_2026';
        const payload = {
            id_usuario: usuario.id_usuario,
            nome: usuario.nome,
            email: usuario.email,
            id_grupo: usuario.id_grupo,
            grupo: usuario.grupo
        };

        const token = jwt.sign(payload, secret, { expiresIn: '8h' });

        return res.json({
            message: 'Autenticação realizada com sucesso.',
            token,
            usuario: {
                id_usuario: usuario.id_usuario,
                nome: usuario.nome,
                email: usuario.email,
                grupo: usuario.grupo
            }
        });
    } catch (error) {
        console.error('Erro no login:', error.message);
        let msg = 'Erro interno ao processar autenticação.';
        if (error.code === 'ECONNREFUSED') {
            msg = 'Não foi possível conectar ao MySQL na porta 3306. Verifique se o MySQL Server está iniciado.';
        } else if (error.code === 'ER_ACCESS_DENIED_ERROR') {
            msg = `Acesso negado no MySQL para '${process.env.DB_USER || 'academia_app'}'. O banco ou o usuário ainda não foram criados no MySQL. Execute os scripts da pasta database/ no MySQL Workbench ou execute o script setup_database.js.`;
        } else if (error.code === 'ER_BAD_DB_ERROR') {
            msg = `Banco de dados '${process.env.DB_NAME}' não existe. Execute o script database/01_database.sql no MySQL.`;
        } else if (error.code === 'ER_NO_SUCH_TABLE') {
            msg = 'Tabelas do sistema não encontradas. Execute database/02_tables.sql e database/09_seed.sql no MySQL.';
        } else if (error.message) {
            msg = `Erro de conexão com MySQL: ${error.message}`;
        }
        return res.status(500).json({ error: msg });
    }
};

exports.me = async (req, res) => {
    try {
        const [rows] = await db.execute(
            `SELECT u.id_usuario, u.nome, u.email, g.nome AS grupo
             FROM usuarios u
             JOIN grupos_usuarios g ON u.id_grupo = g.id_grupo
             WHERE u.id_usuario = ?`,
            [req.user.id_usuario]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        return res.json(rows[0]);
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar perfil do usuário.' });
    }
};
