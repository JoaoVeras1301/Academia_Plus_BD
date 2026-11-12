-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 03_indexes.sql
-- Objetivo: Criação de índices secundários estratégicos com justificativas técnicas.
-- Nota: Colunas com PRIMARY KEY e UNIQUE (como CPFs e códigos de negócio)
-- já possuem índices implícitos criados pelo InnoDB, evitando duplicações desnecessárias.
-- ============================================================================

USE `academia_db`;

-- ----------------------------------------------------------------------------
-- 1. Índice: idx_alunos_nome
-- Justificativa: Permite consultas rápidas por nome de alunos no campo de busca
-- do módulo de alunos (ex: WHERE nome LIKE 'Carlos%').
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_alunos_nome` ON `alunos` (`nome`);

-- ----------------------------------------------------------------------------
-- 2. Índice: idx_alunos_ativo
-- Justificativa: Otimiza a view vw_alunos_ativos e os filtros da listagem de alunos,
-- reduzindo a leitura de registros inativos.
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_alunos_ativo` ON `alunos` (`ativo`);

-- ----------------------------------------------------------------------------
-- 3. Índice: idx_matriculas_id_aluno
-- Justificativa: Otimiza a junção (JOIN) e busca do histórico de matrículas
-- de um determinado aluno (chave estrangeira id_aluno).
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_matriculas_id_aluno` ON `matriculas` (`id_aluno`);

-- ----------------------------------------------------------------------------
-- 4. Índice: idx_matriculas_status
-- Justificativa: Agiliza a contagem e filtro de matrículas com status 'ATIVA'
-- para o Dashboard e verificações de acesso à academia.
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_matriculas_status` ON `matriculas` (`status`);

-- ----------------------------------------------------------------------------
-- 5. Índice composto: idx_mensalidades_status_vencimento
-- Justificativa: Índice composto de alta seletividade para consultas financeiras críticas:
-- busca de mensalidades pendentes ordenadas por vencimento e identificação
-- imediata de mensalidades em atraso (WHERE status = 'PENDENTE' AND data_vencimento < CURDATE()).
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_mensalidades_status_vencimento` ON `mensalidades` (`status`, `data_vencimento`);

-- ----------------------------------------------------------------------------
-- 6. Índice: idx_mensalidades_id_matricula
-- Justificativa: Acelera a consulta de todas as parcelas associadas a uma matrícula específica
-- no momento da exibição financeira ou conferência contratual.
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_mensalidades_id_matricula` ON `mensalidades` (`id_matricula`);

-- ----------------------------------------------------------------------------
-- 7. Índice: idx_pagamentos_id_mensalidade
-- Justificativa: Otimiza as somas e junções entre mensalidades e seus pagamentos,
-- essencial para cálculo de saldo e auditoria de pagamentos parciais.
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_pagamentos_id_mensalidade` ON `pagamentos` (`id_mensalidade`);

-- ----------------------------------------------------------------------------
-- 8. Índice: idx_pagamentos_data
-- Justificativa: Melhora substancialmente as consultas do Dashboard e relatórios contábeis
-- que filtram receitas por mês e ano (WHERE data_pagamento BETWEEN ...).
-- ----------------------------------------------------------------------------
CREATE INDEX `idx_pagamentos_data` ON `pagamentos` (`data_pagamento`);
