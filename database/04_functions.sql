-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 04_functions.sql
-- Objetivo: Definição de Stored Functions para regras de negócio e identificadores.
-- Requisito: Não utilizar DETERMINISTIC em geradores de códigos aleatórios/UUID.
-- ============================================================================

USE `academia_db`;

DELIMITER //

-- ----------------------------------------------------------------------------
-- 1. FUNCTION: fn_gerar_id_aluno
-- Objetivo: Gera código de negócio único para o aluno (ex: ALU-202611-ABCD).
-- Características: NOT DETERMINISTIC (gera valores distintos a cada chamada).
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS `fn_gerar_id_aluno` //
CREATE FUNCTION `fn_gerar_id_aluno`() 
RETURNS VARCHAR(36)
NOT DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_prefixo VARCHAR(20);
    DECLARE v_sufixo VARCHAR(10);
    
    SET v_prefixo = DATE_FORMAT(NOW(), 'ALU-%Y%m-');
    SET v_sufixo = UPPER(SUBSTRING(MD5(UUID()), 1, 6));
    
    RETURN CONCAT(v_prefixo, v_sufixo);
END //

-- ----------------------------------------------------------------------------
-- 2. FUNCTION: fn_gerar_id_matricula
-- Objetivo: Gera código de negócio único para a matrícula (ex: MAT-202611-ABCD).
-- Características: NOT DETERMINISTIC.
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS `fn_gerar_id_matricula` //
CREATE FUNCTION `fn_gerar_id_matricula`() 
RETURNS VARCHAR(36)
NOT DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_prefixo VARCHAR(20);
    DECLARE v_sufixo VARCHAR(10);
    
    SET v_prefixo = DATE_FORMAT(NOW(), 'MAT-%Y%m-');
    SET v_sufixo = UPPER(SUBSTRING(MD5(UUID()), 1, 6));
    
    RETURN CONCAT(v_prefixo, v_sufixo);
END //

-- ----------------------------------------------------------------------------
-- 3. FUNCTION: fn_calcular_saldo_mensalidade
-- Objetivo: Retorna o saldo residual devedor de uma mensalidade específica.
-- Características: READS SQL DATA.
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS `fn_calcular_saldo_mensalidade` //
CREATE FUNCTION `fn_calcular_saldo_mensalidade`(p_id_mensalidade INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_valor DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_pago DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_saldo DECIMAL(10,2) DEFAULT 0.00;

    SELECT valor, valor_pago INTO v_valor, v_pago
    FROM `mensalidades`
    WHERE `id_mensalidade` = p_id_mensalidade;

    IF v_valor IS NULL THEN
        RETURN 0.00;
    END IF;

    SET v_saldo = v_valor - v_pago;
    IF v_saldo < 0 THEN
        SET v_saldo = 0.00;
    END IF;

    RETURN v_saldo;
END //

-- ----------------------------------------------------------------------------
-- 4. FUNCTION: fn_verificar_situacao_mensalidade
-- Objetivo: Determina dinamicamente o status real da mensalidade considerando
-- valores quitados e data de vencimento em relação à data corrente.
-- Características: READS SQL DATA.
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS `fn_verificar_situacao_mensalidade` //
CREATE FUNCTION `fn_verificar_situacao_mensalidade`(p_id_mensalidade INT) 
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_valor DECIMAL(10,2);
    DECLARE v_pago DECIMAL(10,2);
    DECLARE v_vencimento DATE;
    DECLARE v_status_banco VARCHAR(20);

    SELECT valor, valor_pago, data_vencimento, status
    INTO v_valor, v_pago, v_vencimento, v_status_banco
    FROM `mensalidades`
    WHERE `id_mensalidade` = p_id_mensalidade;

    IF v_status_banco = 'CANCELADA' THEN
        RETURN 'CANCELADA';
    END IF;

    IF v_pago >= v_valor THEN
        RETURN 'PAGA';
    ELSEIF v_pago > 0 AND v_pago < v_valor THEN
        RETURN 'PARCIAL';
    ELSEIF v_vencimento < CURDATE() THEN
        RETURN 'ATRASADA';
    ELSE
        RETURN 'PENDENTE';
    END IF;
END //

DELIMITER ;
