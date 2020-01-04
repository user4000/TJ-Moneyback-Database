USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_role_entity_select] 

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

SET @EntityName = RTRIM(LTRIM(UPPER(@EntityName)))
SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @EntityName='' 
BEGIN

	IF dbo.f_is_member_of(@IdUser,'security')=0 EXEC dbo.p_permission @ApiKey, 'role', 'select'
			
	SELECT 
		@IdObject as IdRole,
		IdObject as [IdEntity], 
		NameObject as NameEntity, 
		ISNULL(B.ActionSelect,0) as ActionSelect,
		ISNULL(B.ActionInsert,0) as ActionInsert,
		ISNULL(B.ActionUpdate,0) as ActionUpdate,
		ISNULL(B.ActionDelete,0) as ActionDelete
	FROM V.ENTITY_NOT_LOCKED A
	LEFT JOIN
	(SELECT * FROM J.ROLE_ENTITY WHERE (IdRole > 0) AND (IdRole=@IdObject) ) B
	ON A.IdObject = B.[IdEntity]

RETURN 0 END
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_role_entity_select] error: Entity=' + @EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR)

	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUser, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

		SELECT 
		-1 as IdRole,
		@ReturnCode as [IdEntity], 
		[dbo].[f_standard_code](@ReturnMessage ,@ReturnCode) as NameEntity, 
		0 as ActionSelect,
		0 as ActionInsert,
		0 as ActionUpdate,
		0 as ActionDelete

END CATCH RETURN @ReturnCode END

GO

