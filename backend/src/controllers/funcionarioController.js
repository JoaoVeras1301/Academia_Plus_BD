const db = require('../config/db');

exports.listarFuncionarios = async (req, res) => {
    try {
        const [rows] = await db.execute(
            `SELECT id_funcionario, nome, cpf, telefone, email, cargo, data_contratacao, ativo
             FROM funcionarios
             ORDER BY id_funcionario DESC`
        );
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar funcionários:', error.message);
        return res.status(500).json({ error: 'Erro ao listar funcionários.' });
    }
};

exports.obterFuncionario = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute(
            `SELECT id_funcionario, nome, cpf, telefone, email, cargo, data_contratacao, ativo
             FROM funcionarios 
             WHERE id_funcionario = ?`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Funcionário não encontrado.' });
        }

        return res.json(rows[0]);
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar funcionário.' });
    }
};

exports.cadastrarFuncionario = async (req, res) => {
    const { nome, cpf, telefone, email, cargo, data_contratacao } = req.body;

    if (!nome || !cpf || !cargo || !data_contratacao) {
        return res.status(400).json({ error: 'Nome, CPF, cargo e data de contratação são obrigatórios.' });
    }

    try {
        const [existente] = await db.execute('SELECT id_funcionario FROM funcionarios WHERE cpf = ?', [cpf.trim()]);
        if (existente.length > 0) {
            return res.status(400).json({ error: 'Já existe um funcionário cadastrado com este CPF.' });
        }

        const [result] = await db.execute(
            `INSERT INTO funcionarios (nome, cpf, telefone, email, cargo, data_contratacao, ativo)
             VALUES (?, ?, ?, ?, ?, ?, TRUE)`,
            [
                nome.trim(),
                cpf.trim(),
                telefone ? telefone.trim() : null,
                email ? email.trim().toLowerCase() : null,
                cargo.trim(),
                data_contratacao
            ]
        );

        return res.status(201).json({
            message: 'Funcionário cadastrado com sucesso!',
            id_funcionario: result.insertId
        });
    } catch (error) {
        console.error('Erro ao cadastrar funcionário:', error.message);
        return res.status(500).json({ error: 'Erro interno ao cadastrar funcionário.' });
    }
};

exports.editarFuncionario = async (req, res) => {
    const { id } = req.params;
    const { nome, cpf, telefone, email, cargo, data_contratacao, ativo } = req.body;

    if (!nome || !cpf || !cargo || !data_contratacao) {
        return res.status(400).json({ error: 'Nome, CPF, cargo e data de contratação são obrigatórios.' });
    }

    try {
        const [existente] = await db.execute(
            'SELECT id_funcionario FROM funcionarios WHERE cpf = ? AND id_funcionario <> ?', 
            [cpf.trim(), id]
        );
        if (existente.length > 0) {
            return res.status(400).json({ error: 'Outro funcionário já possui este CPF cadastrado.' });
        }

        await db.execute(
            `UPDATE funcionarios 
             SET nome = ?, cpf = ?, telefone = ?, email = ?, 
                 cargo = ?, data_contratacao = ?, ativo = ?
             WHERE id_funcionario = ?`,
            [
                nome.trim(),
                cpf.trim(),
                telefone ? telefone.trim() : null,
                email ? email.trim().toLowerCase() : null,
                cargo.trim(),
                data_contratacao,
                ativo !== undefined ? ativo : true,
                id
            ]
        );

        return res.json({ message: 'Funcionário atualizado com sucesso.' });
    } catch (error) {
        console.error('Erro ao editar funcionário:', error.message);
        return res.status(500).json({ error: 'Erro ao editar funcionário.' });
    }
};

exports.alternarStatusFuncionario = async (req, res) => {
    const { id } = req.params;
    try {
        const [atual] = await db.execute('SELECT ativo FROM funcionarios WHERE id_funcionario = ?', [id]);
        if (atual.length === 0) {
            return res.status(404).json({ error: 'Funcionário não encontrado.' });
        }

        const novoStatus = !atual[0].ativo;
        await db.execute('UPDATE funcionarios SET ativo = ? WHERE id_funcionario = ?', [novoStatus, id]);

        return res.json({ 
            message: `Funcionário ${novoStatus ? 'ativado' : 'desativado'} com sucesso.`,
            ativo: novoStatus 
        });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao alterar status do funcionário.' });
    }
};
