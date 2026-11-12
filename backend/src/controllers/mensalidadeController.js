const db = require('../config/db');

exports.listarMensalidades = async (req, res) => {
    try {
        const { status, aluno, vencimento_inicio, vencimento_fim } = req.query;
        let sql = `
            SELECT m.id_mensalidade, m.id_matricula, m.numero_parcela, m.valor, 
                   m.data_vencimento, m.valor_pago, m.status,
                   (m.valor - m.valor_pago) AS saldo,
                   a.id_aluno, a.nome AS aluno_nome, a.cpf AS aluno_cpf,
                   p.nome AS plano_nome, mat.codigo_matricula
            FROM mensalidades m
            JOIN matriculas mat ON m.id_matricula = mat.id_matricula
            JOIN alunos a ON mat.id_aluno = a.id_aluno
            JOIN planos p ON mat.id_plano = p.id_plano
            WHERE 1=1
        `;
        const params = [];

        if (status) {
            if (status === 'ATRASADA') {
                sql += " AND m.status IN ('PENDENTE', 'PARCIAL') AND m.data_vencimento < CURDATE()";
            } else if (status === 'PENDENTE_EM_DIA') {
                sql += " AND m.status = 'PENDENTE' AND m.data_vencimento >= CURDATE()";
            } else {
                sql += ' AND m.status = ?';
                params.push(status);
            }
        }

        if (aluno) {
            sql += ' AND (a.nome LIKE ? OR a.cpf LIKE ?)';
            const t = `%${aluno}%`;
            params.push(t, t);
        }

        if (vencimento_inicio) {
            sql += ' AND m.data_vencimento >= ?';
            params.push(vencimento_inicio);
        }

        if (vencimento_fim) {
            sql += ' AND m.data_vencimento <= ?';
            params.push(vencimento_fim);
        }

        sql += ' ORDER BY m.data_vencimento ASC, m.id_mensalidade DESC';

        const [rows] = await db.execute(sql, params);
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar mensalidades:', error.message);
        return res.status(500).json({ error: 'Erro ao listar mensalidades.' });
    }
};

// Endpoint que consulta DIRETAMENTE a View vw_mensalidades_pendentes do banco
exports.listarViewPendentes = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_mensalidades_pendentes ORDER BY data_vencimento ASC');
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao consultar View vw_mensalidades_pendentes:', error.message);
        return res.status(500).json({ error: 'Erro ao consultar View do banco.' });
    }
};

exports.obterMensalidade = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute(
            `SELECT m.*, (m.valor - m.valor_pago) AS saldo,
                    fn_calcular_saldo_mensalidade(m.id_mensalidade) AS saldo_function,
                    fn_verificar_situacao_mensalidade(m.id_mensalidade) AS situacao_function,
                    a.nome AS aluno_nome, a.cpf AS aluno_cpf, a.telefone AS aluno_telefone,
                    p.nome AS plano_nome, mat.codigo_matricula
             FROM mensalidades m
             JOIN matriculas mat ON m.id_matricula = mat.id_matricula
             JOIN alunos a ON mat.id_aluno = a.id_aluno
             JOIN planos p ON mat.id_plano = p.id_plano
             WHERE m.id_mensalidade = ?`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Mensalidade não encontrada.' });
        }

        // Histórico de pagamentos desta parcela
        const [pagamentos] = await db.execute(
            `SELECT id_pagamento, valor, data_pagamento, forma_pagamento, observacao
             FROM pagamentos
             WHERE id_mensalidade = ?
             ORDER BY id_pagamento DESC`,
            [id]
        );

        return res.json({ ...rows[0], pagamentos });
    } catch (error) {
        console.error('Erro ao buscar mensalidade:', error.message);
        return res.status(500).json({ error: 'Erro ao buscar dados da mensalidade.' });
    }
};
