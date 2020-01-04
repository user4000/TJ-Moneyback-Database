USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_test_select] 

	@ApiKey Varchar(100), 
	@EntityName Varchar(100),
	@IdObject Integer = 0

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0, 
	@N INTEGER = 0,
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000)

BEGIN TRY

	SET @EntityName = 'test_classificator'

	/* ********************************************************* */
	--EXEC dbo.p_permission @ApiKey, @EntityName, 'select'
	/* ********************************************************* */
	
	SET @TableName = dbo.f_get_table_by_entity(@EntityName)

	IF LEN(@TableName) > 0
	BEGIN

		EXEC @N = dbo.p_random 1, 20

		SET @Sql = 'SELECT TOP ' + CAST(@N as Varchar) + ' IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject ' +
					'FROM ' + @TableName + ' ' +
					'WHERE (IdObject = @IdObject) OR (@IdObject < 1) ' +
					'ORDER BY NEWID() ----, RankObject, IdParent, IdObject'
		EXEC sp_executesql @Sql, N'@IdObject INT', @IdObject
	RETURN 0 END
	

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_test_select] error: Entity=' + @EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR)
	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
	
	--SET @Sql = @ReturnNote + ';SQL=' + @Sql

	/* EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUser, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@Sql */

	SELECT 
		-1 as IdObject, 
		@ReturnCode as IdParent,
		'' as CodeObject,
		-1 as RankObject,
		'' as NameShort,
		'' as NameObject,
		ERROR_MESSAGE() as NoteObject

END CATCH

RETURN @ReturnCode

END



GO

