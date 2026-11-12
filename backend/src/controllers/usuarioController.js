const db = require('../config/db');
const bcrypt = require('bcrypt');

exports.listarUsuarios = async (req, res) => {
    try {
        const [rows] = await db.execute(
            `SELECT u.id_usuario, u.nome, u.email, u.id_grupo, u.id_funcionario, 
                    u.ativo, u.data_criacao,
                    g.nome AS grupo_nome,
                    f.nome AS funcionario_nome
             FROM usuarios u
             JOIN grupos_usuarios g ON u.id_grupo = g.id_grupo
             LEFT JOIN funcionarios f ON u.id_funcionario = f.id_funcionario
             ORDER BY u.id_usuario ASC`
        );
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar usuários:', error.message);
        return res.status(500).json({ error: 'Erro ao listar usuários.' });
    }
};

exports.listarGrupos = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT id_grupo, nome, descricao FROM grupos_usuarios ORDER BY id_grupo ASC');
        return res.json(rows);
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao listar grupos de usuários.' });
    }
};

exports.cadastrarUsuario = async (req, res) => {
    const { nome, email, senha, id_grupo, id_funcionario } = req.body;

    if (!nome || !email || !senha || !id_grupo) {
        return res.status(400).json({ error: 'Nome, e-mail, senha e grupo são obrigatórios.' });
    }

    if (senha.length < 6) {
        return res.status(400).json({ error: 'A senha deve conter no mínimo 6 caracteres.' });
    }

    try {
        const [existente] = await db.execute('SELECT id_usuario FROM usuarios WHERE email = ?', [email.trim().toLowerCase()]);
        if (existente.length > 0) {
            return res.status(400).json({ error: 'Já existe um usuário cadastrado com este e-mail.' });
        }

        const hash = await bcrypt.hash(senha, 10);

        const [result] = await db.execute(
            `INSERT INTO usuarios (nome, email, senha_hash, id_grupo, id_funcionario, ativo)
             VALUES (?, ?, ?, ?, ?, TRUE)`,
            [
                nome.trim(),
                email.trim().toLowerCase(),
                hash,
                id_grupo,
                id_funcionario || null
            ]
        );

        return res.status(201).json({
            message: 'Usuário cadastrado com sucesso!',
            id_usuario: result.insertId
        });
    } catch (error) {
        console.error('Erro ao cadastrar usuário:', error.message);
        return res.status(500).json({ error: 'Erro interno ao cadastrar usuário.' });
    }
};

exports.editarUsuario = async (req, res) => {
    const { id } = req.params;
    const { nome, email, senha, id_grupo, id_funcionario, ativo } = req.body;

    if (!nome || !email || !id_grupo) {
        return res.status(400).json({ error: 'Nome, e-mail e grupo são obrigatórios.' });
    }

    try {
        const [existente] = await db.execute(
            'SELECT id_usuario FROM usuarios WHERE email = ? AND id_usuario <> ?',
            [email.trim().toLowerCase(), id]
        );
        if (existente.length > 0) {
            return res.status(400).json({ error: 'Outro usuário já utiliza este e-mail.' });
        }

        if (senha && senha.trim()) {
            if (senha.length < 6) {
                return res.status(400).json({ error: 'A nova senha deve possuir pelo menos 6 caracteres.' });
            }
            const hash = await bcrypt.hash(senha, 10);
            await db.execute(
                `UPDATE usuarios 
                 SET nome = ?, email = ?, senha_hash = ?, id_grupo = ?, id_funcionario = ?, ativo = ?
                 WHERE id_usuario = ?`,
                [
                    nome.trim(),
                    email.trim().toLowerCase(),
                    hash,
                    id_grupo,
                    id_funcionario || null,
                    ativo !== undefined ? ativo : true,
                    id
                ]
            );
        } else {
            await db.execute(
                `UPDATE usuarios 
                 SET nome = ?, email = ?, id_grupo = ?, id_funcionario = ?, ativo = ?
                 WHERE id_usuario = ?`,
                [
                    nome.trim(),
                    email.trim().toLowerCase(),
                    id_grupo,
                    id_funcionario || null,
                    ativo !== undefined ? ativo : true,
                    id
                ]
            );
        }

        return res.json({ message: 'Usuário atualizado com sucesso.' });
    } catch (error) {
        console.error('Erro ao editar usuário:', error.message);
        return res.status(500).json({ error: 'Erro ao atualizar dados do usuário.' });
    }
};

exports.alternarStatusUsuario = async (req, res) => {
    const { id } = req.params;
    try {
        const [atual] = await db.execute('SELECT ativo FROM usuarios WHERE id_usuario = ?', [id]);
        if (atual.length === 0) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        const novoStatus = !atual[0].ativo;
        await db.execute('UPDATE usuarios SET ativo = ? WHERE id_usuario = ?', [novoStatus, id]);

        return res.json({ 
            message: `Usuário ${novoStatus ? 'ativado' : 'desativado'} com sucesso.`,
            ativo: novoStatus 
        });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao alterar status do usuário.' });
    }
};
