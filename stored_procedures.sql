
USE ClinicaVeterinaria;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CadastrarFuncionario
    @Nome NVARCHAR(50),
    @Login NVARCHAR(50),
    @SenhaHash NVARCHAR(100),
    @NivelAcesso CHAR(1),
    @Telefone VARCHAR(11),
    @CRMV VARCHAR(10),
    @Funcionarios_TIPO CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validar campos obrigatórios
    IF NULLIF(LTRIM(RTRIM(@Login)), '') IS NULL
        SELECT 'O login e obrigatorio.' AS ERROR;

    IF NULLIF(LTRIM(RTRIM(@SenhaHash)), '') IS NULL
        SELECT 'O hash da senha e obrigatorio.' AS ERROR;

    IF NULLIF(LTRIM(RTRIM(@NivelAcesso)), '') IS NULL
        SELECT 'O nivel de acesso e obrigatorio.' AS ERROR;

    IF NULLIF(LTRIM(RTRIM(@Telefone)), '') IS NULL
        SELECT 'O telefone e obrigatorio.' AS ERROR;

    IF NULLIF(LTRIM(RTRIM(@CRMV)), '') IS NULL
        SELECT 'O CRMV e obrigatorio.' AS ERROR;

    IF NULLIF(LTRIM(RTRIM(@Funcionarios_TIPO)), '') IS NULL
        SELECT 'O tipo de funcionario e obrigatorio.' AS ERROR;

    -- 2. Verificar se o login ja existe
    IF EXISTS (
        SELECT 1
        FROM dbo.Funcionarios
        WHERE Login = @Login
    )
        SELECT 'Este login ja esta cadastrado.' AS ERROR;

    -- 3. Verificar se o CRMV ja existe
    IF EXISTS (
        SELECT 1
        FROM dbo.Funcionarios
        WHERE CRMV = @CRMV
    )
        SELECT 'Este CRMV ja esta cadastrado.' AS ERROR;

    -- 4. Cadastrar funcionario
    INSERT INTO dbo.Funcionarios (
        Login,
        SenhaHash,
        Nome,
        NivelAcesso,
        Telefone,
        CRMV,
        Funcionarios_TIPO
    )
    VALUES (
        @Login,
        @SenhaHash,
        @Nome,
        @NivelAcesso,
        @Telefone,
        @CRMV,
        @Funcionarios_TIPO
    );

    -- 5. Retornar o ID gerado
    SELECT
        'Funcionário cadastrado com sucesso!' AS SUCCESS;
END;
GO

select * from dbo.Funcionarios

CREATE OR ALTER PROCEDURE sp_LoginUser
(
	@Usuario NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ID_Funcionario, Login, Nome, Telefone, NivelAcesso, 
        Funcionarios_TIPO, CRMV, SenhaHash FROM dbo.Funcionarios WHERE Login = @Usuario
END;
GO

CREATE OR ALTER PROCEDURE sp_CadastrarCliente
    @Nome NVARCHAR(50),
    @Telefone VARCHAR(11),
    @CPF VARCHAR(11),
    @Endereco NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.Clientes
        WHERE CPF = @CPF
    )
    BEGIN
        SELECT 'Já existe um cliente cadastrado com este CPF.' AS ERROR;
        RETURN;
    END;

    INSERT INTO dbo.Clientes (
        Nome,
        Telefone,
        CPF,
        Endereco
    )
    VALUES (
        @Nome,
        @Telefone,
        @CPF,
        @Endereco
    );

    SELECT 'Cliente cadastrado com sucesso!' AS SUCCESS;
END;
GO

