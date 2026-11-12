-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 09_seed.sql
-- Objetivo: Carga inicial de dados consistentes (seed) para testes e avaliação.
-- Atende aos requisitos:
-- - >= 10 alunos
-- - >= 3 funcionários
-- - >= 3 planos
-- - Matrículas variadas
-- - Mensalidades pagas, parciais, pendentes e atrasadas
-- - Pagamentos em diferentes modalidades
-- - Usuários de múltiplos grupos com senhas criptografadas em bcrypt
-- - Uso de variáveis de sessão (@var) sem presumir IDs fixos.
-- ============================================================================

USE `academia_db`;

-- ----------------------------------------------------------------------------
-- 1. GRUPOS DE USUÁRIOS
-- ----------------------------------------------------------------------------
INSERT INTO `grupos_usuarios` (`nome`, `descricao`) VALUES
('ADMINISTRADOR', 'Acesso administrativo irrestrito a configurações, relatórios, usuários e demonstrações técnicas'),
('FUNCIONARIO', 'Acesso operacional a cadastro de alunos, matrículas, emissão de cobranças e registro de pagamentos')
ON DUPLICATE KEY UPDATE `descricao` = VALUES(`descricao`);

-- ----------------------------------------------------------------------------
-- 2. FUNCIONÁRIOS
-- ----------------------------------------------------------------------------
INSERT INTO `funcionarios` (`nome`, `cpf`, `telefone`, `email`, `cargo`, `data_contratacao`, `ativo`) VALUES
('Mariana Souza Ribeiro', '111.222.333-44', '(11) 98765-4321', 'mariana.souza@academia.com.br', 'Gerente Administrativa', '2023-01-15', TRUE),
('Carlos Eduardo Lima',   '222.333.444-55', '(11) 97654-3210', 'carlos.lima@academia.com.br',   'Recepcionista Chefe',    '2023-03-01', TRUE),
('Juliana Mendes Prado',  '333.444.555-66', '(11) 96543-2109', 'juliana.mendes@academia.com.br','Instrutora e Coordenadora', '2023-05-10', TRUE),
('Fernando Castro Dias',  '444.555.666-77', '(11) 95432-1098', 'fernando.dias@academia.com.br',  'Consultor de Vendas',    '2023-08-20', TRUE);

-- ----------------------------------------------------------------------------
-- 3. USUÁRIOS DO SISTEMA (Senhas bcrypt: admin123 e func123)
-- ----------------------------------------------------------------------------
SELECT id_grupo INTO @id_grp_admin FROM `grupos_usuarios` WHERE `nome` = 'ADMINISTRADOR' LIMIT 1;
SELECT id_grupo INTO @id_grp_func  FROM `grupos_usuarios` WHERE `nome` = 'FUNCIONARIO' LIMIT 1;
SELECT id_funcionario INTO @id_func_mariana FROM `funcionarios` WHERE `email` = 'mariana.souza@academia.com.br' LIMIT 1;
SELECT id_funcionario INTO @id_func_carlos  FROM `funcionarios` WHERE `email` = 'carlos.lima@academia.com.br' LIMIT 1;

INSERT INTO `usuarios` (`nome`, `email`, `senha_hash`, `id_grupo`, `id_funcionario`, `ativo`) VALUES
('Administrador do Sistema', 'admin@academia.com.br', '$2b$10$xeUCprBfcc25iVL8U0hAsOjMWtwfXzLcWX/qFwSfTMa0aoEUo/7cu', @id_grp_admin, @id_func_mariana, TRUE),
('Carlos Atendente',         'recepcao@academia.com.br', '$2b$10$FIZhBNZxPXuZR/NHKoSuRueYPtQEdJI4Zoxme26YSb0wlWcco3Ewq', @id_grp_func, @id_func_carlos, TRUE),
('Juliana Coordenadora',     'juliana@academia.com.br', '$2b$10$FIZhBNZxPXuZR/NHKoSuRueYPtQEdJI4Zoxme26YSb0wlWcco3Ewq', @id_grp_func, NULL, TRUE);

-- ----------------------------------------------------------------------------
-- 4. PLANOS DA ACADEMIA
-- ----------------------------------------------------------------------------
INSERT INTO `planos` (`nome`, `descricao`, `duracao_meses`, `valor`, `ativo`) VALUES
('Plano Mensal Básico',    'Acesso livre à musculação no período diurno', 1, 120.00, TRUE),
('Plano Trimestral Fit',    'Acesso musculação e cardio com avaliação física', 3, 105.00, TRUE),
('Plano Semestral Power',  'Musculação, cardio e aulas coletivas liberadas', 6, 95.00, TRUE),
('Plano Anual VIP Total',  'Acesso irrestrito a todas as áreas, toalhas e bioimpedância', 12, 85.00, TRUE);

-- ----------------------------------------------------------------------------
-- 5. ALUNOS (12 alunos cadastrados)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 6. MATRÍCULAS E MENSALIDADES
-- Geradas usando chamadas à procedure sp_realizar_matricula para garantir integridade
-- ----------------------------------------------------------------------------

