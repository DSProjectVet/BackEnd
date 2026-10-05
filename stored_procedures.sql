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