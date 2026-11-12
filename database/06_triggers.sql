-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 06_triggers.sql
-- Objetivo: Definição de Triggers para geração de códigos de negócio,
-- atualização automática do status financeiro e auditoria de pagamentos.
-- ============================================================================

USE `academia_db`;

DELIMITER //

-- ----------------------------------------------------------------------------
-- 1. TRIGGER: trg_aluno_codigo_before_insert
-- Momento: BEFORE INSERT ON alunos
-- Objetivo: Garante a geração automática do código de negócio único para o aluno
-- chamando a function fn_gerar_id_aluno caso não tenha sido fornecido.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_aluno_codigo_before_insert` //
CREATE TRIGGER `trg_aluno_codigo_before_insert`
BEFORE INSERT ON `alunos`
FOR EACH ROW
BEGIN
    IF NEW.codigo_aluno IS NULL OR TRIM(NEW.codigo_aluno) = '' THEN
        SET NEW.codigo_aluno = fn_gerar_id_aluno();
    END IF;
END //

-- ----------------------------------------------------------------------------
-- 2. TRIGGER: trg_pagamento_after_insert_atualiza_mensalidade
-- Momento: AFTER INSERT ON pagamentos
-- Objetivo: Atualiza o valor_pago acumulado e o status ('PAGA' ou 'PARCIAL')
-- na tabela mensalidades automaticamente após a efetivação de um pagamento.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_pagamento_after_insert_atualiza_mensalidade` //
CREATE TRIGGER `trg_pagamento_after_insert_atualiza_mensalidade`
AFTER INSERT ON `pagamentos`
FOR EACH ROW
BEGIN
    DECLARE v_total_pago DECIMAL(10,2);
    DECLARE v_valor_total DECIMAL(10,2);

    -- Soma todos os pagamentos da mensalidade
    SELECT COALESCE(SUM(valor), 0.00) INTO v_total_pago
    FROM `pagamentos`
    WHERE `id_mensalidade` = NEW.id_mensalidade;

    -- Obtém o valor nominal da mensalidade
    SELECT valor INTO v_valor_total
    FROM `mensalidades`
    WHERE `id_mensalidade` = NEW.id_mensalidade;

    -- Atualiza a mensalidade com o novo total pago e status
    IF v_total_pago >= v_valor_total THEN
        UPDATE `mensalidades` 
        SET `valor_pago` = v_total_pago,
            `status` = 'PAGA'
        WHERE `id_mensalidade` = NEW.id_mensalidade;
    ELSE
        UPDATE `mensalidades` 
        SET `valor_pago` = v_total_pago,
            `status` = 'PARCIAL'
        WHERE `id_mensalidade` = NEW.id_mensalidade;
    END IF;
END //

-- ----------------------------------------------------------------------------
-- 3. TRIGGER: trg_pagamento_after_insert_auditoria
-- Momento: AFTER INSERT ON pagamentos
-- Objetivo: Registra trilha de auditoria completa na tabela auditoria_pagamentos
-- capturando dados do pagamento e usuário responsável.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_pagamento_after_insert_auditoria` //
CREATE TRIGGER `trg_pagamento_after_insert_auditoria`
AFTER INSERT ON `pagamentos`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_pagamentos` (
        `id_pagamento`,
        `id_mensalidade`,
        `valor_pago`,
        `forma_pagamento`,
        `data_registro`,
        `usuario_responsavel`
    ) VALUES (
        NEW.id_pagamento,
        NEW.id_mensalidade,
        NEW.valor,
        NEW.forma_pagamento,
        NOW(),
        CURRENT_USER()
    );
END //

DELIMITER ;