CREATE or ALTER PROCEDURE
dbo.sp_RegistrarConsulta
	@Diagnostico NVARCHAR(60),
	@DataHora DATETIME,
	@Observacoes NVARCHAR(60),
	@ID_Animal INT,
	@ID_Funcionario INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Consultas (
	Diagnostico,
	DataHora,
	Observacoes,
	fk_Animais_ID_Animal,
	fk_Funcionarios_ID_Funcionario
	)
	VALUES (
	@Diagnostico,
	@DataHora,
	@Observacoes,
	@ID_Animal,
	@ID_Funcionario
	);

	SELECT 'Cadastro concluído com sucesso' AS SUCCESS;
	END;
	GO
	

	CREATE OR ALTER PROCEDURE
	dbo.sp_RegistrarPrescicao
	@Quantidade NUMERIC(2,0),
	@Dosagem VARCHAR(10),
	@Frequencia VARCHAR(20),
	@Duracao VARCHAR(20),
	@Observacoes NVARCHAR(60),
	@ID_Medicamento INT,
	@ID_Consulta INT
	AS
	BEGIN
	SET NOCOUNT ON;

	INSERT INTO Prescricao (
	Quantidade,
	Dosagem,
	Frequencia,
	Duracao,
	Observacoes,
	fk_Medicamentos_ID_Medicamento,
	fk_Consultas_ID_Consulta
	)
	VALUES (
	@Quantidade,
	@Dosagem,
	@Frequencia,
	@Duracao,
	@Observacoes,
	@ID_Medicamento,
	@ID_Consulta
	);

	SELECT 'Registrado com sucesso' AS SUCCESS;
	END;
	GO

	CREATE OR ALTER VIEW dbo.w_ConsultasDetalhadas
	AS
	SELECT
	c.ID_Consulta,
	c.DataHora,

	a.ID_Animal,
	a.Nome AS Nome_Animal,
	a.Especie,
	a.Raca,

	cl.ID_Cliente,
	cl.Nome AS Nome_Cliente,
	cl.Telefone AS Telefone_Cliente,

	f.ID_Funcionario,
	f.login AS Funcionario,
	
	c.Diagnostico,
	c.Observacoes

	FROM Consultas AS c
	INNER JOIN Animais AS a
	ON c.fk_Animais_ID_Animal = a.ID_Animal
	INNER JOIN Clientes as cl
	ON a.fk_Clientes_ID_Cliente = cl.ID_Cliente
	INNER JOIN Funcionarios AS f
	ON c.fk_Funcionarios_ID_Funcionario = f.ID_Funcionario;
	GO

CREATE OR ALTER VIEW dbo.vw_Estoque
AS

SELECT 'PRODUTO' AS Tipo_Item, p.ID_Produto AS ID_Item, p.nome AS Nome_Item,
    ep.Quantidade, ep.EstoqueMinimo,
CASE
    WHEN ep.Quantidade <= ep.EstoqueMinimo
        THEN 'BAIXO'
    ELSE 'NORMAL'
END AS Situacao
FROM Estoque_Produto AS ep
    INNER JOIN Produtos AS p
    ON ep.fk_Produtos_ID_Produto = p.ID_Produto

UNION ALL

SELECT 'MEDICAMENTO' AS Tipo_Item, m.ID_Medicamento AS ID_Item,
    m.Nome as Nome_Item, em.Quantidade, em.EstoqueMinimo,
CASE
    WHEN em.Quantidade <= em.EstoqueMinimo
        THEN 'BAIXO'
    ELSE 'NORMAL'
END AS Situacao
FROM Estoque_Medicamento as em
    INNER JOIN Medicamentos AS m
    ON em.fk_Medicamentos_ID_Medicamento = m.ID_Medicamento;
GO

CREATE OR ALTER TRIGGER dbo.trg_Consulta_Produto_Estoque
ON dbo.Consulta_Produto
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ajustes TABLE (
        ID_Produto INT PRIMARY KEY,
        Delta INT
    );

    INSERT INTO @Ajustes (ID_Produto, Delta)
    SELECT
        ID_Produto,
        SUM(Delta)
    FROM
    (
        SELECT
            fk_Produtos_ID_Produto AS ID_Produto,
            -CAST(Quantidade AS INT) AS Delta
        FROM inserted

        UNION ALL

        SELECT
            fk_Produtos_ID_Produto AS ID_Produto,
            CAST(Quantidade AS INT) AS Delta
        FROM deleted
    ) AS Movimentos
    GROUP BY ID_Produto;

    IF EXISTS (
        SELECT 1
        FROM @Ajustes AS a
        LEFT JOIN Estoque_Produto AS ep
            ON ep.fk_Produtos_ID_Produto = a.ID_Produto
        WHERE ep.fk_Produtos_ID_Produto IS NULL
          AND a.Delta < 0
    )
    BEGIN
        SELECT 'O produto não possui registro de estoque.' AS ERROR;
    END;

    UPDATE ep
    SET ep.Quantidade = ep.Quantidade + a.Delta
    FROM Estoque_Produto AS ep
    INNER JOIN @Ajustes AS a
        ON ep.fk_Produtos_ID_Produto = a.ID_Produto;

    IF EXISTS (
        SELECT 1
        FROM Estoque_Produto AS ep
        INNER JOIN @Ajustes AS a
            ON ep.fk_Produtos_ID_Produto = a.ID_Produto
        WHERE ep.Quantidade < 0
    )
    BEGIN
        SELECT 'Quantidade insuficiente em estoque.' AS ERROR;
    END;
END;
GO