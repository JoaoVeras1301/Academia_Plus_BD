const db = require('../config/db');

exports.listarPlanos = async (req, res) => {
    try {
        const { ativo } = req.query;
        let sql = 'SELECT id_plano, nome, descricao, duracao_meses, valor, ativo FROM planos WHERE 1=1';
        const params = [];

        if (ativo !== undefined && ativo !== '') {
            sql += ' AND ativo = ?';
            params.push(ativo === 'true' || ativo === '1');
        }

        sql += ' ORDER BY duracao_meses ASC';

        const [rows] = await db.execute(sql, params);
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar planos:', error.message);
        return res.status(500).json({ error: 'Erro ao listar planos.' });
    }
};

exports.obterPlano = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute(
            'SELECT id_plano, nome, descricao, duracao_meses, valor, ativo FROM planos WHERE id_plano = ?',
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Plano não encontrado.' });
        }

        return res.json(rows[0]);
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar plano.' });
    }
};

exports.cadastrarPlano = async (req, res) => {
    const { nome, descricao, duracao_meses, valor } = req.body;

    if (!nome || !duracao_meses || !valor) {
        return res.status(400).json({ error: 'Nome, duração em meses e valor são obrigatórios.' });
    }

    if (parseInt(duracao_meses) <= 0 || parseFloat(valor) <= 0) {
        return res.status(400).json({ error: 'Duração e valor devem ser números positivos.' });
    }

    try {
        const [result] = await db.execute(
            `INSERT INTO planos (nome, descricao, duracao_meses, valor, ativo)
             VALUES (?, ?, ?, ?, TRUE)`,
            [
                nome.trim(),
                descricao ? descricao.trim() : null,
                parseInt(duracao_meses),
                parseFloat(valor)
            ]
        );

        return res.status(201).json({
            message: 'Plano cadastrado com sucesso!',
            id_plano: result.insertId
        });
    } catch (error) {
        console.error('Erro ao cadastrar plano:', error.message);
        return res.status(500).json({ error: 'Erro ao cadastrar plano.' });
    }
};

exports.editarPlano = async (req, res) => {
    const { id } = req.params;
    const { nome, descricao, duracao_meses, valor, ativo } = req.body;

    if (!nome || !duracao_meses || !valor) {
        return res.status(400).json({ error: 'Nome, duração e valor são obrigatórios.' });
    }

    try {
        await db.execute(
            `UPDATE planos 
             SET nome = ?, descricao = ?, duracao_meses = ?, valor = ?, ativo = ?
             WHERE id_plano = ?`,
            [
                nome.trim(),
                descricao ? descricao.trim() : null,
                parseInt(duracao_meses),
                parseFloat(valor),
                ativo !== undefined ? ativo : true,
                id
            ]
        );

        return res.json({ message: 'Plano atualizado com sucesso.' });
    } catch (error) {
        console.error('Erro ao editar plano:', error.message);
        return res.status(500).json({ error: 'Erro ao editar plano.' });
    }
};

exports.alternarStatusPlano = async (req, res) => {
    const { id } = req.params;
    try {
        const [atual] = await db.execute('SELECT ativo FROM planos WHERE id_plano = ?', [id]);
        if (atual.length === 0) {
            return res.status(404).json({ error: 'Plano não encontrado.' });
        }

        const novoStatus = !atual[0].ativo;
        await db.execute('UPDATE planos SET ativo = ? WHERE id_plano = ?', [novoStatus, id]);

        return res.json({ 
            message: `Plano ${novoStatus ? 'ativado' : 'desativado'} com sucesso.`,
            ativo: novoStatus 
        });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao alterar status do plano.' });
    }
};
