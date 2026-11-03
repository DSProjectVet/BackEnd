select * from Funcionarios


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
    SET XACT_ABORT ON;

    SET @Nome = NULLIF(LTRIM(RTRIM(@Nome)), '');
    SET @Login = NULLIF(LTRIM(RTRIM(@Login)), '');
    SET @CRMV = NULLIF(LTRIM(RTRIM(@CRMV)), '');

    IF @Nome IS NULL
        THROW 50001, 'Informe o nome.', 1;

    IF @Login IS NULL
        THROW 50002, 'Informe o login.', 1;

    IF NULLIF(LTRIM(RTRIM(@SenhaHash)), '') IS NULL
        THROW 50003, 'SenhaHash obrigatoria.', 1;

    IF @NivelAcesso IS NULL
       OR @NivelAcesso NOT IN ('1', '2', '3')
        THROW 50004, 'Nivel de acesso invalido.', 1;

    IF @Telefone IS NULL
       OR LEN(@Telefone) NOT IN (10, 11)
       OR @Telefone LIKE '%[^0-9]%'
        THROW 50005, 'Telefone invalido.', 1;

    IF @Funcionarios_TIPO IS NULL
       OR LTRIM(RTRIM(@Funcionarios_TIPO)) = ''
        THROW 50006, 'Tipo de funcionario obrigatorio.', 1;

    -- Veterinarios precisam de CRMV.
    IF @NivelAcesso = '3' AND @CRMV IS NULL
        THROW 50007, 'CRMV obrigatorio para veterinario.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Funcionarios WITH (UPDLOCK, HOLDLOCK)
            WHERE Login = @Login
        )
            THROW 50008, 'Este login ja existe.', 1;

        IF @CRMV IS NOT NULL
           AND EXISTS
           (
               SELECT 1
               FROM dbo.Funcionarios WITH (UPDLOCK, HOLDLOCK)
               WHERE CRMV = @CRMV
           )
            THROW 50009, 'Este CRMV ja existe.', 1;

        INSERT INTO dbo.Funcionarios
        (
            Nome,
            Login,
            SenhaHash,
            NivelAcesso,
            Telefone,
            CRMV,
            Funcionarios_TIPO
        )
        VALUES
        (
            @Nome,
            @Login,
            @SenhaHash,
            @NivelAcesso,
            @Telefone,
            @CRMV,
            @Funcionarios_TIPO
        );

        DECLARE @NovoId INT =
            CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        SELECT @NovoId AS ID_Funcionario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


SELECT
    @@SERVERNAME AS Servidor,
    DB_NAME() AS BancoAtual;

SELECT
    ID_Funcionario,
    Nome,
    Login,
    NivelAcesso,
    Telefone,
    CRMV,
    Funcionarios_TIPO
FROM dbo.Funcionarios
ORDER BY ID_Funcionario DESC;


ALTER TABLE dbo.Funcionarios
ALTER COLUMN CRMV VARCHAR(10) NULL;


select * from dbo.Movimentacao_Financeira



-- Executar no banco ClinicaVeterinaria.
-- Faça backup antes de alterar a estrutura.

IF COL_LENGTH(
    'dbo.Movimentacao_Financeira', 'Origem'
) IS NULL
BEGIN
    ALTER TABLE dbo.Movimentacao_Financeira
    ADD Origem VARCHAR(20) NULL;
END;
GO

IF COL_LENGTH(
    'dbo.Movimentacao_Financeira', 'IdOrigem'
) IS NULL
BEGIN
    ALTER TABLE dbo.Movimentacao_Financeira
    ADD IdOrigem INT NULL;
END;
GO

-- Evita repetir uma movimentação automática.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id =
        OBJECT_ID('dbo.Movimentacao_Financeira')
      AND name = 'UX_MovFin_Origem'
)
BEGIN
    CREATE UNIQUE INDEX UX_MovFin_Origem
    ON dbo.Movimentacao_Financeira
    (
        fk_Consultas_ID_Consulta,
        Origem,
        IdOrigem
    )
    WHERE Origem IS NOT NULL
      AND IdOrigem IS NOT NULL;
END;
GO





