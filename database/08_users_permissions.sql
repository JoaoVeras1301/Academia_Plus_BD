-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 08_users_permissions.sql
-- Objetivo: Configuração de usuários do SGBD MySQL e concessão de privilégios.
-- ============================================================================

-- 1. USUÁRIO DA APLICAÇÃO (academia_app)
-- Cria e atualiza para localhost, 127.0.0.1, ::1 e % para compatibilidade total com Node.js
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

-- 2. USUÁRIO DE CONSULTA / RELATÓRIOS (academia_readonly)
CREATE USER IF NOT EXISTS 'academia_readonly'@'localhost' IDENTIFIED BY 'AcademiaRead#2026';
CREATE USER IF NOT EXISTS 'academia_readonly'@'127.0.0.1' IDENTIFIED BY 'AcademiaRead#2026';
CREATE USER IF NOT EXISTS 'academia_readonly'@'%' IDENTIFIED BY 'AcademiaRead#2026';

GRANT SELECT, SHOW VIEW ON `academia_db`.* TO 'academia_readonly'@'localhost';
GRANT SELECT, SHOW VIEW ON `academia_db`.* TO 'academia_readonly'@'127.0.0.1';
GRANT SELECT, SHOW VIEW ON `academia_db`.* TO 'academia_readonly'@'%';

FLUSH PRIVILEGES;
