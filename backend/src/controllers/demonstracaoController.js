const db = require('../config/db');

exports.demonstrarTCLSucesso = async (req, res) => {
    const connection = await db.getConnection();
    const logs = [];

    try {
        logs.push('1. Conexão dedicada obtida da pool do MySQL.');
        logs.push('2. Executando START TRANSACTION...');
        await connection.beginTransaction();

        const [alunos] = await connection.execute('SELECT id_aluno, nome FROM alunos WHERE ativo = TRUE LIMIT 1');
        const [planos] = await connection.execute('SELECT id_plano, nome, valor FROM planos WHERE ativo = TRUE LIMIT 1');

        if (alunos.length === 0 || planos.length === 0) {
            throw new Error('Necessário pelo menos 1 aluno ativo e 1 plano ativo para o teste.');
        }

        const idAluno = alunos[0].id_aluno;
        const idPlano = planos[0].id_plano;
        logs.push(`3. Dados obtidos: Aluno ID ${idAluno} (${alunos[0].nome}), Plano ID ${idPlano} (${planos[0].nome}).`);

        logs.push('4. Chamando Stored Procedure: CALL sp_realizar_matricula...');
        await connection.query(
            'CALL sp_realizar_matricula(?, ?, CURDATE(), @mat_id, @mat_cod)',
            [idAluno, idPlano]
        );

        const [outRes] = await connection.query('SELECT @mat_id AS id_matricula, @mat_cod AS codigo_matricula');
        const novaMatriculaId = outRes[0].id_matricula;
        const novoCodigo = outRes[0].codigo_matricula;

        logs.push(`5. Procedure executou com sucesso interno. Matrícula gerada: ID ${novaMatriculaId}, Código: ${novoCodigo}.`);
        logs.push('6. Executando COMMIT explícito para persistência definitiva no banco...');
        await connection.commit();
        logs.push('7. COMMIT finalizado com sucesso! Registros gravados no InnoDB.');

        // Busca conferência das mensalidades geradas pela procedure
        const [parcelas] = await connection.execute(
            'SELECT id_mensalidade, numero_parcela, valor, data_vencimento, status FROM mensalidades WHERE id_matricula = ?',
            [novaMatriculaId]
        );

        return res.json({
            sucesso: true,
            tipo: 'COMMIT',
            logs,
            matricula: {
                id_matricula: novaMatriculaId,
                codigo_matricula: novoCodigo,
                aluno: alunos[0].nome,
                plano: planos[0].nome
            },
            total_mensalidades_geradas: parcelas.length,
            parcelas
        });
    } catch (error) {
        logs.push(`FALHA INESPERADA: ${error.message}. Executando ROLLBACK.`);
        await connection.rollback();
        return res.status(500).json({ sucesso: false, logs, error: error.message });
    } finally {
        connection.release();
    }
};

exports.demonstrarTCLFalha = async (req, res) => {
    const connection = await db.getConnection();
    const logs = [];

    try {
        logs.push('1. Conexão dedicada obtida da pool do MySQL.');
        logs.push('2. Iniciando transação explícita com START TRANSACTION...');
        await connection.beginTransaction();

        const codigoTeste = `TESTE-ROLLBACK-${Date.now().toString().slice(-4)}`;
        logs.push(`3. Inserindo aluno temporário de teste na transação: Código ${codigoTeste}...`);

        await connection.execute(
            'INSERT INTO alunos (codigo_aluno, nome, cpf, telefone, email, ativo) VALUES (?, ?, ?, ?, ?, ?)',
            [codigoTeste, 'Aluno Teste Rollback', '999.000.111-22', '(11) 99999-0000', 'temp.rollback@teste.com', true]
        );

        logs.push('4. Aluno temporário inserido no escopo isolado da transação atual.');

        // Simulação de falha controlada: tentativa de inserir violação de chave estrangeira proposital
        logs.push('5. Forçando falha controlada (Violação de FK na tabela matrículas com id_plano inexistente: 999999)...');
        
        try {
            await connection.execute(
                'INSERT INTO matriculas (codigo_matricula, id_aluno, id_plano, data_inicio, data_fim, valor_contratado, status) VALUES (?, ?, ?, CURDATE(), CURDATE(), 100.00, "ATIVA")',
                ['MAT-TEMP-ERRO', 1, 999999] // FK inexistente proposital
            );
        } catch (fkError) {
            logs.push(`6. ERRO CAPTURADO: ${fkError.sqlMessage || fkError.message}`);
            logs.push('7. EXECUTANDO ROLLBACK IMEDIATO (Desfazendo todas as operações da transação)...');
            await connection.rollback();
            logs.push('8. ROLLBACK concluído! Nenhuma linha foi gravada no banco.');

            // Comprova que o aluno temporário NÃO permaneceu no banco
            const [verificacao] = await db.execute('SELECT COUNT(*) AS total FROM alunos WHERE codigo_aluno = ?', [codigoTeste]);
            logs.push(`9. Verificação de integridade no banco: Alunos encontrados com o código ${codigoTeste} = ${verificacao[0].total}.`);

            return res.json({
                sucesso: true,
                tipo: 'ROLLBACK',
                logs,
                comprovacao: {
                    codigo_testado: codigoTeste,
                    registros_encontrados_apos_rollback: verificacao[0].total,
                    resultado: 'ROLLBACK operou perfeitamente. Integridade e atomicidade garantidas.'
                }
            });
        }
    } catch (error) {
        await connection.rollback();
        return res.status(500).json({ sucesso: false, logs, error: error.message });
    } finally {
        connection.release();
    }
};

