const db = require('../config/db');

exports.listarMatriculas = async (req, res) => {
    try {
        const { status, aluno } = req.query;
        let sql = `
            SELECT m.id_matricula, m.codigo_matricula, m.id_aluno, m.id_plano,
                   m.data_inicio, m.data_fim, m.valor_contratado, m.status, m.data_criacao,
                   a.nome AS aluno_nome, a.cpf AS aluno_cpf, a.codigo_aluno,
                   p.nome AS plano_nome, p.duracao_meses,
                   (SELECT COUNT(*) FROM mensalidades men WHERE men.id_matricula = m.id_matricula) AS total_parcelas,
                   (SELECT COUNT(*) FROM mensalidades men WHERE men.id_matricula = m.id_matricula AND men.status = 'PAGA') AS parcelas_pagas
            FROM matriculas m
            JOIN alunos a ON m.id_aluno = a.id_aluno
            JOIN planos p ON m.id_plano = p.id_plano
            WHERE 1=1
        `;
        const params = [];

        if (status) {
            sql += ' AND m.status = ?';
            params.push(status);
        }

        if (aluno) {
            sql += ' AND (a.nome LIKE ? OR a.cpf LIKE ?)';
            const t = `%${aluno}%`;
            params.push(t, t);
        }

        sql += ' ORDER BY m.id_matricula DESC';

        const [rows] = await db.execute(sql, params);
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar matrículas:', error.message);
        return res.status(500).json({ error: 'Erro ao listar matrículas.' });
    }
};

exports.obterMatricula = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute(
            `SELECT m.*, a.nome AS aluno_nome, a.cpf AS aluno_cpf, a.email AS aluno_email,
                    p.nome AS plano_nome, p.duracao_meses, p.valor AS plano_valor
             FROM matriculas m
             JOIN alunos a ON m.id_aluno = a.id_aluno
             JOIN planos p ON m.id_plano = p.id_plano
             WHERE m.id_matricula = ?`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Matrícula não encontrada.' });
        }

        const [mensalidades] = await db.execute(
            `SELECT id_mensalidade, numero_parcela, valor, data_vencimento, valor_pago, status,
                    (valor - valor_pago) AS saldo
             FROM mensalidades
             WHERE id_matricula = ?
             ORDER BY numero_parcela ASC`,
            [id]
        );

        return res.json({ ...rows[0], mensalidades });
    } catch (error) {
        console.error('Erro ao buscar matrícula:', error.message);
        return res.status(500).json({ error: 'Erro ao buscar dados da matrícula.' });
    }
};

exports.realizarMatricula = async (req, res) => {
    const { id_aluno, id_plano, data_inicio } = req.body;

    if (!id_aluno || !id_plano || !data_inicio) {
        return res.status(400).json({ error: 'Aluno, plano e data de início são obrigatórios.' });
    }

    try {
        // Chamada à Stored Procedure transacional sp_realizar_matricula
        // Recebe os parâmetros de saída via variáveis de sessão MySQL
        await db.query(
            'CALL sp_realizar_matricula(?, ?, ?, @p_id_matricula, @p_codigo_matricula)',
            [id_aluno, id_plano, data_inicio]
        );

        const [outResult] = await db.query(
            'SELECT @p_id_matricula AS id_matricula, @p_codigo_matricula AS codigo_matricula'
        );

        const idMatricula = outResult[0].id_matricula;
        const codMatricula = outResult[0].codigo_matricula;

        return res.status(201).json({
            message: 'Matrícula e mensalidades geradas com sucesso via Stored Procedure transacional!',
            id_matricula: idMatricula,
            codigo_matricula: codMatricula
        });
    } catch (error) {
        console.error('Erro ao realizar matrícula:', error.message);
        return res.status(400).json({ 
            error: error.sqlMessage || error.message || 'Falha ao processar matrícula no banco.' 
        });
    }
};

exports.cancelarMatricula = async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute("UPDATE matriculas SET status = 'CANCELADA' WHERE id_matricula = ?", [id]);
        await db.execute(
            "UPDATE mensalidades SET status = 'CANCELADA' WHERE id_matricula = ? AND status = 'PENDENTE' AND valor_pago = 0",
            [id]
        );

        return res.json({ message: 'Matrícula cancelada com sucesso.' });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao cancelar matrícula.' });
    }
};
