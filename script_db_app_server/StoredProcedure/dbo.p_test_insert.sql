USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_test_insert] 

	@ApiKey VarChar(100),
	@EntityName VarChar(100),
	@IdObject INTEGER,
	@IdParent INTEGER,
	@CodeObject Varchar(100),
	@RankObject INTEGER, 
	@NameShort NVarChar(100),
	@NameObject NVarChar(1000),
	@NoteObject NVarChar(4000) = ''

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewObject INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',

	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000),
	@Var NVARCHAR(4000),
	@Quote NVarChar(10) = ''''

BEGIN TRY

	SET @EntityName = 'test_classificator'

	/* Проверка разрешений на добавление данных указанной сущности  */
	------EXEC dbo.p_permission @ApiKey, @EntityName, 'insert'
	/* ********************************************************** */

	SET @TableName = dbo.f_get_table_by_entity(@EntityName)

	IF LEN(@TableName) > 0
	BEGIN

		SET @IdObject = ISNULL(@IdObject,0)
		SET @CodeObject = ISNULL(@CodeObject,'')
		SET @RankObject = ISNULL(@RankObject,0)
		SET @NameShort  = ISNULL(@NameShort,'')
		SET @NameObject = ISNULL(@NameObject,'')
		SET @NoteObject = ISNULL(@NoteObject,'')

		IF EXISTS(SELECT * FROM A.ENTITY_COLUMN WHERE (ColumnRank < 0) AND ColumnName='IdParent' AND CodeObject=@EntityName) 
			SET @IdParent = 0

		SET @Sql = 
		'
		DECLARE @Inserted TABLE ( IdNewCreatedObject INTEGER )
		DECLARE @Table1 AS dbo.TYPE_CLASSIFICATOR 
		INSERT INTO @Table1 		
		VALUES (@IdObject, @IdParent, @CodeObject, @RankObject, @NameShort, @NameObject, @NoteObject)

		IF 
			EXISTS( SELECT * FROM ' + @TableName + ' WHERE IdObject = (SELECT IdObject FROM @Table1 ) )
			OR	
			( ( SELECT IsNull(MAX(IdObject),0) FROM ' + @TableName + '  ) = 0 )
			
			UPDATE @Table1 SET IdObject = (SELECT 1+MAX(IdObject) FROM ' + @TableName + ' ) 
		
		UPDATE @Table1 SET CodeObject = IdObject WHERE LEN(CodeObject) < 1

		IF EXISTS(SELECT * FROM ' + @TableName + ' WHERE CodeObject IN (SELECT CodeObject FROM @Table1))
		UPDATE @Table1 SET CodeObject = ''' + CAST(@IdObject as VARCHAR) + '-' + RIGHT(NEWID(),8)  + '''

		INSERT INTO ' + @TableName + ' 
			OUTPUT INSERTED.IdObject INTO @Inserted ( IdNewCreatedObject )
			SELECT * FROM @Table1
				
		SELECT @retvalOUT = MAX(IdNewCreatedObject) FROM @Inserted'

		SET @Var = N'@IdObject INT, @IdParent INT, @CodeObject Varchar(100), @RankObject INT, @NameShort NVarChar(100), @NameObject NVarChar(1000), @NoteObject NVarChar(4000), @retvalOUT int OUTPUT'
		
		EXEC sp_executesql 	
							@Sql, 
							@Var,

							@IdObject,
							@IdParent,
							@CodeObject,
							@RankObject,
							@NameShort,
							@NameObject,
							@NoteObject,

							@retvalOUT = @IdCreatedNewObject OUTPUT

	END	ELSE BEGIN

		SET @TableName = 'Не удалось определить тип классификатора по значению = ' + @EntityName;
		EXEC dbo.p_error @TableName, 102004

	END

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_test_insert] error: Entity='+@EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR) + ';NameObject='+@NameObject 
	SET @RankObject = [dbo].[f_get_id_by_apikey](@ApiKey)
	
	/*
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@RankObject, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote 
	*/

END CATCH

SELECT @ReturnCode as ReturnCode, @IdCreatedNewObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode 

END

GO

