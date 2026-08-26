/* modelo_logico: */

CREATE TABLE Clientes (
    ID INT PRIMARY KEY,
    Nome NVARCHAR,
    Telefone NUMERIC,
    Endereco NVARCHAR,
    CPF VARCHAR,
    Nivel INT,
    Senha VARCHAR,
    Usuario NVARCHAR
);

CREATE TABLE Animais (
    ID INT PRIMARY KEY,
    Nome NVARCHAR,
    Raca NVARCHAR,
    Sexo CHAR,
    Enfermidade NVARCHAR,
    Descricao NVARCHAR,
    Especie NVARCHAR,
    fk_Clientes_ID INT
);

CREATE TABLE Veterinarios (
    ID INT PRIMARY KEY,
    Nome NVARCHAR,
    Telefone NUMERIC,
    Nivel INT,
    Usuario NVARCHAR,
    Senha VARCHAR
);

CREATE TABLE Consultas (
    Diagnostico NVARCHAR,
    Preco MONEY,
    ID INT PRIMARY KEY,
    DataHora DATETIME,
    fk_Animais_ID INT,
    fk_Veterinarios_ID INT
);

CREATE TABLE Servicos (
    ID INT PRIMARY KEY,
    Tipo INT
);

CREATE TABLE Medicamentos (
    ID INT PRIMARY KEY,
    Nome NVARCHAR,
    Descricao NVARCHAR,
    Quantidade INT,
    Preco MONEY,
    fk_Estoque_Financeiro_ID INT
);

CREATE TABLE Produtos (
    ID INT PRIMARY KEY,
    Nome NVARCHAR,
    Descricao VARCHAR,
    Quantidade INT,
    Preco MONEY,
    fk_Estoque_Financeiro_ID INT
);

CREATE TABLE Fornecedores (
    ID INT PRIMARY KEY,
    Nome NVARCHAR,
    CPF_CNPJ VARCHAR,
    Telefone NUMERIC,
    Descricao NVARCHAR
);

CREATE TABLE Estoque_Financeiro (
    ID INT PRIMARY KEY,
    Entrada MONEY,
    Saida MONEY,
    Saldo MONEY,
    fk_Fornecedores_ID INT
);

CREATE TABLE Servico_Consulta_Realiza (
    Preco_Cobrado MONEY,
    Quantidade INT,
    Observacoes NVARCHAR,
    fk_Consultas_ID INT,
    fk_Servicos_ID INT
);

CREATE TABLE Medicamento_Consulta_Utiliza (
    fk_Medicamentos_ID INT,
    fk_Consultas_ID INT
);
 
ALTER TABLE Animais ADD CONSTRAINT FK_Animais_2
    FOREIGN KEY (fk_Clientes_ID)
    REFERENCES Clientes (ID)
    ON DELETE RESTRICT;
 
ALTER TABLE Consultas ADD CONSTRAINT FK_Consultas_2
    FOREIGN KEY (fk_Animais_ID)
    REFERENCES Animais (ID)
    ON DELETE RESTRICT;
 
ALTER TABLE Consultas ADD CONSTRAINT FK_Consultas_3
    FOREIGN KEY (fk_Veterinarios_ID)
    REFERENCES Veterinarios (ID)
    ON DELETE RESTRICT;
 
ALTER TABLE Medicamentos ADD CONSTRAINT FK_Medicamentos_2
    FOREIGN KEY (fk_Estoque_Financeiro_ID)
    REFERENCES Estoque_Financeiro (ID)
    ON DELETE RESTRICT;
 
ALTER TABLE Produtos ADD CONSTRAINT FK_Produtos_2
    FOREIGN KEY (fk_Estoque_Financeiro_ID)
    REFERENCES Estoque_Financeiro (ID)
    ON DELETE RESTRICT;
 
ALTER TABLE Estoque_Financeiro ADD CONSTRAINT FK_Estoque_Financeiro_2
    FOREIGN KEY (fk_Fornecedores_ID)
    REFERENCES Fornecedores (ID)
    ON DELETE RESTRICT;
 
ALTER TABLE Servico_Consulta_Realiza ADD CONSTRAINT FK_Servico_Consulta_Realiza_1
    FOREIGN KEY (fk_Consultas_ID)
    REFERENCES Consultas (ID);
 
ALTER TABLE Servico_Consulta_Realiza ADD CONSTRAINT FK_Servico_Consulta_Realiza_2
    FOREIGN KEY (fk_Servicos_ID)
    REFERENCES Servicos (ID);
 
ALTER TABLE Medicamento_Consulta_Utiliza ADD CONSTRAINT FK_Medicamento_Consulta_Utiliza_1
    FOREIGN KEY (fk_Medicamentos_ID)
    REFERENCES Medicamentos (ID);
 
ALTER TABLE Medicamento_Consulta_Utiliza ADD CONSTRAINT FK_Medicamento_Consulta_Utiliza_2
    FOREIGN KEY (fk_Consultas_ID)
    REFERENCES Consultas (ID);