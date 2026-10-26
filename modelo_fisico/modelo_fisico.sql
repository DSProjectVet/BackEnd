/* modelo_logico: */
CREATE DATABASE ClinicaVeterinaria;
USE ClinicaVeterinaria;

DROP DATABASE ClinicaVeterinaria;

CREATE TABLE Funcionarios (
    ID_Funcionario INT IDENTITY(1,1) PRIMARY KEY,
    Login NVARCHAR(50) NOT NULL UNIQUE,
    SenhaHash NVARCHAR(100) NOT NULL,
    Nome NVARCHAR(50) NOT NULL,
    NivelAcesso CHAR(1) NOT NULL,
    Telefone VARCHAR(11) NOT NULL,
    CRMV VARCHAR(10) NOT NULL UNIQUE,
    Funcionarios_TIPO CHAR(1) NOT NULL
);

DROP TABLE dbo.Funcionarios

CREATE TABLE Clientes (
    ID_Cliente INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(50) NOT NULL,
    Telefone VARCHAR(11) NOT NULL,
    CPF VARCHAR(11) NOT NULL UNIQUE,
    Endereco NVARCHAR(50) NOT NULL
);

DROP TABLE dbo.Clientes

CREATE TABLE Animais (
    ID_Animal INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(50) NOT NULL,
    Raca NVARCHAR(50) NOT NULL,
    Sexo CHAR(1) NOT NULL CHECK (Sexo IN ('M', 'F')),
    Descricao NVARCHAR(60) NOT NULL,
    Especie VARCHAR(30) NOT NULL,
    Data_Nascimento DATE NOT NULL,

    fk_Clientes_ID_Cliente INT NOT NULL 
    FOREIGN KEY REFERENCES dbo.Clientes (ID_Cliente) ON DELETE NO ACTION
);

DROP TABLE dbo.Animais

CREATE TABLE Consultas (
    ID_Consulta INT IDENTITY(1,1) PRIMARY KEY,

    Diagnostico NVARCHAR(60) NOT NULL,
    DataHora DATETIME NOT NULL,
    Observacoes NVARCHAR(60) NOT NULL,

    fk_Animais_ID_Animal INT NOT NULL,
    fk_Funcionarios_ID_Funcionario INT NOT NULL,

    CONSTRAINT FK_Consultas_Animal
        FOREIGN KEY (fk_Animais_ID_Animal)
        REFERENCES dbo.Animais(ID_Animal)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Consultas_Funcionario
        FOREIGN KEY (fk_Funcionarios_ID_Funcionario)
        REFERENCES dbo.Funcionarios(ID_Funcionario)
        ON DELETE NO ACTION
);

DROP TABLE dbo.Consultas

CREATE TABLE Servicos (
    ID_Servico INT IDENTITY(1,1) PRIMARY KEY,
    Tipo CHAR(1) NOT NULL,
    Descricao NVARCHAR(60) NOT NULL,
    Preco MONEY NOT NULL
);

DROP TABLE dbo.Servicos

CREATE TABLE Medicamentos (
    ID_Medicamento INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(50) NOT NULL,
    Descricao NVARCHAR(60) NOT NULL,
    Preco MONEY NOT NULL
);

DROP TABLE dbo.Medicamentos

CREATE TABLE Produtos (
    ID_Produto INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(50) NOT NULL,
    Preco MONEY NOT NULL,
    Descricao NVARCHAR(60) NOT NULL
);

DROP TABLE dbo.Produtos

CREATE TABLE Fornecedores (
    ID_Fornecedor INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(50) NOT NULL,
    CPF_CNPJ VARCHAR(14) NOT NULL UNIQUE,
    Telefone VARCHAR(11) NOT NULL,
    Email NVARCHAR(50) NOT NULL,
    Descricao NVARCHAR(60) NOT NULL
);

DROP TABLE dbo.Fornecedores

CREATE TABLE Movimentacao_Financeira (
    ID_Movimentacao INT IDENTITY(1,1) PRIMARY KEY,

    Tipo CHAR(1) NOT NULL CHECK (Tipo IN ('E', 'S')),
    DataHora DATETIME NOT NULL,
    Valor MONEY NOT NULL,
    Descricao NVARCHAR(60) NOT NULL,

    fk_Consultas_ID_Consulta INT NOT NULL,

    CONSTRAINT FK_Movimentacao_Financeira_Consulta
        FOREIGN KEY (fk_Consultas_ID_Consulta)
        REFERENCES dbo.Consultas(ID_Consulta)
        ON DELETE NO ACTION
);

DROP TABLE dbo.Movimentacao_Financeira

