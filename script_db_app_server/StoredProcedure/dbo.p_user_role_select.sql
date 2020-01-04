USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_role_select] 

	@ApiKey Varchar(100), 
	@EntityName Varchar(100),
	@IdObject Integer = 0

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@TableName VARCHAR(100)

BEGIN TRY

SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
SET @EntityName = RTRIM(LTRIM(UPPER(@EntityName)))
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN

	IF dbo.f_is_member_of(@IdUser,'security')=0 EXEC dbo.p_permission @ApiKey, 'role', 'select'
			
	SELECT A.IdObject as IdRole, CASE WHEN IdRole IS NULL THEN 0 ELSE 1 END as ActionSelect, NameObject FROM A.[ROLE] A
		LEFT JOIN (SELECT IdRole FROM J.ROLE_USER WHERE IdUser=@IdObject) B
			ON A.IdObject = B.IdRole
				WHERE A.IdObject > 0
				ORDER BY A.RankObject, A.IdObject

RETURN 0 END
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_user_role_select] error: Entity=' + @EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR)
	
	EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage,	@TextNote=@ReturnNote

	SELECT 	-1 as IdRole, 0 as ActionSelect, dbo.f_standard_code(@ReturnMessage, @ReturnCode) as NameObject

END CATCH RETURN @ReturnCode END

GO

