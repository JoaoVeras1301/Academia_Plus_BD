-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 02_tables.sql
-- Objetivo: Criação das tabelas relacionais com integridade referencial (InnoDB).
-- Justificativa AUTO_INCREMENT: Utilizado exclusivamente para chaves primárias
-- surrogate (internas ao SGBD) para garantir performance em JOINs e indexação B-Tree.
-- Regras próprias e funções de negócio geram códigos públicos (ex: codigo_aluno, codigo_matricula).
-- ============================================================================

USE `academia_db`;

-- Desativa checagem temporária para permitir recriação limpa se necessário
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

-- ----------------------------------------------------------------------------
-- 1. TABELA: grupos_usuarios
-- Perfis e níveis de acesso (ex: ADMINISTRADOR, FUNCIONARIO)
-- ----------------------------------------------------------------------------
CREATE TABLE `grupos_usuarios` (
    `id_grupo` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(50) NOT NULL UNIQUE,
    `descricao` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. TABELA: funcionarios
-- Colaboradores da academia
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 3. TABELA: usuarios
-- Acesso ao sistema web, vinculados a um grupo e opcionalmente a um funcionário
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 4. TABELA: alunos
-- Alunos matriculados com código de negócio e dados cadastrais
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 5. TABELA: planos
-- Planos de assinatura disponíveis
-- ----------------------------------------------------------------------------
CREATE TABLE `planos` (
    `id_plano` INT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(50) NOT NULL,
    `descricao` VARCHAR(255) NULL,
    `duracao_meses` INT NOT NULL,
    `valor` DECIMAL(10,2) NOT NULL,
    `ativo` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 6. TABELA: matriculas
-- Contratos de matrícula de alunos em planos
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 7. TABELA: mensalidades
-- Parcelas geradas automaticamente para cada contrato de matrícula
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 8. TABELA: pagamentos
-- Registro de transações financeiras associadas às mensalidades
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 9. TABELA: auditoria_pagamentos
-- Tabela de trilha de auditoria alimentada por trigger
-- ----------------------------------------------------------------------------
CREATE TABLE `auditoria_pagamentos` (
    `id_auditoria` INT AUTO_INCREMENT PRIMARY KEY,
    `id_pagamento` INT NOT NULL,
    `id_mensalidade` INT NOT NULL,
    `valor_pago` DECIMAL(10,2) NOT NULL,
    `forma_pagamento` VARCHAR(50) NOT NULL,
    `data_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `usuario_responsavel` VARCHAR(100) DEFAULT 'SISTEMA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
