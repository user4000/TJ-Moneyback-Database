USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_select] 

	@ApiKey Varchar(100), 
	@IdObject Integer = 0

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@TableName VARCHAR(100),
	@EntityName VARCHAR(100),
	@Sql NVARCHAR(4000)

BEGIN TRY

/* ---------------------------------------------------------------------------------------- */
	
	/* ********************************************************* */
	/* Проверка разрешений на выборку данных указанной сущности  */
	/* ********************************************************* */
	SET @EntityName = 'user'
	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
	IF dbo.f_is_member_of(@IdUser,'security')=0 EXEC dbo.p_permission @ApiKey, @EntityName, 'select'
	/* ********************************************************* */
	
	SELECT IdUser, UserLogin, SurName, FirstName, UserPatronymic, IdStatus, IdUnit, IdPosition, UserNote, '' as PasswordHash, '' as SaltHash
		FROM [T].[USER] A
		INNER JOIN A.UNIT B ON A.IdUnit=B.IdObject
		INNER JOIN A.POSITION C ON A.IdPosition = C.IdObject		 
			WHERE (IdUser = @IdObject) OR (@IdObject < 1)
				ORDER BY B.RankObject, C.RankObject, A.SurName, A.FirstName, A.UserPatronymic, A.UserLogin
	
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_user_select] error: Entity=' + @EntityName + ';Executed by IdUser=' + CAST(@IdUser as VARCHAR)

	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUser, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

	SELECT 
	-1 as IdUser, 
	'' as UserLogin, 
	'' as SurName, 
	'' as FirstName, 
	'' as UserPatronymic, 
	0 as IdStatus, 
	0 as IdUnit, 
	0 as IdPosition, 
	[dbo].[f_standard_code](@ReturnMessage, @ReturnCode) as UserNote,
	'' as PasswordHash, 
	'' as SaltHash

END CATCH RETURN @ReturnCode END

GO

