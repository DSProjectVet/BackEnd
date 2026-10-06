CREATE OR ALTER PROCEDURE SP_LoginUser
(
	@Usuario NVARCHAR(50),
	@Senha VARCHAR(255)
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ID_Funcionario, Nome, Telefone, NivelAcesso, Funcionarios_TIPO, CRMV FROM dbo.Funcionarios WHERE Login = @Usuario AND 
	SenhaHash = @Senha
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
        SELECT 'Já existe um cliente cadastrado com este CPF.';
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

    SELECT 'Cliente cadastrado com sucesso!';
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

	SELECT 'Cadastro concluído com sucesso';
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

	SELECT 'Registrado com sucesso';
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

CREATE OR ALTER  VIEW dbo.vw_Estoque
AS

SELECT
'PRODUTO' AS Tipo_Item,
p.ID_Produto AS ID_Item,
p.nome AS Nome_Item,
ep.Quantidade,
ep.EstoqueMinimo,
CASE
WHEN ep.Quantidade <= ep.EstoqueMinimo
THEN 'BAIXO'
ELSE 'NORMAL'
END AS Situacao
FROM Estoque_Produto AS ep
INNER JOIN Produtos AS p
ON ep.fk_Produtos_ID_Produto = p.ID_Produto

UNION ALL

SELECT
'MEDICAMENTO' AS Tipo_Item,
m.ID_Medicamento AS ID_Item,
m.Nome as Nome_Item,
em.Quantidade,
em.EstoqueMinimo,
CASE
WHEN em.Quantidade <= em.EstoqueMinimo
THEN 'BAIXO'
ELSE 'NORMAL'
END AS Situacao
FROM Estoque_Medicamento as em
INNER JOIN Medicamentos AS m
ON em.fk_Medicamentos_ID_Medicamento = m.ID_Medicamento;
GO

