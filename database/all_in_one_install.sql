-- ============================================================================
-- PROJETO ACADEMIA+ | SCRIPT CONSOLIDADO DE INSTALAÇÃO COMPLETA
-- Execute este arquivo no MySQL Workbench como usuário ROOT (ou DBA)
-- Ele executa automaticamente todas as 9 etapas em ordem estrita.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. DATABASE
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `academia_db`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `academia_db`;

-- ----------------------------------------------------------------------------
-- 2. TABELAS (InnoDB)
-- ----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `auditoria_pagamentos`;
DROP TABLE IF EXISTS `pagamentos`;
DROP TABLE IF EXISTS `mensalidades`;
DROP TABLE IF EXISTS `matriculas`;
DROP TABLE IF EXISTS `planos`;
DROP TABLE IF EXISTS `alunos`;
DROP TABLE IF EXISTS `usuarios`;
DROP TABLE IF EXISTS `funcionarios`;
DROP TABLE IF EXISTS `grupos_usuarios`;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `grupos_usuarios` (
    `id_grupo` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(50) NOT NULL UNIQUE,
    `descricao` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `funcionarios` (
    `id_funcionario` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(100) NOT NULL,
    `cpf` VARCHAR(14) NOT NULL UNIQUE,
    `telefone` VARCHAR(20) NULL,
    `email` VARCHAR(100) NULL UNIQUE,
    `cargo` VARCHAR(50) NOT NULL,
    `data_contratacao` DATE NOT NULL,
    `ativo` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `usuarios` (
    `id_usuario` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `senha_hash` VARCHAR(255) NOT NULL,
    `id_grupo` INT NOT NULL,
    `id_funcionario` INT NULL,
    `ativo` BOOLEAN NOT NULL DEFAULT TRUE,
    `data_criacao` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_usuario_grupo` FOREIGN KEY (`id_grupo`) 
        REFERENCES `grupos_usuarios` (`id_grupo`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_usuario_funcionario` FOREIGN KEY (`id_funcionario`) 
        REFERENCES `funcionarios` (`id_funcionario`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `alunos` (
    `id_aluno` INT AUTO_INCREMENT PRIMARY KEY,
    `codigo_aluno` VARCHAR(36) NOT NULL UNIQUE,
    `nome` VARCHAR(100) NOT NULL,
    `cpf` VARCHAR(14) NOT NULL UNIQUE,
    `telefone` VARCHAR(20) NULL,
    `email` VARCHAR(100) NULL,
    `data_nascimento` DATE NULL,
    `endereco` VARCHAR(255) NULL,
    `data_cadastro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `ativo` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `planos` (
    `id_plano` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(50) NOT NULL,
    `descricao` VARCHAR(255) NULL,
    `duracao_meses` INT NOT NULL,
    `valor` DECIMAL(10,2) NOT NULL,
    `ativo` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `matriculas` (
    `id_matricula` INT AUTO_INCREMENT PRIMARY KEY,
    `codigo_matricula` VARCHAR(36) NOT NULL UNIQUE,
    `id_aluno` INT NOT NULL,
    `id_plano` INT NOT NULL,
    `data_inicio` DATE NOT NULL,
    `data_fim` DATE NOT NULL,
    `valor_contratado` DECIMAL(10,2) NOT NULL,
    `status` ENUM('ATIVA', 'CANCELADA', 'FINALIZADA') NOT NULL DEFAULT 'ATIVA',
    `data_criacao` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_matricula_aluno` FOREIGN KEY (`id_aluno`) 
        REFERENCES `alunos` (`id_aluno`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_matricula_plano` FOREIGN KEY (`id_plano`) 
        REFERENCES `planos` (`id_plano`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mensalidades` (
    `id_mensalidade` INT AUTO_INCREMENT PRIMARY KEY,
    `id_matricula` INT NOT NULL,
    `numero_parcela` INT NOT NULL,
    `valor` DECIMAL(10,2) NOT NULL,
    `data_vencimento` DATE NOT NULL,
    `valor_pago` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `status` ENUM('PENDENTE', 'PARCIAL', 'PAGA', 'CANCELADA') NOT NULL DEFAULT 'PENDENTE',
    CONSTRAINT `fk_mensalidade_matricula` FOREIGN KEY (`id_matricula`) 
        REFERENCES `matriculas` (`id_matricula`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pagamentos` (
    `id_pagamento` INT AUTO_INCREMENT PRIMARY KEY,
    `id_mensalidade` INT NOT NULL,
    `valor` DECIMAL(10,2) NOT NULL,
    `data_pagamento` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `forma_pagamento` ENUM('DINHEIRO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'BOLETO') NOT NULL,
    `observacao` VARCHAR(255) NULL,
    CONSTRAINT `fk_pagamento_mensalidade` FOREIGN KEY (`id_mensalidade`) 
        REFERENCES `mensalidades` (`id_mensalidade`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `auditoria_pagamentos` (
    `id_auditoria` INT AUTO_INCREMENT PRIMARY KEY,
    `id_pagamento` INT NOT NULL,
    `id_mensalidade` INT NOT NULL,
    `valor_pago` DECIMAL(10,2) NOT NULL,
    `forma_pagamento` VARCHAR(50) NOT NULL,
    `data_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `usuario_responsavel` VARCHAR(100) DEFAULT 'SISTEMA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. ÍNDICES
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_alunos_nome` ON `alunos` (`nome`);
CREATE INDEX `idx_alunos_ativo` ON `alunos` (`ativo`);
CREATE INDEX `idx_matriculas_id_aluno` ON `matriculas` (`id_aluno`);
CREATE INDEX `idx_matriculas_status` ON `matriculas` (`status`);
CREATE INDEX `idx_mensalidades_status_vencimento` ON `mensalidades` (`status`, `data_vencimento`);
CREATE INDEX `idx_mensalidades_id_matricula` ON `mensalidades` (`id_matricula`);
CREATE INDEX `idx_pagamentos_id_mensalidade` ON `pagamentos` (`id_mensalidade`);
CREATE INDEX `idx_pagamentos_data` ON `pagamentos` (`data_pagamento`);

-- ----------------------------------------------------------------------------
-- 4. FUNCTIONS
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS `fn_gerar_id_aluno`;
DELIMITER //
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
DELIMITER ;

DROP FUNCTION IF EXISTS `fn_gerar_id_matricula`;
DELIMITER //
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
DELIMITER ;

DROP FUNCTION IF EXISTS `fn_calcular_saldo_mensalidade`;
DELIMITER //
CREATE FUNCTION `fn_calcular_saldo_mensalidade`(p_id_mensalidade INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_valor DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_pago DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_saldo DECIMAL(10,2) DEFAULT 0.00;
    SELECT valor, valor_pago INTO v_valor, v_pago FROM `mensalidades` WHERE `id_mensalidade` = p_id_mensalidade;
    IF v_valor IS NULL THEN RETURN 0.00; END IF;
    SET v_saldo = v_valor - v_pago;
    IF v_saldo < 0 THEN SET v_saldo = 0.00; END IF;
    RETURN v_saldo;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS `fn_verificar_situacao_mensalidade`;
DELIMITER //
CREATE FUNCTION `fn_verificar_situacao_mensalidade`(p_id_mensalidade INT) 
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_valor DECIMAL(10,2);
    DECLARE v_pago DECIMAL(10,2);
    DECLARE v_vencimento DATE;
    DECLARE v_status_banco VARCHAR(20);
    SELECT valor, valor_pago, data_vencimento, status INTO v_valor, v_pago, v_vencimento, v_status_banco FROM `mensalidades` WHERE `id_mensalidade` = p_id_mensalidade;
    IF v_status_banco = 'CANCELADA' THEN RETURN 'CANCELADA'; END IF;
    IF v_pago >= v_valor THEN RETURN 'PAGA';
    ELSEIF v_pago > 0 AND v_pago < v_valor THEN RETURN 'PARCIAL';
    ELSEIF v_vencimento < CURDATE() THEN RETURN 'ATRASADA';
    ELSE RETURN 'PENDENTE'; END IF;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- 5. PROCEDURES
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `sp_realizar_matricula`;
DELIMITER //
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

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM `alunos` WHERE `id_aluno` = p_id_aluno AND `ativo` = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aluno inválido ou inativo no sistema.';
    END IF;

    IF p_data_inicio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de início é obrigatória.';
    END IF;

    SELECT duracao_meses, valor INTO v_duracao_meses, v_valor_mensal 
    FROM `planos` 
    WHERE `id_plano` = p_id_plano AND `ativo` = TRUE;

    IF v_duracao_meses IS NULL OR v_duracao_meses <= 0 OR v_valor_mensal <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Plano inválido, inativo ou com valores inconsistentes.';
    END IF;

    SET v_data_fim = DATE_ADD(p_data_inicio, INTERVAL v_duracao_meses MONTH);
    SET v_valor_contratado = v_duracao_meses * v_valor_mensal;
    SET v_codigo = fn_gerar_id_matricula();

    INSERT INTO `matriculas` (
        `codigo_matricula`, `id_aluno`, `id_plano`, 
        `data_inicio`, `data_fim`, `valor_contratado`, `status`
    ) VALUES (
        v_codigo, p_id_aluno, p_id_plano, 
        p_data_inicio, v_data_fim, v_valor_contratado, 'ATIVA'
    );
    
    SET p_id_matricula = LAST_INSERT_ID();
    SET p_codigo_matricula = v_codigo;

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

    COMMIT;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS `sp_registrar_pagamento`;
DELIMITER //
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

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_valor IS NULL OR p_valor <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O valor do pagamento deve ser maior que zero.';
    END IF;

    IF p_forma_pagamento NOT IN ('DINHEIRO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'BOLETO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Forma de pagamento inválida.';
    END IF;

    START TRANSACTION;

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

    IF p_valor > v_saldo THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Valor informado ultrapassa o saldo devedor da mensalidade.';
    END IF;

    INSERT INTO `pagamentos` (
        `id_mensalidade`, `valor`, `forma_pagamento`, `observacao`
    ) VALUES (
        p_id_mensalidade, p_valor, p_forma_pagamento, p_observacao
    );

    SET p_id_pagamento = LAST_INSERT_ID();

    COMMIT;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- 6. TRIGGERS
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_aluno_codigo_before_insert`;
DELIMITER //
CREATE TRIGGER `trg_aluno_codigo_before_insert`
BEFORE INSERT ON `alunos`
FOR EACH ROW
BEGIN
    IF NEW.codigo_aluno IS NULL OR TRIM(NEW.codigo_aluno) = '' THEN
        SET NEW.codigo_aluno = fn_gerar_id_aluno();
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_pagamento_after_insert_atualiza_mensalidade`;
DELIMITER //
CREATE TRIGGER `trg_pagamento_after_insert_atualiza_mensalidade`
AFTER INSERT ON `pagamentos`
FOR EACH ROW
BEGIN
    DECLARE v_total_pago DECIMAL(10,2);
    DECLARE v_valor_total DECIMAL(10,2);

    SELECT COALESCE(SUM(valor), 0.00) INTO v_total_pago
    FROM `pagamentos`
    WHERE `id_mensalidade` = NEW.id_mensalidade;

    SELECT valor INTO v_valor_total
    FROM `mensalidades`
    WHERE `id_mensalidade` = NEW.id_mensalidade;

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
DELIMITER ;

DROP TRIGGER IF EXISTS `trg_pagamento_after_insert_auditoria`;
DELIMITER //
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

-- ----------------------------------------------------------------------------
-- 7. VIEWS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_alunos_ativos` AS
SELECT 
    a.`codigo_aluno`,
    a.`nome` AS `nome_aluno`,
    COALESCE(a.`telefone`, 'Não informado') AS `telefone`,
    COALESCE(p.`nome`, 'Sem Plano Ativo') AS `plano_atual`,
    m.`data_inicio`,
    m.`data_fim`,
    CASE 
        WHEN a.`ativo` = TRUE AND (m.`status` = 'ATIVA' OR m.`status` IS NULL) THEN 'ATIVO'
        ELSE 'INATIVO'
    END AS `situacao`
FROM `alunos` a
LEFT JOIN `matriculas` m ON a.`id_aluno` = m.`id_aluno` AND m.`status` = 'ATIVA'
LEFT JOIN `planos` p ON m.`id_plano` = p.`id_plano`
WHERE a.`ativo` = TRUE;

CREATE OR REPLACE VIEW `vw_mensalidades_pendentes` AS
SELECT 
    m.`id_mensalidade`,
    m.`id_matricula`,
    a.`nome` AS `nome_aluno`,
    p.`nome` AS `nome_plano`,
    m.`numero_parcela`,
    m.`valor`,
    m.`valor_pago`,
    (m.`valor` - m.`valor_pago`) AS `saldo`,
    m.`data_vencimento`,
    CASE 
        WHEN m.`data_vencimento` < CURDATE() THEN 'ATRASADA'
        ELSE 'PENDENTE'
    END AS `situacao_financeira`
FROM `mensalidades` m
JOIN `matriculas` mat ON m.`id_matricula` = mat.`id_matricula`
JOIN `alunos` a ON mat.`id_aluno` = a.`id_aluno`
JOIN `planos` p ON mat.`id_plano` = p.`id_plano`
WHERE m.`status` IN ('PENDENTE', 'PARCIAL');

-- ----------------------------------------------------------------------------
-- 8. USUÁRIOS E PERMISSÕES DO SGBD
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'academia_app'@'localhost' IDENTIFIED BY 'AcademiaApp#2026';
CREATE USER IF NOT EXISTS 'academia_app'@'127.0.0.1' IDENTIFIED BY 'AcademiaApp#2026';
CREATE USER IF NOT EXISTS 'academia_app'@'::1' IDENTIFIED BY 'AcademiaApp#2026';
CREATE USER IF NOT EXISTS 'academia_app'@'%' IDENTIFIED BY 'AcademiaApp#2026';

ALTER USER 'academia_app'@'localhost' IDENTIFIED BY 'AcademiaApp#2026';
ALTER USER 'academia_app'@'127.0.0.1' IDENTIFIED BY 'AcademiaApp#2026';
ALTER USER 'academia_app'@'::1' IDENTIFIED BY 'AcademiaApp#2026';
ALTER USER 'academia_app'@'%' IDENTIFIED BY 'AcademiaApp#2026';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON `academia_db`.* TO 'academia_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON `academia_db`.* TO 'academia_app'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON `academia_db`.* TO 'academia_app'@'::1';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, SHOW VIEW ON `academia_db`.* TO 'academia_app'@'%';

CREATE USER IF NOT EXISTS 'academia_readonly'@'localhost' IDENTIFIED BY 'AcademiaRead#2026';
CREATE USER IF NOT EXISTS 'academia_readonly'@'127.0.0.1' IDENTIFIED BY 'AcademiaRead#2026';
CREATE USER IF NOT EXISTS 'academia_readonly'@'%' IDENTIFIED BY 'AcademiaRead#2026';

GRANT SELECT, SHOW VIEW ON `academia_db`.* TO 'academia_readonly'@'localhost';
GRANT SELECT, SHOW VIEW ON `academia_db`.* TO 'academia_readonly'@'127.0.0.1';
GRANT SELECT, SHOW VIEW ON `academia_db`.* TO 'academia_readonly'@'%';

FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 9. CARGA DE DADOS (SEED)
-- ----------------------------------------------------------------------------
INSERT INTO `grupos_usuarios` (`nome`, `descricao`) VALUES
('ADMINISTRADOR', 'Acesso administrativo irrestrito a configurações, relatórios, usuários e demonstrações técnicas'),
('FUNCIONARIO', 'Acesso operacional a cadastro de alunos, matrículas, emissão de cobranças e registro de pagamentos')
ON DUPLICATE KEY UPDATE `descricao` = VALUES(`descricao`);

INSERT INTO `funcionarios` (`nome`, `cpf`, `telefone`, `email`, `cargo`, `data_contratacao`, `ativo`) VALUES
('Mariana Souza Ribeiro', '111.222.333-44', '(11) 98765-4321', 'mariana.souza@academia.com.br', 'Gerente Administrativa', '2023-01-15', TRUE),
('Carlos Eduardo Lima',   '222.333.444-55', '(11) 97654-3210', 'carlos.lima@academia.com.br',   'Recepcionista Chefe',    '2023-03-01', TRUE),
('Juliana Mendes Prado',  '333.444.555-66', '(11) 96543-2109', 'juliana.mendes@academia.com.br','Instrutora e Coordenadora', '2023-05-10', TRUE),
('Fernando Castro Dias',  '444.555.666-77', '(11) 95432-1098', 'fernando.dias@academia.com.br',  'Consultor de Vendas',    '2023-08-20', TRUE);

SELECT id_grupo INTO @id_grp_admin FROM `grupos_usuarios` WHERE `nome` = 'ADMINISTRADOR' LIMIT 1;
SELECT id_grupo INTO @id_grp_func  FROM `grupos_usuarios` WHERE `nome` = 'FUNCIONARIO' LIMIT 1;
SELECT id_funcionario INTO @id_func_mariana FROM `funcionarios` WHERE `email` = 'mariana.souza@academia.com.br' LIMIT 1;
SELECT id_funcionario INTO @id_func_carlos  FROM `funcionarios` WHERE `email` = 'carlos.lima@academia.com.br' LIMIT 1;

INSERT INTO `usuarios` (`nome`, `email`, `senha_hash`, `id_grupo`, `id_funcionario`, `ativo`) VALUES
('Administrador do Sistema', 'admin@academia.com.br', '$2b$10$xeUCprBfcc25iVL8U0hAsOjMWtwfXzLcWX/qFwSfTMa0aoEUo/7cu', @id_grp_admin, @id_func_mariana, TRUE),
('Carlos Atendente',         'recepcao@academia.com.br', '$2b$10$FIZhBNZxPXuZR/NHKoSuRueYPtQEdJI4Zoxme26YSb0wlWcco3Ewq', @id_grp_func, @id_func_carlos, TRUE),
('Juliana Coordenadora',     'juliana@academia.com.br', '$2b$10$FIZhBNZxPXuZR/NHKoSuRueYPtQEdJI4Zoxme26YSb0wlWcco3Ewq', @id_grp_func, NULL, TRUE);

INSERT INTO `planos` (`nome`, `descricao`, `duracao_meses`, `valor`, `ativo`) VALUES
('Plano Mensal Básico',    'Acesso livre à musculação no período diurno', 1, 120.00, TRUE),
('Plano Trimestral Fit',    'Acesso musculação e cardio com avaliação física', 3, 105.00, TRUE),
('Plano Semestral Power',  'Musculação, cardio e aulas coletivas liberadas', 6, 95.00, TRUE),
('Plano Anual VIP Total',  'Acesso irrestrito a todas as áreas, toalhas e bioimpedância', 12, 85.00, TRUE);

INSERT INTO `alunos` (`codigo_aluno`, `nome`, `cpf`, `telefone`, `email`, `data_nascimento`, `endereco`, `ativo`) VALUES
('ALU-202401-0001', 'Lucas Gabriel Oliveira',  '501.123.456-78', '(11) 98111-2233', 'lucas.oliveira@gmail.com',  '1995-04-12', 'Rua das Flores, 120 - SP', TRUE),
('ALU-202401-0002', 'Beatriz Silva Santos',     '502.234.567-89', '(11) 98222-3344', 'beatriz.silva@gmail.com',     '1998-09-23', 'Av. Paulista, 1500, Ap 42 - SP', TRUE),
('ALU-202401-0003', 'Rodrigo Martins Costa',    '503.345.678-90', '(11) 98333-4455', 'rodrigo.costa@hotmail.com',  '1992-12-05', 'Rua Augusta, 850 - SP', TRUE),
('ALU-202401-0004', 'Camila Ferreira Ramos',    '504.456.789-01', '(11) 98444-5566', 'camila.ramos@outlook.com',  '2001-03-18', 'Rua Vergueiro, 320 - SP', TRUE),
('ALU-202401-0005', 'Thiago Henrique Barbosa',  '505.567.890-12', '(11) 98555-6677', 'thiago.barbosa@gmail.com',  '1989-07-30', 'Rua Domingos de Morais, 900 - SP', TRUE),
('ALU-202401-0006', 'Larissa Azevedo Rocha',    '506.678.901-23', '(11) 98666-7788', 'larissa.rocha@yahoo.com',   '1996-11-14', 'Av. Rebouças, 1200 - SP', TRUE),
('ALU-202401-0007', 'Mateus Pinheiro Alencar',  '507.789.012-34', '(11) 98777-8899', 'mateus.alencar@gmail.com',  '1994-02-28', 'Alameda Santos, 450 - SP', TRUE),
('ALU-202401-0008', 'Fernanda Lima Nogueira',   '508.890.123-45', '(11) 98888-9900', 'fernanda.lima@uol.com.br',  '2000-08-15', 'Rua Consolação, 2100 - SP', TRUE),
('ALU-202401-0009', 'Vinicius Prado Duarte',    '509.901.234-56', '(11) 98999-0011', 'vinicius.prado@gmail.com',  '1997-05-19', 'Rua Oscar Freire, 300 - SP', TRUE),
('ALU-202401-0010', 'Patricia Guimarães Neves', '510.012.345-67', '(11) 99111-1122', 'patricia.neves@gmail.com', '1993-10-08', 'Av. Brigadeiro Faria Lima, 2000 - SP', TRUE),
('ALU-202401-0011', 'Diego Farias Santana',     '511.123.456-78', '(11) 99222-2233', 'diego.farias@gmail.com',    '1990-06-11', 'Rua Haddock Lobo, 780 - SP', TRUE),
('ALU-202401-0012', 'Renata Correia Viana',     '512.234.567-89', '(11) 99333-3344', 'renata.viana@gmail.com',    '1985-01-25', 'Rua Bela Cintra, 1100 - SP', FALSE);

-- Matrícula 1
SELECT id_aluno INTO @a1 FROM `alunos` WHERE `email` = 'lucas.oliveira@gmail.com' LIMIT 1;
SELECT id_plano INTO @p_sem FROM `planos` WHERE `nome` = 'Plano Semestral Power' LIMIT 1;
CALL sp_realizar_matricula(@a1, @p_sem, DATE_SUB(CURDATE(), INTERVAL 3 MONTH), @mat1_id, @mat1_cod);

-- Matrícula 2
SELECT id_aluno INTO @a2 FROM `alunos` WHERE `email` = 'beatriz.silva@gmail.com' LIMIT 1;
SELECT id_plano INTO @p_tri FROM `planos` WHERE `nome` = 'Plano Trimestral Fit' LIMIT 1;
CALL sp_realizar_matricula(@a2, @p_tri, DATE_SUB(CURDATE(), INTERVAL 2 MONTH), @mat2_id, @mat2_cod);

-- Matrícula 3
SELECT id_aluno INTO @a3 FROM `alunos` WHERE `email` = 'rodrigo.costa@hotmail.com' LIMIT 1;
SELECT id_plano INTO @p_vip FROM `planos` WHERE `nome` = 'Plano Anual VIP Total' LIMIT 1;
CALL sp_realizar_matricula(@a3, @p_vip, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), @mat3_id, @mat3_cod);

-- Matrícula 4
SELECT id_aluno INTO @a4 FROM `alunos` WHERE `email` = 'camila.ramos@outlook.com' LIMIT 1;
SELECT id_plano INTO @p_men FROM `planos` WHERE `nome` = 'Plano Mensal Básico' LIMIT 1;
CALL sp_realizar_matricula(@a4, @p_men, CURDATE(), @mat4_id, @mat4_cod);

-- Matrícula 5
SELECT id_aluno INTO @a5 FROM `alunos` WHERE `email` = 'thiago.barbosa@gmail.com' LIMIT 1;
CALL sp_realizar_matricula(@a5, @p_tri, CURDATE(), @mat5_id, @mat5_cod);

-- Matrícula 6
SELECT id_aluno INTO @a6 FROM `alunos` WHERE `email` = 'larissa.rocha@yahoo.com' LIMIT 1;
CALL sp_realizar_matricula(@a6, @p_sem, DATE_SUB(CURDATE(), INTERVAL 4 MONTH), @mat6_id, @mat6_cod);

-- Pagamentos
SELECT id_mensalidade INTO @m1_p1 FROM `mensalidades` WHERE `id_matricula` = @mat1_id AND `numero_parcela` = 1 LIMIT 1;
SELECT id_mensalidade INTO @m1_p2 FROM `mensalidades` WHERE `id_matricula` = @mat1_id AND `numero_parcela` = 2 LIMIT 1;
CALL sp_registrar_pagamento(@m1_p1, 95.00, 'PIX', 'Pagamento pontual via chave PIX', @pag1_id);
CALL sp_registrar_pagamento(@m1_p2, 95.00, 'CARTAO_CREDITO', 'Transação autorizada maquineta', @pag2_id);

SELECT id_mensalidade INTO @m2_p1 FROM `mensalidades` WHERE `id_matricula` = @mat2_id AND `numero_parcela` = 1 LIMIT 1;
CALL sp_registrar_pagamento(@m2_p1, 50.00, 'DINHEIRO', 'Entrada parcial em espécie no balcão', @pag3_id);

SELECT id_mensalidade INTO @m3_p1 FROM `mensalidades` WHERE `id_matricula` = @mat3_id AND `numero_parcela` = 1 LIMIT 1;
CALL sp_registrar_pagamento(@m3_p1, 85.00, 'CARTAO_DEBITO', 'Cartão de débito bandeira Visa', @pag4_id);

SELECT id_mensalidade INTO @m6_p1 FROM `mensalidades` WHERE `id_matricula` = @mat6_id AND `numero_parcela` = 1 LIMIT 1;
CALL sp_registrar_pagamento(@m6_p1, 95.00, 'PIX', 'PIX QR Code', @pag5_id);

SELECT 'INSTALACAO CONCLUIDA COM SUCESSO! ACADEMIA+ PRONTO PARA USO.' AS STATUS;
