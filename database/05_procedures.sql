-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 05_procedures.sql
-- Objetivo: Stored Procedures com controle transacional (TCL: START TRANSACTION,
-- COMMIT, ROLLBACK) para matrícula e registro de pagamentos.
-- ============================================================================

USE `academia_db`;

DELIMITER //

-- ----------------------------------------------------------------------------
-- 1. PROCEDURE: sp_realizar_matricula
-- Objetivo: Matricula um aluno ativo em um plano ativo e gera todas as mensalidades
-- correspondentes de forma 100% atômica dentro de uma transação.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `sp_realizar_matricula` //
CREATE PROCEDURE `sp_realizar_matricula`(
    IN p_id_aluno INT,
    IN p_id_plano INT,
    IN p_data_inicio DATE,
    OUT p_id_matricula INT,
    OUT p_codigo_matricula VARCHAR(36)
)
BEGIN
    DECLARE v_duracao_meses INT;
    DECLARE v_valor_mensal DECIMAL(10,2);
    DECLARE v_valor_contratado DECIMAL(10,2);
    DECLARE v_data_fim DATE;
    DECLARE v_codigo VARCHAR(36);
    DECLARE i INT DEFAULT 0;

    -- Tratamento de exceção: Desfaz qualquer alteração e propaga erro
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Inicia transação explícita
    START TRANSACTION;

    -- Validação: Aluno existente e ativo
    IF NOT EXISTS (SELECT 1 FROM `alunos` WHERE `id_aluno` = p_id_aluno AND `ativo` = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aluno inválido ou inativo no sistema.';
    END IF;

    -- Validação: Data de início
    IF p_data_inicio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de início é obrigatória.';
    END IF;

    -- Validação: Plano existente e ativo
    SELECT duracao_meses, valor INTO v_duracao_meses, v_valor_mensal 
    FROM `planos` 
    WHERE `id_plano` = p_id_plano AND `ativo` = TRUE;

    IF v_duracao_meses IS NULL OR v_duracao_meses <= 0 OR v_valor_mensal <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Plano inválido, inativo ou com valores inconsistentes.';
    END IF;

    -- Cálculo das datas e valores
    SET v_data_fim = DATE_ADD(p_data_inicio, INTERVAL v_duracao_meses MONTH);
    SET v_valor_contratado = v_duracao_meses * v_valor_mensal;
    SET v_codigo = fn_gerar_id_matricula();

    -- Inserção do contrato de matrícula
    INSERT INTO `matriculas` (
        `codigo_matricula`, `id_aluno`, `id_plano`, 
        `data_inicio`, `data_fim`, `valor_contratado`, `status`
    ) VALUES (
        v_codigo, p_id_aluno, p_id_plano, 
        p_data_inicio, v_data_fim, v_valor_contratado, 'ATIVA'
    );
    
    SET p_id_matricula = LAST_INSERT_ID();
    SET p_codigo_matricula = v_codigo;

    -- Geração sequencial das mensalidades
    WHILE i < v_duracao_meses DO
        INSERT INTO `mensalidades` (
            `id_matricula`, `numero_parcela`, `valor`, 
            `data_vencimento`, `valor_pago`, `status`
        ) VALUES (
            p_id_matricula,
            (i + 1),
            v_valor_mensal,
            DATE_ADD(p_data_inicio, INTERVAL i MONTH),
            0.00,
            'PENDENTE'
        );
        SET i = i + 1;
    END WHILE;

    -- Confirmação com sucesso
    COMMIT;
END //

-- ----------------------------------------------------------------------------
-- 2. PROCEDURE: sp_registrar_pagamento
-- Objetivo: Registra pagamento de mensalidade, valida saldo remanescente, 
-- impede duplicidades/concorrência com lock de linha (FOR UPDATE) e opera com atomicidade.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `sp_registrar_pagamento` //
CREATE PROCEDURE `sp_registrar_pagamento`(
    IN p_id_mensalidade INT,
    IN p_valor DECIMAL(10,2),
    IN p_forma_pagamento VARCHAR(30),
    IN p_observacao VARCHAR(255),
    OUT p_id_pagamento INT
)
BEGIN
    DECLARE v_valor_mensalidade DECIMAL(10,2);
    DECLARE v_valor_pago_atual DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);
    DECLARE v_status_atual VARCHAR(20);

    -- Handler para cancelamento e rollback em falhas
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validação: Valor maior que zero
    IF p_valor IS NULL OR p_valor <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O valor do pagamento deve ser maior que zero.';
    END IF;

    -- Validação: Forma de pagamento aceita
    IF p_forma_pagamento NOT IN ('DINHEIRO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'BOLETO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forma de pagamento inválida.';
    END IF;

    -- Inicia transação explícita
    START TRANSACTION;

    -- Bloqueio da linha da mensalidade para controle de concorrência
    SELECT valor, valor_pago, status
    INTO v_valor_mensalidade, v_valor_pago_atual, v_status_atual
    FROM `mensalidades`
    WHERE `id_mensalidade` = p_id_mensalidade
    FOR UPDATE;

    IF v_valor_mensalidade IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mensalidade não encontrada.';
    END IF;

    IF v_status_atual = 'PAGA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mensalidade já se encontra totalmente quitada.';
    END IF;

    IF v_status_atual = 'CANCELADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido registrar pagamento em mensalidade cancelada.';
    END IF;

    SET v_saldo = v_valor_mensalidade - v_valor_pago_atual;

    -- Impede pagamento superior ao saldo
    IF p_valor > v_saldo THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Valor informado ultrapassa o saldo devedor da mensalidade.';
    END IF;

    -- Insere registro de pagamento (a trigger cuidará da auditoria e atualização de saldo)
    INSERT INTO `pagamentos` (
        `id_mensalidade`, `valor`, `forma_pagamento`, `observacao`
    ) VALUES (
        p_id_mensalidade, p_valor, p_forma_pagamento, p_observacao
    );

    SET p_id_pagamento = LAST_INSERT_ID();

    -- Confirmação transacional
    COMMIT;
END //

DELIMITER ;