CREATE TABLE Prescricao (
    ID_Prescricao INT IDENTITY(1,1) PRIMARY KEY,
    Quantidade NUMERIC(2,0) NOT NULL,
    Dosagem VARCHAR(10) NOT NULL,
    Frequencia VARCHAR(20) NOT NULL,
    Duracao VARCHAR(20) NOT NULL,
    Observacoes NVARCHAR(60) NOT NULL,

    fk_Medicamentos_ID_Medicamento INT NOT NULL,
    fk_Consultas_ID_Consulta INT NOT NULL,

    CONSTRAINT FK_Prescricao_Medicamento
    FOREIGN KEY (fk_Medicamentos_ID_Medicamento) 
    REFERENCES dbo.Medicamentos (ID_Medicamento),

    CONSTRAINT FK_Prescricao_Consulta
    FOREIGN KEY (fk_Consultas_ID_Consulta) 
    REFERENCES dbo.Consultas (ID_Consulta)
);

DROP TABLE dbo.Prescricao

CREATE TABLE Consulta_Servico (
    fk_Servicos_ID_Servico INT NOT NULL,
    fk_Consultas_ID_Consulta INT NOT NULL,

    CONSTRAINT PK_Consulta_Servico
        PRIMARY KEY (
            fk_Servicos_ID_Servico,
            fk_Consultas_ID_Consulta
        ),

    Quantidade NUMERIC(2,0) NOT NULL,
    Preco MONEY NOT NULL,

    CONSTRAINT FK_Consulta_Servico_Servico
        FOREIGN KEY (fk_Servicos_ID_Servico)
        REFERENCES dbo.Servicos(ID_Servico)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Consulta_Servico_Consulta
        FOREIGN KEY (fk_Consultas_ID_Consulta)
        REFERENCES dbo.Consultas(ID_Consulta)
        ON DELETE NO ACTION
);

DROP TABLE dbo.Consulta_Servico

CREATE TABLE Fornecedor_Produto (
    fk_Produtos_ID_Produto INT NOT NULL,
    fk_Fornecedores_ID_Fornecedor INT NOT NULL,

    CONSTRAINT PK_Fornecedor_Produto
    PRIMARY KEY (fk_Produtos_ID_Produto, fk_Fornecedores_ID_Fornecedor),
    PrecoCompra MONEY NOT NULL,

     CONSTRAINT FK_Fornecedor_Produto_Produto
     FOREIGN KEY (fk_Produtos_ID_Produto) 
     REFERENCES dbo.Produtos (ID_Produto),

     CONSTRAINT FK_Fornecedor_Produto_Fornecedor
     FOREIGN KEY (fk_Fornecedores_ID_Fornecedor) 
     REFERENCES dbo.Fornecedores (ID_Fornecedor)
);

DROP TABLE dbo.Fornecedor_Produto

CREATE TABLE Fornecedor_Medicamento (
    fk_Medicamentos_ID_Medicamento INT NOT NULL,
    fk_Fornecedores_ID_Fornecedor INT NOT NULL,

    CONSTRAINT PK_Fornecedor_Medicamento
    PRIMARY KEY (fk_Medicamentos_ID_Medicamento, fk_Fornecedores_ID_Fornecedor),
    PrecoCompra MONEY NOT NULL,

    CONSTRAINT FK_Fornecedor_Medicamento_Produto
     FOREIGN KEY (fk_Medicamentos_ID_Medicamento) 
     REFERENCES dbo.Medicamentos (ID_Medicamento),

     CONSTRAINT FK_Fornecedor_Medicamento_Fornecedor
     FOREIGN KEY (fk_Fornecedores_ID_Fornecedor) 
     REFERENCES dbo.Fornecedores (ID_Fornecedor)
);

DROP TABLE dbo.Fornecedor_Medicamento

CREATE TABLE Estoque_Produto (
    fk_Produtos_ID_Produto INT PRIMARY KEY
    FOREIGN KEY REFERENCES dbo.Produtos(ID_Produto)
    ON DELETE NO ACTION,

    Quantidade NUMERIC(4,0) NOT NULL,
    EstoqueMinimo NUMERIC(3,0) NOT NULL
);

DROP TABLE dbo.Estoque_Produto

CREATE TABLE Estoque_Medicamento (
    fk_Medicamentos_ID_Medicamento INT PRIMARY KEY
    FOREIGN KEY REFERENCES dbo.Medicamentos(ID_Medicamento)
    ON DELETE NO ACTION,

    Quantidade NUMERIC(4,0) NOT NULL,
    EstoqueMinimo NUMERIC(3,0) NOT NULL
);

DROP TABLE dbo.Estoque_Medicamento

CREATE TABLE Consulta_Produto (
    fk_Consultas_ID_Consulta INT NOT NULL,
    fk_Produtos_ID_Produto INT NOT NULL,

    CONSTRAINT PK_Consulta_Produto
    PRIMARY KEY (fk_Consultas_ID_Consulta, fk_Produtos_ID_Produto),

    Quantidade NUMERIC(2,0) NOT NULL,
    Preco MONEY NOT NULL,

    CONSTRAINT FK_Consulta_Produto_Consulta
     FOREIGN KEY (fk_Consultas_ID_Consulta) 
     REFERENCES dbo.Consultas (ID_Consulta),

     CONSTRAINT FK_Consulta_Produto_Produto
     FOREIGN KEY (fk_Produtos_ID_Produto) 
     REFERENCES dbo.Produtos (ID_Produto)
);

DROP TABLE dbo.Consulta_Produto