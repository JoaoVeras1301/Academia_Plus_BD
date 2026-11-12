const db = require('../config/db');

exports.listarPagamentos = async (req, res) => {
    try {
        const [rows] = await db.execute(
            `SELECT p.id_pagamento, p.id_mensalidade, p.valor, p.data_pagamento, 
                    p.forma_pagamento, p.observacao,
                    m.numero_parcela, m.valor AS valor_mensalidade,
                    a.id_aluno, a.nome AS aluno_nome, a.cpf AS aluno_cpf,
                    pl.nome AS plano_nome, mat.codigo_matricula
             FROM pagamentos p
             JOIN mensalidades m ON p.id_mensalidade = m.id_mensalidade
             JOIN matriculas mat ON m.id_matricula = mat.id_matricula
             JOIN alunos a ON mat.id_aluno = a.id_aluno
             JOIN planos pl ON mat.id_plano = pl.id_plano
             ORDER BY p.id_pagamento DESC
             LIMIT 100`
        );
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar pagamentos:', error.message);
        return res.status(500).json({ error: 'Erro ao listar histórico de pagamentos.' });
    }
};

exports.registrarPagamento = async (req, res) => {
    const { id_mensalidade, valor, forma_pagamento, observacao } = req.body;

    if (!id_mensalidade || !valor || !forma_pagamento) {
        return res.status(400).json({ error: 'Mensalidade, valor e forma de pagamento são obrigatórios.' });
    }

    const valorNum = parseFloat(valor);
    if (isNaN(valorNum) || valorNum <= 0) {
        return res.status(400).json({ error: 'O valor do pagamento deve ser um número positivo.' });
    }

    try {
        // Chamada à Stored Procedure transacional sp_registrar_pagamento
        await db.query(
            'CALL sp_registrar_pagamento(?, ?, ?, ?, @p_id_pagamento)',
            [id_mensalidade, valorNum, forma_pagamento, observacao || null]
        );

        const [outResult] = await db.query('SELECT @p_id_pagamento AS id_pagamento');
        const idPagamento = outResult[0].id_pagamento;

        // Busca o estado atualizado da mensalidade pós-trigger
        const [mensalidadeAtualizada] = await db.execute(
            `SELECT m.id_mensalidade, m.valor, m.valor_pago, m.status, 
                    (m.valor - m.valor_pago) AS saldo
             FROM mensalidades m 
             WHERE m.id_mensalidade = ?`,
            [id_mensalidade]
        );

        return res.status(201).json({
            message: 'Pagamento processado com sucesso via Stored Procedure e atualizado por Trigger!',
            id_pagamento: idPagamento,
            mensalidade: mensalidadeAtualizada[0]
        });
    } catch (error) {
        console.error('Erro ao registrar pagamento:', error.message);
        return res.status(400).json({ 
            error: error.sqlMessage || error.message || 'Falha ao registrar pagamento no banco.' 
        });
    }
};