-- Aluno 1: Semestral Power (iniciado há 3 meses -> parcelas já pagas e futuras)
SELECT id_aluno INTO @a1 FROM `alunos` WHERE `email` = 'lucas.oliveira@gmail.com' LIMIT 1;
SELECT id_plano INTO @p_sem FROM `planos` WHERE `nome` = 'Plano Semestral Power' LIMIT 1;
CALL sp_realizar_matricula(@a1, @p_sem, DATE_SUB(CURDATE(), INTERVAL 3 MONTH), @mat1_id, @mat1_cod);

-- Aluno 2: Trimestral Fit (iniciado há 2 meses -> atrasada + parcial)
SELECT id_aluno INTO @a2 FROM `alunos` WHERE `email` = 'beatriz.silva@gmail.com' LIMIT 1;
SELECT id_plano INTO @p_tri FROM `planos` WHERE `nome` = 'Plano Trimestral Fit' LIMIT 1;
CALL sp_realizar_matricula(@a2, @p_tri, DATE_SUB(CURDATE(), INTERVAL 2 MONTH), @mat2_id, @mat2_cod);

-- Aluno 3: Anual VIP (iniciado mês passado -> pendente futuro)
SELECT id_aluno INTO @a3 FROM `alunos` WHERE `email` = 'rodrigo.costa@hotmail.com' LIMIT 1;
SELECT id_plano INTO @p_vip FROM `planos` WHERE `nome` = 'Plano Anual VIP Total' LIMIT 1;
CALL sp_realizar_matricula(@a3, @p_vip, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), @mat3_id, @mat3_cod);

-- Aluno 4: Mensal Básico (iniciado hoje -> pendente)
SELECT id_aluno INTO @a4 FROM `alunos` WHERE `email` = 'camila.ramos@outlook.com' LIMIT 1;
SELECT id_plano INTO @p_men FROM `planos` WHERE `nome` = 'Plano Mensal Básico' LIMIT 1;
CALL sp_realizar_matricula(@a4, @p_men, CURDATE(), @mat4_id, @mat4_cod);

-- Aluno 5: Trimestral Fit (iniciado no mês atual)
SELECT id_aluno INTO @a5 FROM `alunos` WHERE `email` = 'thiago.barbosa@gmail.com' LIMIT 1;
CALL sp_realizar_matricula(@a5, @p_tri, CURDATE(), @mat5_id, @mat5_cod);

-- Aluno 6: Semestral Power (iniciado há 4 meses -> possui atrasadas e pagas)
SELECT id_aluno INTO @a6 FROM `alunos` WHERE `email` = 'larissa.rocha@yahoo.com' LIMIT 1;
CALL sp_realizar_matricula(@a6, @p_sem, DATE_SUB(CURDATE(), INTERVAL 4 MONTH), @mat6_id, @mat6_cod);

-- ----------------------------------------------------------------------------
-- 7. PAGAMENTOS REALIZADOS (Variadas modalidades: PIX, CARTAO, DINHEIRO)
-- O registro de pagamentos dispara as triggers de atualização de mensalidade e auditoria!
-- ----------------------------------------------------------------------------

-- Quitação das 2 primeiras parcelas da Matrícula 1 (Aluno Lucas - Semestral)
SELECT id_mensalidade INTO @m1_p1 FROM `mensalidades` WHERE `id_matricula` = @mat1_id AND `numero_parcela` = 1 LIMIT 1;
SELECT id_mensalidade INTO @m1_p2 FROM `mensalidades` WHERE `id_matricula` = @mat1_id AND `numero_parcela` = 2 LIMIT 1;
CALL sp_registrar_pagamento(@m1_p1, 95.00, 'PIX', 'Pagamento pontual via chave PIX', @pag1_id);
CALL sp_registrar_pagamento(@m1_p2, 95.00, 'CARTAO_CREDITO', 'Transação autorizada maquineta', @pag2_id);

-- Pagamento PARCIAL na Parcela 1 da Matrícula 2 (Aluna Beatriz)
-- Parcela é de R$ 105.00, pagou R$ 50.00 -> Resta R$ 55.00 (Status vira PARCIAL automaticamente pela Trigger)
SELECT id_mensalidade INTO @m2_p1 FROM `mensalidades` WHERE `id_matricula` = @mat2_id AND `numero_parcela` = 1 LIMIT 1;
CALL sp_registrar_pagamento(@m2_p1, 50.00, 'DINHEIRO', 'Entrada parcial em espécie no balcão', @pag3_id);

-- Quitação da Parcela 1 da Matrícula 3 (Aluno Rodrigo - Anual)
SELECT id_mensalidade INTO @m3_p1 FROM `mensalidades` WHERE `id_matricula` = @mat3_id AND `numero_parcela` = 1 LIMIT 1;
CALL sp_registrar_pagamento(@m3_p1, 85.00, 'CARTAO_DEBITO', 'Cartão de débito bandeira Visa', @pag4_id);

-- Quitação da Parcela 1 da Matrícula 6 (Aluna Larissa)
SELECT id_mensalidade INTO @m6_p1 FROM `mensalidades` WHERE `id_matricula` = @mat6_id AND `numero_parcela` = 1 LIMIT 1;
CALL sp_registrar_pagamento(@m6_p1, 95.00, 'PIX', 'PIX QR Code', @pag5_id);
