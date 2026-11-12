# Academia+ | Sistema Integrado de Gestão para Academias & MySQL 8

Sistema web completo desenvolvido para a disciplina de Banco de Dados Relacional, integrando frontend responsivo, backend em Node.js/Express e um banco de dados relacional MySQL 8 avançado com controle transacional (TCL), Stored Procedures, Functions, Triggers, Views e usuários com diferentes níveis de privilégios.

---

## 📋 Sumário
1. [Visão Geral e Arquitetura](#-visão-geral-e-arquitetura)
2. [Estrutura do Projeto](#-estrutura-do-projeto)
3. [Requisitos do SGBD MySQL Cumpridos](#-requisitos-do-sgbd-mysql-cumpridos)
4. [Instalação e Configuração Passo a Passo](#-instalação-e-configuração-passo-a-passo)
5. [Credenciais de Teste e Avaliação](#-credenciais-de-teste-e-avaliação)
6. [Guia de Apresentação e Demonstração Oral (5 Minutos)](#-guia-de-apresentação-e-demonstração-oral-5-minutos)
7. [Relatório de Testes e Validação](#-relatório-de-testes-e-validação)

---

## 🏛 Visão Geral e Arquitetura

O **Academia+** foi concebido com uma arquitetura em camadas clara e desacoplada:

- **Frontend:** Single/Multi-page moderna em HTML5, CSS3 com tema escuro (Dark Slate/Green), JavaScript Vanilla (ES6+), Font Awesome e formulários com máscaras.
- **Backend:** API REST desenvolvida em Node.js e Express, utilizando `mysql2/promise` com Connection Pool, autenticação JWT (`jsonwebtoken`) e criptografia com `bcrypt`.
- **Banco de Dados (MySQL 8):** Modelagem relacional completa em InnoDB, com integridade referencial, índices estratégicos, views, triggers de negócio e auditoria, procedures com transações explícitas (TCL: `START TRANSACTION`, `COMMIT`, `ROLLBACK`) e isolamento de permissões sem uso do usuário `root`.

---

## 📂 Estrutura do Projeto

```
TRABALHO_BD_ACADEMIA/
├── database/
│   ├── 01_database.sql             # Criação da base academia_db (utf8mb4)
│   ├── 02_tables.sql               # Criação das 9 tabelas relacionais (InnoDB)
│   ├── 03_indexes.sql              # Índices com justificativas técnicas
│   ├── 04_functions.sql            # 4 Stored Functions (IDs e regras de saldo)
│   ├── 05_procedures.sql           # Procedures com TCL (sp_realizar_matricula, sp_registrar_pagamento)
│   ├── 06_triggers.sql             # Triggers de código, status de mensalidade e auditoria
│   ├── 07_views.sql                # Views (vw_alunos_ativos, vw_mensalidades_pendentes)
│   ├── 08_users_permissions.sql    # Criação de usuários MySQL (academia_app, academia_readonly)
│   ├── 09_seed.sql                 # Carga de teste completa (>=10 alunos, planos, mensalidades, pagamentos)
│   └── 10_tests.sql                # Roteiro de testes SQL para validação e apresentação
├── backend/
│   ├── src/
│   │   ├── config/db.js            # Conexão Pool com MySQL (mysql2/promise)
│   │   ├── middlewares/auth.js     # Middleware JWT e controle por grupo (RBAC)
│   │   ├── controllers/            # Lógica dos módulos (Alunos, Matrículas, Pagamentos, etc.)
│   │   ├── routes/                 # Definição e proteção das rotas REST
│   │   └── app.js                  # Inicialização do Express e middlewares
│   ├── server.js                   # Ponto de entrada do servidor backend
│   ├── package.json                # Dependências Node.js
│   ├── .env.example                # Template de configuração de variáveis
│   └── .env                        # Configurações ativas do ambiente local
├── frontend/
│   ├── css/style.css               # Folha de estilo completa (Tema Escuro / Verde)
│   ├── js/
│   │   ├── app.js                  # Sessão JWT, controle de menus e helper da API
│   │   ├── dashboard.js            # Consulta de KPIs reais do banco
│   │   └── demonstracao.js         # Controle da tela de demonstração técnica MySQL
│   ├── pages/
│   │   ├── alunos.html             # CRUD completo com máscaras de CPF/Telefone
│   │   ├── funcionarios.html       # Gestão de colaboradores (exclusivo ADMIN)
│   │   ├── planos.html             # Catálogo e cadastro de planos de academia
│   │   ├── matriculas.html         # Matrícula transacional com procedure e parcelas
│   │   ├── financeiro.html         # Gestão de mensalidades, View pendentes e pagamentos
│   │   ├── usuarios.html           # Gestão de usuários e grupos (exclusivo ADMIN)
│   │   └── demonstracao.html       # Painel interativo de demonstração técnica MySQL
│   ├── index.html                  # Dashboard central com métricas reais
│   └── login.html                  # Tela de autenticação e botões de acesso rápido
├── .gitignore                      # Proteção de node_modules e arquivos sensíveis
└── README.md                       # Documentação técnica completa
```

---

## 🎯 Requisitos do SGBD MySQL Cumpridos

| Requisito do Professor | Implementação no Academia+ | Arquivo SQL |
| :--- | :--- | :--- |
| **Tabelas Relacionadas** | 9 tabelas (`grupos_usuarios`, `funcionarios`, `usuarios`, `alunos`, `planos`, `matriculas`, `mensalidades`, `pagamentos`, `auditoria_pagamentos`) com FKs em InnoDB. | `database/02_tables.sql` |
| **Índices com Justificativa** | 8 índices estratégicos criados sem duplicação de PKs/UNIQUEs (ex: `idx_mensalidades_status_vencimento`, `idx_alunos_nome`). | `database/03_indexes.sql` |
| **Stored Functions (≥ 2)** | 4 functions: `fn_gerar_id_aluno` (NOT DETERMINISTIC), `fn_gerar_id_matricula` (NOT DETERMINISTIC), `fn_calcular_saldo_mensalidade`, `fn_verificar_situacao_mensalidade`. | `database/04_functions.sql` |
| **Stored Procedures (≥ 2)** | 2 procedures transacionais: `sp_realizar_matricula` e `sp_registrar_pagamento`. | `database/05_procedures.sql` |
| **TCL (Transações)** | `START TRANSACTION`, `COMMIT`, `ROLLBACK` via handlers em Procedures e demonstráveis interativamente no painel. | `database/05_procedures.sql` / `database/10_tests.sql` |
| **Triggers (≥ 2)** | 3 triggers ativas: geração de código comercial no aluno, atualização automática de saldo/status da mensalidade e trilha de auditoria em pagamentos. | `database/06_triggers.sql` |
| **Views (≥ 2)** | 2 Views consultadas pela aplicação: `vw_alunos_ativos` e `vw_mensalidades_pendentes`. | `database/07_views.sql` |
| **Usuários e Permissões** | Usuários MySQL específicos: `academia_app` (DML + EXECUTE + SHOW VIEW) e `academia_readonly`. **Proibido root**. | `database/08_users_permissions.sql` |
| **Tabelas Obrigatórias** | `usuarios` e `grupos_usuarios` com relacionamentos e senhas com hash `bcrypt`. | `database/02_tables.sql` |
| **Geração de IDs Própria** | Códigos de negócio gerados por functions (`ALU-YYYYMM-XXXX`, `MAT-YYYYMM-XXXX`) com justificativa para surrogate keys em AUTO_INCREMENT. | `database/04_functions.sql` |

---

## 🚀 Instalação e Configuração Passo a Passo

### 1. Banco de Dados MySQL
Abra o MySQL Workbench, terminal MySQL ou DBeaver e execute os scripts da pasta `database/` **estritamente nesta ordem**:

```sql
SOURCE database/01_database.sql;
SOURCE database/02_tables.sql;
SOURCE database/03_indexes.sql;
SOURCE database/04_functions.sql;
SOURCE database/05_procedures.sql;
SOURCE database/06_triggers.sql;
SOURCE database/07_views.sql;
SOURCE database/08_users_permissions.sql;
SOURCE database/09_seed.sql;
```

> **Dica de Avaliação:** Para executar os testes automatizados do banco, execute:
> ```sql
> SOURCE database/10_tests.sql;
> ```

### 2. Backend (Node.js)
Abra o terminal na pasta `backend/`:

```bash
cd backend
npm install
npm start
```

O servidor iniciará em `http://localhost:3000`.

### 3. Acesso à Aplicação Web
Abra seu navegador em:
👉 **`http://localhost:3000`** ou **`http://localhost:3000/login.html`**

*(A aplicação também pode ser acessada abrindo o arquivo `frontend/login.html` diretamente ou via Live Server).*

---

## 🔑 Credenciais de Teste e Avaliação

Para facilitar a apresentação ao professor, a tela de login conta com botões de preenchimento automático:

| Perfil | E-mail | Senha | Nível de Acesso |
| :--- | :--- | :--- | :--- |
| **Administrador** | `admin@academia.com.br` | `admin123` | Acesso irrestrito a todos os módulos e Painel de Demonstração MySQL |
| **Funcionário** | `recepcao@academia.com.br` | `func123` | Operacional: Alunos, Matrículas, Planos e Pagamentos |

---

## 🎤 Guia de Apresentação e Demonstração Oral (5 Minutos)

Para a apresentação de até cinco minutos com o professor, siga este roteiro testado:

1. **Abertura (30s):** Faça login com `admin@academia.com.br`. Mostre o Dashboard com indicadores reais vindos do MySQL (Alunos, Matrículas, Receita do mês).
2. **Conexão Segura e Permissões (30s):** Abra a página **Demonstração MySQL** -> Item 6. Mostre que o backend está conectado com o usuário `academia_app` e liste os privilégios (`SHOW GRANTS`), ressaltando que o `root` não é utilizado.
3. **Controle Transacional TCL (1 min):**
   - Clique em **"Executar Transação com SUCESSO (COMMIT)"**: mostre a procedure `sp_realizar_matricula` inserindo o contrato e todas as mensalidades atômicas com `COMMIT`.
   - Clique em **"Provocar Falha e Testar ROLLBACK"**: mostre o erro proposital capturado e o `ROLLBACK` desfazendo as alterações sem deixar dados corrompidos.
4. **Views do SGBD (45s):** Clique em **"Consultar vw_mensalidades_pendentes"** e mostre que ela também pode ser visualizada no menu **Financeiro** -> aba **View do MySQL**.
5. **Functions e Triggers (1 min):**
   - Mostre as Stored Functions gerando os códigos de negócio `ALU-...` e `MAT-...` e calculando saldos.
   - Mostre a tabela `auditoria_pagamentos` alimentada pela trigger em tempo real quando um pagamento é registrado.
6. **Encerramento (15s):** Destaque os índices estratégicos analisados via `EXPLAIN` e a separação dos papéis no backend.

---

## ✅ Relatório de Testes e Validação

- [x] **Integridade Referencial:** Chaves estrangeiras com `ON UPDATE CASCADE` e `ON DELETE RESTRICT` operando em conformidade.
- [x] **Autenticação:** Protegida com salt rounds de `bcrypt` e tokens JWT expirando em 8 horas.
- [x] **Triggers:** Testadas e validadas: geração de código no `INSERT` de aluno, cálculo automático de saldo e auditoria de pagamento.
- [x] **Procedures & TCL:** Testados cenários de sucesso (`COMMIT`) e falha com cancelamento atômico (`ROLLBACK`).
- [x] **Views:** Testadas e exibidas diretamente na API (`/api/mensalidades/pendentes-view` e `/api/demonstracao/views/...`).
- [x] **Usuários MySQL:** Conexão homologada com o usuário `academia_app`.
