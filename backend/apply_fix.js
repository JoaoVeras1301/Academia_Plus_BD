const db = require('./src/config/db');

async function applyFix() {
    console.log('[1/4] Atualizando fn_gerar_id_aluno...');
    try {
        await db.query('DROP FUNCTION IF EXISTS `fn_gerar_id_aluno`');
        await db.query(`
            CREATE FUNCTION \`fn_gerar_id_aluno\`() 
            RETURNS VARCHAR(36)
            NOT DETERMINISTIC
            NO SQL
            BEGIN
                DECLARE v_prefixo VARCHAR(20);
                DECLARE v_sufixo VARCHAR(10);
                
                SET v_prefixo = DATE_FORMAT(NOW(), 'ALU-%Y%m-');
                SET v_sufixo = UPPER(SUBSTRING(MD5(UUID()), 1, 6));
                
                RETURN CONCAT(v_prefixo, v_sufixo);
            END
        `);
        console.log('      fn_gerar_id_aluno atualizada com sucesso!');
    } catch (err) {
        console.error('      Erro ao atualizar fn_gerar_id_aluno:', err.message);
    }

    console.log('[2/4] Atualizando fn_gerar_id_matricula...');
    try {
        await db.query('DROP FUNCTION IF EXISTS `fn_gerar_id_matricula`');
        await db.query(`
            CREATE FUNCTION \`fn_gerar_id_matricula\`() 
            RETURNS VARCHAR(36)
            NOT DETERMINISTIC
            NO SQL
            BEGIN
                DECLARE v_prefixo VARCHAR(20);
                DECLARE v_sufixo VARCHAR(10);
                
                SET v_prefixo = DATE_FORMAT(NOW(), 'MAT-%Y%m-');
                SET v_sufixo = UPPER(SUBSTRING(MD5(UUID()), 1, 6));
                
                RETURN CONCAT(v_prefixo, v_sufixo);
            END
        `);
        console.log('      fn_gerar_id_matricula atualizada com sucesso!');
    } catch (err) {
        console.error('      Erro ao atualizar fn_gerar_id_matricula:', err.message);
    }

    console.log('[3/4] Testando chamada das duas functions...');
    try {
        const [resAluno] = await db.query('SELECT fn_gerar_id_aluno() AS cod_aluno');
        const [resMat] = await db.query('SELECT fn_gerar_id_matricula() AS cod_matricula');
        console.log('      fn_gerar_id_aluno() ->', resAluno[0].cod_aluno);
        console.log('      fn_gerar_id_matricula() ->', resMat[0].cod_matricula);
    } catch (err) {
        console.error('      Erro no teste das functions:', err.message);
    }

    console.log('[4/4] Concluído!');
    process.exit(0);
}

applyFix();
