USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_test_delete] 

	@ApiKey VarChar(100),
	@EntityName VarChar(100),
	@IdObject INTEGER = 0

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewObject INTEGER = 0,
	@ReturnMessage Varchar(4000) = 'Объект удалён.',
	@ReturnNote Varchar(4000) = '',

	@OuterX INTEGER,
	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000),
	@Var NVARCHAR(4000),
	@Quote NVarChar(10) = ''''

BEGIN TRY

	SET @EntityName = 'test_classificator'

	/* Проверка разрешений на удаление данных указанной сущности  */
	--EXEC dbo.p_permission @ApiKey, @EntityName, 'delete' 
	/* ************************************************************ */

	SET @TableName = dbo.f_get_table_by_entity(@EntityName)

	IF LEN(@TableName) > 0
	BEGIN
		---------------------------------------------------------------------------------------------------------------
		IF @IdObject=0 EXEC dbo.p_error 'Запрещено удалять объект с идентификатором = 0', 102001
		---------------------------------------------------------------------------------------------------------------
		IF EXISTS(SELECT * FROM A.ENTITY_LOCKED WHERE CodeEntity=@EntityName and IdObject=@IdObject)
			EXEC dbo.p_error 'Запрещено удалять встроенные объекты информационной системы', 102002
		---------------------------------------------------------------------------------------------------------------
		SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE IdParent=@IdObject'
		SET @Var = N'@IdObject INT, @OuterX INT OUTPUT'
		EXEC sp_executesql 	@Sql, @Var, @IdObject, @OuterX = @OuterX OUTPUT
		IF (@OuterX > 0) EXEC dbo.p_error 'Запрещено удалять объект, содержащий входящие в него объекты', 102003
		---------------------------------------------------------------------------------------------------------------
		
		SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE IdObject=@IdObject'
		SET @Var = N'@IdObject INT, @OuterX INT OUTPUT'
		EXEC sp_executesql 	@Sql, @Var, @IdObject, @OuterX = @OuterX OUTPUT
		IF (@OuterX = 0) EXEC dbo.p_error 'Объект не найден.', 100008



		---------------------------------------------------------------------------------------------------------------
		SET @Sql = 'DELETE FROM ' + @TableName + ' WHERE IdObject=@IdObject'
		SET @Var = N'@IdObject INT'
		EXEC sp_executesql 	@Sql, @Var, @IdObject
		---------------------------------------------------------------------------------------------------------------
	END	ELSE BEGIN

		SET @TableName = 'Не удалось определить тип классификатора по значению = ' + @EntityName;
		EXEC dbo.p_error @TableName, 102004

	END

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_test_delete] error: Entity='+@EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR)
	--EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=0, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode 

END




GO

