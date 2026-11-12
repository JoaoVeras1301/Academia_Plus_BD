-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 07_views.sql
-- Objetivo: Criação de Views para visualização gerencial e consumo pela API.
-- ============================================================================

USE `academia_db`;

-- ----------------------------------------------------------------------------
-- 1. VIEW: vw_alunos_ativos
-- Objetivo: Exibe alunos ativos com detalhes do plano atual contratado,
-- período de vigência e situação.
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

-- ----------------------------------------------------------------------------
-- 2. VIEW: vw_mensalidades_pendentes
-- Objetivo: Exibe mensalidades pendentes e parciais com saldo remanescente
-- e classificação em tempo real entre PENDENTE e ATRASADA.
-- ----------------------------------------------------------------------------
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