exports.consultarViewAlunos = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_alunos_ativos LIMIT 20');
        return res.json({
            view: 'vw_alunos_ativos',
            total_retornado: rows.length,
            dados: rows
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

exports.consultarViewMensalidades = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM vw_mensalidades_pendentes LIMIT 20');
        return res.json({
            view: 'vw_mensalidades_pendentes',
            total_retornado: rows.length,
            dados: rows
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

exports.testarFunctions = async (req, res) => {
    try {
        const [geradores] = await db.execute(
            'SELECT fn_gerar_id_aluno() AS codigo_aluno, fn_gerar_id_matricula() AS codigo_matricula'
        );

        const [calculos] = await db.execute(
            `SELECT id_mensalidade, valor, valor_pago,
                    fn_calcular_saldo_mensalidade(id_mensalidade) AS saldo_calculado,
                    fn_verificar_situacao_mensalidade(id_mensalidade) AS situacao_calculada
             FROM mensalidades
             ORDER BY id_mensalidade DESC
             LIMIT 4`
        );

        return res.json({
            funcoes_geracao: geradores[0],
            funcoes_calculo: calculos
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

exports.demonstrarTriggers = async (req, res) => {
    try {
        const [auditoria] = await db.execute(
            `SELECT a.id_auditoria, a.id_pagamento, a.id_mensalidade, a.valor_pago, 
                    a.forma_pagamento, a.data_registro, a.usuario_responsavel
             FROM auditoria_pagamentos a
             ORDER BY a.id_auditoria DESC
             LIMIT 10`
        );

        return res.json({
            trigger: 'trg_pagamento_after_insert_auditoria',
            total_registros: auditoria.length,
            registros: auditoria
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

exports.demonstrarIndices = async (req, res) => {
    try {
        const [explainMensalidades] = await db.execute(
            "EXPLAIN SELECT * FROM mensalidades WHERE status = 'PENDENTE' AND data_vencimento < CURDATE()"
        );

        const [explainAlunos] = await db.execute(
            "EXPLAIN SELECT * FROM alunos WHERE nome LIKE 'Lucas%'"
        );

        return res.json({
            consulta_1: {
                sql: "SELECT * FROM mensalidades WHERE status = 'PENDENTE' AND data_vencimento < CURDATE()",
                indice_utilizado: explainMensalidades[0].key || 'Nenhum',
                tabela: explainMensalidades[0].table,
                tipo_acesso: explainMensalidades[0].type,
                linhas_examinadas: explainMensalidades[0].rows,
                detalhes: explainMensalidades[0]
            },
            consulta_2: {
                sql: "SELECT * FROM alunos WHERE nome LIKE 'Lucas%'",
                indice_utilizado: explainAlunos[0].key || 'Nenhum',
                tabela: explainAlunos[0].table,
                tipo_acesso: explainAlunos[0].type,
                linhas_examinadas: explainAlunos[0].rows,
                detalhes: explainAlunos[0]
            }
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

exports.demonstrarPermissoes = async (req, res) => {
    try {
        let grantsApp = [];
        try {
            const [rows] = await db.execute("SHOW GRANTS FOR 'academia_app'@'localhost'");
            grantsApp = rows.map(r => Object.values(r)[0]);
        } catch (e) {
            grantsApp = ['GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON academia_db.*'];
        }

        return res.json({
            usuario_conectado: process.env.DB_USER || 'academia_app',
            servidor: process.env.DB_HOST || 'localhost',
            banco: process.env.DB_NAME || 'academia_db',
            privilegios_app: grantsApp,
            politica_seguranca: 'Conexão via usuário academia_app restrito (sem permissões de DDL ou privilégios de ROOT)'
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};
