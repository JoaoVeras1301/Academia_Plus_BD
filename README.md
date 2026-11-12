# 🏋️ Academia+ — Sistema de Gerenciamento de Academias

O **Academia+** é uma aplicação web desenvolvida para gerenciar as principais operações de uma academia, reunindo cadastro de alunos, funcionários, planos, matrículas e controle financeiro em um único sistema.

O projeto foi desenvolvido como atividade acadêmica da disciplina de Banco de Dados, com foco na integração entre uma aplicação web e o SGBD MySQL, explorando recursos como procedures, functions, triggers, views, índices, transações e controle de permissões.

## ✨ Funcionalidades

- **Dashboard:** visualização de indicadores gerais da academia.
- **Alunos:** cadastro, consulta, edição e gerenciamento de alunos.
- **Funcionários:** gerenciamento dos colaboradores.
- **Planos:** cadastro e administração dos planos oferecidos.
- **Matrículas:** criação e gerenciamento de matrículas, com geração de mensalidades.
- **Financeiro:** consulta de mensalidades, acompanhamento de pagamentos e histórico financeiro.
- **Usuários e permissões:** gerenciamento de contas e níveis de acesso.
- **Demonstração técnica:** painel para apresentar recursos e funcionalidades do MySQL utilizados no projeto.

## 🛠️ Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| HTML5 | Estrutura da aplicação |
| CSS3 | Estilização e responsividade |
| JavaScript | Interatividade e comunicação com a API |
| Node.js | Ambiente de execução do backend |
| Express | Construção da API REST |
| MySQL 8+ | Banco de dados relacional |
| mysql2 | Integração entre Node.js e MySQL |
| JWT | Autenticação |
| bcrypt | Criptografia de senhas |

## 🗄️ Banco de dados

O projeto utiliza um banco de dados relacional chamado `academia_db`, composto pelas seguintes tabelas:

- `grupos_usuarios`
- `usuarios`
- `funcionarios`
- `alunos`
- `planos`
- `matriculas`
- `mensalidades`
- `pagamentos`
- `auditoria_pagamentos`

### Recursos implementados no MySQL

- Relacionamentos e integridade referencial.
- Índices para otimização de consultas.
- **Triggers:** geração de código de aluno, atualização de mensalidades e auditoria de pagamentos.
- **Views:** `vw_alunos_ativos` e `vw_mensalidades_pendentes`.
- **Stored Procedures:** `sp_realizar_matricula` e `sp_registrar_pagamento`.
- **Stored Functions:** geração de identificadores e cálculo/verificação de informações financeiras.
- **TCL:** utilização de transações com `START TRANSACTION`, `COMMIT` e `ROLLBACK`.
- Usuários específicos do MySQL com diferentes níveis de permissões.

## 📁 Estrutura do projeto

```text
ACADEMIA+/
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middlewares/
│   │   ├── routes/
│   │   └── app.js
│   ├── server.js
│   ├── package.json
│   └── .env.example
│
├── database/
│   ├── 01_database.sql
│   ├── 02_tables.sql
│   ├── 03_indexes.sql
│   ├── 04_functions.sql
│   ├── 05_procedures.sql
│   ├── 06_triggers.sql
│   ├── 07_views.sql
│   ├── 08_users_permissions.sql
│   ├── 09_seed.sql
│   ├── 10_tests.sql
│   └── all_in_one_install.sql
│
├── frontend/
│   ├── css/
│   ├── js/
│   ├── pages/
│   ├── index.html
│   └── login.html
│
├── .gitignore
└── README.md
```

## 🚀 Como executar o projeto

### 1. Pré-requisitos

Antes de começar, instale:

- [Node.js](https://nodejs.org/)
- [MySQL 8+](https://dev.mysql.com/downloads/mysql/)
- [MySQL Workbench](https://dev.mysql.com/downloads/workbench/) (opcional, para administração do banco).

### 2. Configuração do banco de dados

O projeto disponibiliza scripts SQL na pasta `database/`.

Para uma instalação inicial em um banco novo, execute o script:

```text
database/all_in_one_install.sql
```

Ele reúne a criação da estrutura, os objetos do banco, usuários e dados de demonstração.

Também existe o instalador automatizado:

```bash
cd backend
node setup_database.js
```

O instalador solicita a senha do administrador do MySQL para realizar o provisionamento inicial.

**Atenção:** utilize os scripts de instalação somente em um ambiente novo, pois alguns comandos podem remover estruturas existentes. Não execute a instalação novamente em um banco que contenha dados importantes sem realizar backup e revisar os scripts.

### 3. Configuração do backend

Entre na pasta do backend:

```bash
cd backend
```

Instale as dependências:

```bash
npm install
```

Crie um arquivo `.env` com base no `.env.example` e configure as variáveis de ambiente:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=academia_app
DB_PASSWORD=sua_senha_mysql
DB_NAME=academia_db

JWT_SECRET=gere_um_segredo_aleatorio

PORT=3000
NODE_ENV=development
```

Utilize as credenciais correspondentes aos usuários configurados no seu MySQL. Não utilize o usuário `root` na conexão normal da aplicação.

### 4. Inicialização

Ainda dentro da pasta `backend`, execute:

```bash
npm start
```

Após iniciar o servidor, acesse:

```text
http://localhost:3000
```

A API também disponibiliza uma rota de verificação:

```text
http://localhost:3000/api/health
```

## 🔐 Controle de acesso

O sistema possui autenticação e gerenciamento de permissões por grupos de usuários.

Os grupos previstos são:

- **ADMINISTRADOR:** acesso às funcionalidades administrativas e de gerenciamento.
- **FUNCIONARIO:** acesso às funcionalidades operacionais permitidas.

No banco de dados, também são configurados usuários específicos para a aplicação e para consultas somente de leitura.

## 🎓 Objetivo acadêmico

Além de oferecer funcionalidades de gerenciamento, o Academia+ demonstra na prática a utilização de recursos de um Sistema Gerenciador de Banco de Dados Relacional.

O projeto busca integrar os conceitos estudados em sala de aula com uma aplicação funcional, permitindo observar como o banco de dados participa das operações, validações, transações e controles de segurança do sistema.

## 👥 Equipe de desenvolvimento

Projeto desenvolvido em grupo como atividade acadêmica da disciplina de Banco de Dados.

## 📌 Status do projeto

Projeto acadêmico desenvolvido para fins educacionais e demonstração prática de integração entre aplicação web e banco de dados MySQL.

---

**Academia+ — Tecnologia e organização para a gestão de academias.**
