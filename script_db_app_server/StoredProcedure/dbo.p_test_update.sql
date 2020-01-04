USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_test_update] 

	@ApiKey VarChar(100),
	@IdObject INTEGER, 
	@EntityName Varchar(100),
	@ColumnName Varchar(100),
	@CellValue NVarChar(4000)

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewObject INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',
	
	@OuterX INTEGER,
	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000),
	@Var NVARCHAR(4000),
	@Quote NVarChar(10) = ''

BEGIN TRY 
	
	SET @EntityName = 'test_classificator'
	/* Проверка разрешений на изменение данных указанной сущности  */
	--EXEC dbo.p_permission @ApiKey, @EntityName, 'update' 
	/* ********************************************************** */

	SET @TableName = dbo.f_get_table_by_entity(@EntityName)

	IF LEN(@TableName) > 0
	BEGIN

		IF (@ColumnName NOT IN ('IdObject', 'RankObject', 'IdParent') ) SET @Quote = '''';

		IF 	(@ColumnName='IdObject') 
		BEGIN
			
			IF @IdObject=0 EXEC dbo.p_error 'Запрещено изменять идентификатор встроенного объекта', 102005
			-----------------------------------------------------------------------------------------------------------------
			SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE IdObject=' + @CellValue
			SET @Var = N'@OuterX INT OUTPUT'
			EXEC sp_executesql 	@Sql, @Var, @OuterX = @OuterX OUTPUT
			IF (@OuterX > 0) EXEC dbo.p_error 'Новое значение идентификатора уже используется', 102006
			-----------------------------------------------------------------------------------------------------------------
			SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE IdParent=' + CAST(@IdObject as VARCHAR)
			
			--EXEC dbo.p_event 0,0,'test [p_classificator_update]', @Sql

			SET @Var = N'@OuterX INT OUTPUT'
			EXEC sp_executesql 	@Sql, @Var, @OuterX = @OuterX OUTPUT
			IF (@OuterX > 0) EXEC dbo.p_error 'Нельзя менять идентификатор, если на него ссылаются другие объекты', 102007
			-----------------------------------------------------------------------------------------------------------------
		
		END

		IF @ColumnName='CodeObject'
		BEGIN
			-----------------------------------------------------------------------------------------------------------------
			SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE CodeObject=' + @Quote + @CellValue + @Quote
			SET @Var = N'@OuterX INT OUTPUT'
			EXEC sp_executesql 	@Sql, @Var, @OuterX = @OuterX OUTPUT
			IF (@OuterX > 0) EXEC dbo.p_error 'Новое значение кода уже используется', 102008
			-----------------------------------------------------------------------------------------------------------------
		END

		IF EXISTS(SELECT * FROM A.ENTITY_LOCKED WHERE CodeEntity=@EntityName and IdObject=@IdObject)
			EXEC dbo.p_error 'Запрещено изменять встроенные объекты информационной системы', 102009

		/**********************************************************************************************************************************/
		----SET @Sql = 'UPDATE ' + @TableName +	' SET [' + @ColumnName + '] = ' + @Quote + @CellValue + @Quote + ' WHERE (IdObject = @IdObject)'
		----EXEC sp_executesql @Sql, N'@IdObject INT', @IdObject --- this one has vulnerability SQL INJECTION ATTACK to @CellValue variable !!!!!!


		SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE IdObject=@IdObject'
		SET @Var = N'@IdObject INT, @OuterX INT OUTPUT'
		EXEC sp_executesql 	@Sql, @Var, @IdObject, @OuterX = @OuterX OUTPUT
		IF (@OuterX = 0) EXEC dbo.p_error 'Объект не найден.', 100008


		SET @Sql = 'UPDATE ' + @TableName +	' SET [' + @ColumnName + '] = @CellValue WHERE (IdObject = @IdObject)'
		EXEC sp_executesql @Sql, N'@IdObject INT, @CellValue NVARCHAR(4000)', @IdObject, @CellValue


		SET @Sql = 'UPDATE ' + @TableName +	' SET IdParent = IdParent+1 WHERE (IdObject = @IdObject)'
		EXEC sp_executesql @Sql, N'@IdObject INT', @IdObject


		/**********************************************************************************************************************************/
	END	ELSE BEGIN

		SET @TableName = 'Не удалось определить тип классификатора по значению = ' + @EntityName;
		EXEC dbo.p_error @TableName, 102004

	END

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @OuterX = [dbo].[f_get_id_by_apikey](@ApiKey)
	
	SET @ReturnNote = 'SP [dbo].[p_test_update] error: Entity='+@EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR) + ';ColumnName=' + @ColumnName + ';CellValue=' + @CellValue 
		
	/* EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@OuterX, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote */

END CATCH

SELECT @ReturnCode as ReturnCode, @IdCreatedNewObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode 

END



GO

