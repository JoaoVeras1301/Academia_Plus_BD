const db = require('../config/db');

exports.listarAlunos = async (req, res) => {
    try {
        const { busca, ativo } = req.query;
        let sql = `
            SELECT a.id_aluno, a.codigo_aluno, a.nome, a.cpf, a.telefone, 
                   a.email, a.data_nascimento, a.endereco, a.data_cadastro, a.ativo,
                   (SELECT COUNT(*) FROM matriculas m WHERE m.id_aluno = a.id_aluno AND m.status = 'ATIVA') AS matriculas_ativas
            FROM alunos a
            WHERE 1=1
        `;
        const params = [];

        if (busca && busca.trim()) {
            sql += ` AND (a.nome LIKE ? OR a.cpf LIKE ? OR a.codigo_aluno LIKE ?)`;
            const termo = `%${busca.trim()}%`;
            params.push(termo, termo, termo);
        }

        if (ativo !== undefined && ativo !== '') {
            sql += ` AND a.ativo = ?`;
            params.push(ativo === 'true' || ativo === '1');
        }

        sql += ` ORDER BY a.id_aluno DESC`;

        const [rows] = await db.execute(sql, params);
        return res.json(rows);
    } catch (error) {
        console.error('Erro ao listar alunos:', error.message);
        return res.status(500).json({ error: 'Erro ao listar alunos.' });
    }
};

exports.obterAluno = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute(
            `SELECT id_aluno, codigo_aluno, nome, cpf, telefone, email, 
                    data_nascimento, endereco, data_cadastro, ativo
             FROM alunos 
             WHERE id_aluno = ?`,
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ error: 'Aluno não encontrado.' });
        }

        // Histórico de matrículas do aluno
        const [matriculas] = await db.execute(
            `SELECT m.id_matricula, m.codigo_matricula, p.nome AS plano_nome, 
                    m.data_inicio, m.data_fim, m.valor_contratado, m.status
             FROM matriculas m
             JOIN planos p ON m.id_plano = p.id_plano
             WHERE m.id_aluno = ?
             ORDER BY m.id_matricula DESC`,
            [id]
        );

        return res.json({ ...rows[0], matriculas });
    } catch (error) {
        console.error('Erro ao buscar aluno:', error.message);
        return res.status(500).json({ error: 'Erro ao buscar aluno.' });
    }
};

exports.cadastrarAluno = async (req, res) => {
    const { nome, cpf, telefone, email, data_nascimento, endereco } = req.body;

    if (!nome || !cpf) {
        return res.status(400).json({ error: 'Nome e CPF são campos obrigatórios.' });
    }

    try {
        // Validação de duplicidade de CPF
        const [existente] = await db.execute('SELECT id_aluno FROM alunos WHERE cpf = ?', [cpf.trim()]);
        if (existente.length > 0) {
            return res.status(400).json({ error: 'Já existe um aluno cadastrado com este CPF.' });
        }

        // Inserção - a trigger trg_aluno_codigo_before_insert gera o código de negócio se omitido!
        const [result] = await db.execute(
            `INSERT INTO alunos (nome, cpf, telefone, email, data_nascimento, endereco, ativo)
             VALUES (?, ?, ?, ?, ?, ?, TRUE)`,
            [
                nome.trim(),
                cpf.trim(),
                telefone ? telefone.trim() : null,
                email ? email.trim() : null,
                data_nascimento || null,
                endereco ? endereco.trim() : null
            ]
        );

        const novoId = result.insertId;
        const [novoAluno] = await db.execute('SELECT * FROM alunos WHERE id_aluno = ?', [novoId]);

        return res.status(201).json({
            message: 'Aluno cadastrado com sucesso!',
            aluno: novoAluno[0]
        });
    } catch (error) {
        console.error('Erro ao cadastrar aluno:', error.message);
        return res.status(500).json({ error: 'Erro interno ao cadastrar aluno.' });
    }
};

exports.editarAluno = async (req, res) => {
    const { id } = req.params;
    const { nome, cpf, telefone, email, data_nascimento, endereco, ativo } = req.body;

    if (!nome || !cpf) {
        return res.status(400).json({ error: 'Nome e CPF são campos obrigatórios.' });
    }

    try {
        const [existente] = await db.execute('SELECT id_aluno FROM alunos WHERE cpf = ? AND id_aluno <> ?', [cpf.trim(), id]);
        if (existente.length > 0) {
            return res.status(400).json({ error: 'Outro aluno já possui este CPF cadastrado.' });
        }

        await db.execute(
            `UPDATE alunos 
             SET nome = ?, cpf = ?, telefone = ?, email = ?, 
                 data_nascimento = ?, endereco = ?, ativo = ?
             WHERE id_aluno = ?`,
            [
                nome.trim(),
                cpf.trim(),
                telefone ? telefone.trim() : null,
                email ? email.trim() : null,
                data_nascimento || null,
                endereco ? endereco.trim() : null,
                ativo !== undefined ? ativo : true,
                id
            ]
        );

        return res.json({ message: 'Dados do aluno atualizados com sucesso.' });
    } catch (error) {
        console.error('Erro ao editar aluno:', error.message);
        return res.status(500).json({ error: 'Erro ao editar dados do aluno.' });
    }
};

exports.alternarStatusAluno = async (req, res) => {
    const { id } = req.params;
    try {
        const [atual] = await db.execute('SELECT ativo FROM alunos WHERE id_aluno = ?', [id]);
        if (atual.length === 0) {
            return res.status(404).json({ error: 'Aluno não encontrado.' });
        }

        const novoStatus = !atual[0].ativo;
        await db.execute('UPDATE alunos SET ativo = ? WHERE id_aluno = ?', [novoStatus, id]);

        return res.json({ 
            message: `Aluno ${novoStatus ? 'ativado' : 'desativado'} com sucesso.`,
            ativo: novoStatus 
        });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao alterar status do aluno.' });
    }
};