CREATE OR ALTER PROCEDURE dbo.sp_SincronizarFinanceiroConsulta
    @Consulta INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Consultas
            WHERE ID_Consulta = @Consulta
        )
            THROW 50100, 'Consulta nao encontrada.', 1;

        DECLARE @Esperados TABLE
        (
            Origem VARCHAR(20) NOT NULL,
            IdOrigem INT NOT NULL,
            Tipo CHAR(1) NOT NULL,
            Valor DECIMAL(18,2) NOT NULL,
            Descricao NVARCHAR(250) NOT NULL,
            PRIMARY KEY (Origem, IdOrigem)
        );

        -- ======================================
        -- ENTRADAS: SERVICOS
        -- ======================================

        INSERT INTO @Esperados
        (
            Origem, IdOrigem, Tipo, Valor, Descricao
        )
        SELECT
            'SERVICO',
            cs.fk_Servicos_ID_Servico,
            'E',
            SUM(
                CAST(cs.Quantidade AS DECIMAL(18,2))
                * CAST(cs.Preco AS DECIMAL(18,2))
            ),
            CONCAT(
                N'Servico: ',
                MAX(CONVERT(NVARCHAR(100), s.Descricao))
            )
        FROM dbo.Consulta_Servico AS cs
        INNER JOIN dbo.Servicos AS s
            ON s.ID_Servico =
               cs.fk_Servicos_ID_Servico
        WHERE cs.fk_Consultas_ID_Consulta = @Consulta
        GROUP BY cs.fk_Servicos_ID_Servico;

        -- ======================================
        -- SAIDAS: PRODUTOS
        -- ======================================

        INSERT INTO @Esperados
        (
            Origem, IdOrigem, Tipo, Valor, Descricao
        )
        SELECT
            'PRODUTO',
            cp.fk_Produtos_ID_Produto,
            'S',
            SUM(
                CAST(cp.Quantidade AS DECIMAL(18,2))
                * CAST(cp.Preco AS DECIMAL(18,2))
            ),
            CONCAT(
                N'Produto: ',
                MAX(CONVERT(NVARCHAR(100), p.Nome))
            )
        FROM dbo.Consulta_Produto AS cp
        INNER JOIN dbo.Produtos AS p
            ON p.ID_Produto =
               cp.fk_Produtos_ID_Produto
        WHERE cp.fk_Consultas_ID_Consulta = @Consulta
        GROUP BY cp.fk_Produtos_ID_Produto;

        -- ======================================
        -- SAIDAS: MEDICAMENTOS
        -- ======================================

        INSERT INTO @Esperados
        (
            Origem, IdOrigem, Tipo, Valor, Descricao
        )
        SELECT
            'PRESCRICAO',
            pr.ID_Prescricao,
            'S',
            CAST(pr.Quantidade AS DECIMAL(18,2))
                * CAST(m.Preco AS DECIMAL(18,2)),
            CONCAT(
                N'Medicamento: ',
                CONVERT(NVARCHAR(100), m.Nome)
            )
        FROM dbo.Prescricao AS pr
        INNER JOIN dbo.Medicamentos AS m
            ON m.ID_Medicamento =
               pr.fk_Medicamentos_ID_Medicamento
        WHERE pr.fk_Consultas_ID_Consulta = @Consulta;

        -- ======================================
        -- IDENTIFICAR TAMANHO DA DESCRICAO
        -- ======================================

        DECLARE @TamDescricao INT;

        SELECT @TamDescricao =
            CASE
                WHEN c.max_length = -1 THEN 4000
                WHEN t.name IN ('nvarchar', 'nchar')
                    THEN c.max_length / 2
                ELSE c.max_length
            END
        FROM sys.columns AS c
        INNER JOIN sys.types AS t
            ON t.user_type_id = c.user_type_id
        WHERE c.object_id =
            OBJECT_ID('dbo.Movimentacao_Financeira')
          AND c.name = 'Descricao';

        IF @TamDescricao IS NULL
           OR @TamDescricao <= 0
            THROW 50101,
                'Coluna Descricao incompativel.', 1;

        -- ======================================
        -- ATUALIZAR MOVIMENTACOES EXISTENTES
        -- ======================================

        UPDATE mf
        SET
            mf.Tipo = e.Tipo,
            mf.Valor = e.Valor,
            mf.Descricao =
                LEFT(e.Descricao, @TamDescricao)
        FROM dbo.Movimentacao_Financeira AS mf
        INNER JOIN @Esperados AS e
            ON e.Origem = mf.Origem
           AND e.IdOrigem = mf.IdOrigem
        WHERE mf.fk_Consultas_ID_Consulta =
              @Consulta;

        -- ======================================
        -- INSERIR MOVIMENTACOES NOVAS
        -- ======================================

        INSERT INTO dbo.Movimentacao_Financeira
        (
            Tipo,
            DataHora,
            Valor,
            Descricao,
            fk_Consultas_ID_Consulta,
            Origem,
            IdOrigem
        )
        SELECT
            e.Tipo,
            GETDATE(),
            e.Valor,
            LEFT(e.Descricao, @TamDescricao),
            @Consulta,
            e.Origem,
            e.IdOrigem
        FROM @Esperados AS e
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Movimentacao_Financeira AS mf
                WITH (UPDLOCK, HOLDLOCK)
            WHERE mf.fk_Consultas_ID_Consulta =
                  @Consulta
              AND mf.Origem = e.Origem
              AND mf.IdOrigem = e.IdOrigem
        );

        -- ======================================
        -- REMOVER LANCAMENTOS CANCELADOS
        -- ======================================

        DELETE mf
        FROM dbo.Movimentacao_Financeira AS mf
        WHERE mf.fk_Consultas_ID_Consulta =
              @Consulta
          AND mf.Origem IN
          (
              'SERVICO',
              'PRODUTO',
              'PRESCRICAO'
          )
          AND NOT EXISTS
          (
              SELECT 1
              FROM @Esperados AS e
              WHERE e.Origem = mf.Origem
                AND e.IdOrigem = mf.IdOrigem
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO


BEGIN TRY
    BEGIN TRANSACTION;

    -- Substitua pelo nome exato da restrição
    -- UNIQUE que pertence à coluna CRMV.
    ALTER TABLE dbo.Funcionarios
    DROP CONSTRAINT [UQ__Funciona__F2379DCAE3C441B2];

    -- Normaliza CRMVs vazios.
    UPDATE dbo.Funcionarios
    SET CRMV = NULL
    WHERE CRMV IS NOT NULL
      AND LTRIM(RTRIM(CRMV)) = '';

    -- Exige CRMV único somente quando preenchido.
    CREATE UNIQUE INDEX
        UX_Funcionarios_CRMV_Preenchido
    ON dbo.Funcionarios(CRMV)
    WHERE CRMV IS NOT NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
