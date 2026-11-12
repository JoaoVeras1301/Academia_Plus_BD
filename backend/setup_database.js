/**
 * ACADEMIA+ | INSTALADOR AUTOMÁTICO DO BANCO DE DADOS MYSQL
 * Executa o arquivo consolidado database/all_in_one_install.sql
 * utilizando o cliente oficial mysql.exe do MySQL Server 8.0.
 */

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');
const readline = require('readline');
const mysql = require('mysql2/promise');

function encontrarMysqlExe() {
    const caminhos = [
        'C:\\Program Files\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe',
        'C:\\Program Files (x86)\\MySQL\\MySQL Server 8.0\\bin\\mysql.exe',
        'C:\\xampp\\mysql\\bin\\mysql.exe',
        'mysql'
    ];

    for (const c of caminhos) {
        if (c === 'mysql' || fs.existsSync(c)) {
            return c;
        }
    }
    return 'mysql';
}

async function perguntarSenha() {
    return new Promise((resolve) => {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        rl.question('Digite a senha do usuario ROOT do seu MySQL: ', (senha) => {
            rl.close();
            resolve(senha.trim());
        });
    });
}

async function run() {
    console.log('====================================================');
    console.log(' Academia+ | Instalador do Banco de Dados MySQL 8');
    console.log('====================================================\n');

    let rootPassword = process.argv[2];
    if (rootPassword === undefined) {
        rootPassword = await perguntarSenha();
    }

    const sqlFile = path.resolve(__dirname, '../database/all_in_one_install.sql');
    if (!fs.existsSync(sqlFile)) {
        console.error('[ERRO] Arquivo não encontrado:', sqlFile);
        process.exit(1);
    }

    const mysqlExe = encontrarMysqlExe();
    console.log(`\n[1/3] Utilizando cliente MySQL: ${mysqlExe}`);
    console.log('[2/3] Executando all_in_one_install.sql com usuário ROOT...');

    const args = [
        '--user=root',
        `--password=${rootPassword}`,
        '--host=127.0.0.1',
        '--port=3306',
        '--default-character-set=utf8mb4'
    ];

    const result = spawnSync(mysqlExe, args, {
        input: fs.readFileSync(sqlFile),
        encoding: 'utf8',
        maxBuffer: 10 * 1024 * 1024
    });

    if (result.error || result.status !== 0) {
        console.error('\n[ERRO] Falha ao executar o script no MySQL:');
        console.error(result.stderr || result.stdout || result.error);
        console.log('\nPossíveis causas:');
        console.log('1. A senha digitada do ROOT do MySQL está incorreta.');
        console.log('2. O serviço do MySQL Server 8.0 não está iniciado no Windows.');
        console.log('\nAlternativa manual: Abra o MySQL Workbench, abra o arquivo:');
        console.log(`  ${sqlFile}`);
        console.log('E clique no ícone de Raio (Execute).');
        process.exit(1);
    }

    console.log('[3/3] Validando conexão com o usuário academia_app...');
    try {
        const conn = await mysql.createConnection({
            host: '127.0.0.1',
            port: 3306,
            user: 'academia_app',
            password: 'AcademiaApp#2026',
            database: 'academia_db'
        });

        const [users] = await conn.execute('SELECT COUNT(*) as total FROM usuarios');
        console.log(`      Conexão OK! Usuários cadastrados no banco: ${users[0].total}`);
        await conn.end();

        console.log('\n====================================================');
        console.log(' [SUCESSO TOTAL] BANCO ACADEMIA_DB PRONTO PARA USO!');
        console.log(' - Usuário de conexão: academia_app');
        console.log(' - 12 alunos e contratos de teste gerados');
        console.log('====================================================');
        console.log('\nVocê já pode fazer login na aplicação:');
        console.log('  E-mail: admin@academia.com.br');
        console.log('  Senha:  admin123\n');
    } catch (testErr) {
        console.error('\n[AVISO] O script foi executado, mas a conexão como academia_app retornou:');
        console.error(testErr.message);
    }
}

run();
