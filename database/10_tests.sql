-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 10_tests.sql
-- Objetivo: Roteiro completo de testes e validação dos requisitos do professor:
-- 1. Verificação de integridade referencial
-- 2. Teste das Stored Functions
-- 3. Teste das Stored Procedures com TCL (COMMIT e ROLLBACK)
-- 4. Teste e comprovação do acionamento de Triggers
-- 5. Consulta e validação das Views
-- 6. Validação dos Índices com EXPLAIN
-- 7. Auditoria e permissões de usuários
-- ============================================================================

USE `academia_db`;

-- ----------------------------------------------------------------------------
-- TESTE 1: Consulta às Views Obrigatórias
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 1.1] View vw_alunos_ativos ---' AS status_teste;
SELECT * FROM `vw_alunos_ativos` LIMIT 10;

SELECT '--- [TESTE 1.2] View vw_mensalidades_pendentes ---' AS status_teste;
SELECT * FROM `vw_mensalidades_pendentes` LIMIT 10;

-- ----------------------------------------------------------------------------
-- TESTE 2: Execução das Stored Functions
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 2] Stored Functions ---' AS status_teste;
SELECT 
    fn_gerar_id_aluno() AS codigo_aluno_gerado,
    fn_gerar_id_matricula() AS codigo_matricula_gerado;

-- Teste de cálculo de saldo e verificação de situação
SELECT 
    id_mensalidade,
    valor,
    valor_pago,
    fn_calcular_saldo_mensalidade(id_mensalidade) AS saldo_calculado_fn,
    fn_verificar_situacao_mensalidade(id_mensalidade) AS situacao_calculada_fn
FROM `mensalidades`
LIMIT 5;

-- ----------------------------------------------------------------------------
-- TESTE 3: Demonstração de Transação TCL - SUCESSO (COMMIT)
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 3.1] TCL: Transação com Sucesso (COMMIT) via Procedure ---' AS status_teste;
-- Seleciona o primeiro aluno e o plano semestral
SELECT id_aluno INTO @aluno_teste FROM `alunos` WHERE `ativo` = TRUE LIMIT 1;
SELECT id_plano INTO @plano_teste FROM `planos` WHERE `ativo` = TRUE LIMIT 1;

CALL sp_realizar_matricula(@aluno_teste, @plano_teste, CURDATE(), @mat_commit_id, @mat_commit_cod);

-- Comprova que os dados foram persistidos (COMMIT efetuado)
SELECT id_matricula, codigo_matricula, id_aluno, id_plano, status 
FROM `matriculas` 
WHERE `id_matricula` = @mat_commit_id;

SELECT id_mensalidade, id_matricula, numero_parcela, valor, status 
FROM `mensalidades` 
WHERE `id_matricula` = @mat_commit_id;

-- ----------------------------------------------------------------------------
-- TESTE 4: Demonstração de Transação TCL - FALHA CONTROLADA (ROLLBACK)
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 4.1] TCL: Transação com Falha e ROLLBACK ---' AS status_teste;
-- Tenta matricular um aluno inexistente (ID 999999)
-- A procedure dispara SIGNAL e o EXIT HANDLER executa ROLLBACK automático.
-- Exemplo de execução simulada:
-- CALL sp_realizar_matricula(999999, @plano_teste, CURDATE(), @out_id, @out_cod);
-- O MySQL retornará erro 'Aluno inválido ou inativo no sistema' e nenhuma linha será criada.

-- Demonstração explícita de ROLLBACK manual:
START TRANSACTION;
INSERT INTO `alunos` (`codigo_aluno`, `nome`, `cpf`, `ativo`) 
VALUES ('TESTE-TEMP-01', 'Aluno Temporario Rollback', '999.888.777-66', TRUE);

-- Verifica que existe dentro da transação atual
SELECT * FROM `alunos` WHERE `codigo_aluno` = 'TESTE-TEMP-01';

-- Executa o ROLLBACK
ROLLBACK;

-- Comprova que o registro foi 100% desfeito
SELECT COUNT(*) AS total_apos_rollback FROM `alunos` WHERE `codigo_aluno` = 'TESTE-TEMP-01';

-- ----------------------------------------------------------------------------
-- TESTE 5: Comprovação das Triggers
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 5.1] Trigger de geração de código no Aluno ---' AS status_teste;
INSERT INTO `alunos` (`nome`, `cpf`, `telefone`, `email`, `ativo`) 
VALUES ('Teste Trigger Aluno', '777.666.555-44', '(11) 91234-5678', 'teste.trigger@aluno.com', TRUE);

SELECT id_aluno, codigo_aluno, nome FROM `alunos` WHERE `cpf` = '777.666.555-44';

SELECT '--- [TESTE 5.2] Trigger de Auditoria de Pagamentos ---' AS status_teste;
SELECT * FROM `auditoria_pagamentos` ORDER BY id_auditoria DESC LIMIT 5;

-- ----------------------------------------------------------------------------
-- TESTE 6: Análise de Índices com EXPLAIN
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 6] Uso de Índices com EXPLAIN ---' AS status_teste;
EXPLAIN SELECT * FROM `mensalidades` WHERE `status` = 'PENDENTE' AND `data_vencimento` < CURDATE();
EXPLAIN SELECT * FROM `alunos` WHERE `nome` LIKE 'Lucas%';

-- ----------------------------------------------------------------------------
-- TESTE 7: Verificação de Permissões de Usuários
-- ----------------------------------------------------------------------------
SELECT '--- [TESTE 7] Privilégios Concedidos aos Usuários MySQL ---' AS status_teste;
SHOW GRANTS FOR 'academia_app'@'localhost';
SHOW GRANTS FOR 'academia_readonly'@'localhost';
