-- ============================================================================
-- PROJETO ACADEMIA+ | BANCO DE DADOS RELACIONAL MYSQL
-- Script: 01_database.sql
-- Objetivo: Criação da base de dados com charset UTF-8 e collation apropriada.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `academia_db`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `academia_db`;
