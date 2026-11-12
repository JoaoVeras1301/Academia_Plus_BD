const db = require('../config/db');

exports.getDashboardData = async (req, res) => {
    try {
        const [alunos] = await db.execute('SELECT COUNT(*) AS total FROM alunos WHERE ativo = TRUE');
        const [funcionarios] = await db.execute('SELECT COUNT(*) AS total FROM funcionarios WHERE ativo = TRUE');
        const [matriculas] = await db.execute("SELECT COUNT(*) AS total FROM matriculas WHERE status = 'ATIVA'");
        
        // Mensalidades pendentes no prazo
        const [mensalidadesPendentes] = await db.execute(
            "SELECT COUNT(*) AS total FROM mensalidades WHERE status IN ('PENDENTE', 'PARCIAL') AND data_vencimento >= CURDATE()"
        );

        // Mensalidades atrasadas
        const [mensalidadesAtrasadas] = await db.execute(
            "SELECT COUNT(*) AS total FROM mensalidades WHERE status IN ('PENDENTE', 'PARCIAL') AND data_vencimento < CURDATE()"
        );

        // Total arrecadado no mês atual
        const [receita] = await db.execute(
            `SELECT COALESCE(SUM(valor), 0.00) AS total 
             FROM pagamentos 
             WHERE MONTH(data_pagamento) = MONTH(CURDATE()) 
               AND YEAR(data_pagamento) = YEAR(CURDATE())`
        );

        // Últimas matrículas para lista recente no dashboard
        const [ultimasMatriculas] = await db.execute(
            `SELECT m.id_matricula, m.codigo_matricula, a.nome AS aluno_nome, p.nome AS plano_nome, 
                    m.data_inicio, m.valor_contratado, m.status
             FROM matriculas m
             JOIN alunos a ON m.id_aluno = a.id_aluno
             JOIN planos p ON m.id_plano = p.id_plano
             ORDER BY m.id_matricula DESC
             LIMIT 5`
        );

        return res.json({
            alunos_ativos: alunos[0].total,
            funcionarios_ativos: funcionarios[0].total,
            matriculas_ativas: matriculas[0].total,
            mensalidades_pendentes: mensalidadesPendentes[0].total,
            mensalidades_atrasadas: mensalidadesAtrasadas[0].total,
            receita_mes: parseFloat(receita[0].total) || 0.00,
            ultimas_matriculas: ultimasMatriculas
        });
    } catch (error) {
        console.error('Erro no Dashboard:', error.message);
        return res.status(500).json({ error: 'Erro ao buscar dados do dashboard.' });
    }
};
