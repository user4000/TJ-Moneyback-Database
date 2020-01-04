USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_role_update] 

	@ApiKey VarChar(100),
	@IdObject INTEGER, ---------- IdRole
	@EntityName Varchar(100), ---- IdUser
	@ColumnName Varchar(100), ---- ColumnName ---- NOT USED HERE ---
	@CellValue  VarChar(100)  ---- CellValue

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewObject INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',
	
	@IdUser INTEGER,
	@IdRole INTEGER,
	@IdEntity INTEGER,
	@Cell INTEGER

BEGIN TRY 
	
	/* Проверка разрешений на изменение данных указанной сущности  */
	--EXEC dbo.p_permission @ApiKey, 'role', 'update' 
	/* ********************************************************** */

	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
	--------------------------------------------------------------------------------------------------------------------------------
	IF [dbo].[f_is_member_of](@IdUser,'security')=0 EXEC dbo.p_error '', 102034
	--------------------------------------------------------------------------------------------------------------------------------

	
	SET @IdRole = @IdObject

	IF @IdRole=0 EXEC dbo.p_error '', 102012
	
	SET @IdEntity = ISNULL(TRY_CONVERT(integer, @EntityName),-1)
	SET @Cell = ISNULL(TRY_CONVERT(integer, @CellValue),-1)
	SET @ColumnName = LOWER(@ColumnName)
	--------------------------------------------------------------------------------------------------------------------------------
	IF @IdEntity < 0 EXEC dbo.p_error '', 100013
	--------------------------------------------------------------------------------------------------------------------------------
	IF @Cell < 0 EXEC dbo.p_error '', 100013
	--------------------------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS(SELECT * FROM [A].[ROLE] WHERE IdObject=@IdRole) EXEC dbo.p_error '', 101014
	--------------------------------------------------------------------------------------------------------------------------------
	IF @Cell > 1 EXEC dbo.p_error '', 100012
	--------------------------------------------------------------------------------------------------------------------------------
	IF EXISTS (SELECT * FROM [T].[USER] WHERE IdStatus=dbo.f_get_id_by_code('status','deleted') AND IdUser=@IdEntity) EXEC dbo.p_error '', 102036
	--------------------------------------------------------------------------------------------------------------------------------
	IF @IdUser=@IdEntity AND @Cell = 0 AND [dbo].[f_role_is_security_admin](@IdRole)=1 EXEC dbo.p_error '', 102031
	--------------------------------------------------------------------------------------------------------------------------------
	IF @IdUser=@IdEntity AND @Cell = 1 AND [dbo].[f_role_is_security_admin](@IdRole)=1 EXEC dbo.p_error '', 102035
	--------------------------------------------------------------------------------------------------------------------------------
	IF @Cell = 1
	IF EXISTS(SELECT * FROM [J].[ROLE_USER] WHERE IdUser=@IdEntity AND IdRole=dbo.f_get_id_by_code('role', 'admin')) EXEC dbo.p_error '', 102032
	--------------------------------------------------------------------------------------------------------------------------------
	IF @Cell = 1
	IF EXISTS(SELECT * FROM [J].[ROLE_USER] WHERE IdUser=@IdEntity AND IdRole=dbo.f_get_id_by_code('role', 'developer')) EXEC dbo.p_error '', 102033
	--------------------------------------------------------------------------------------------------------------------------------
	IF ( @IdRole = dbo.f_get_id_by_code('role','developer') ) EXEC dbo.p_error '', 102037
	--------------------------------------------------------------------------------------------------------------------------------
	IF 
	[dbo].[f_is_member_of](@IdUser,'admin')=0 
	AND 
	[dbo].[f_is_member_of](@IdUser,'developer')=0
	AND
	( @IdRole = dbo.f_get_id_by_code('role','admin') )
	EXEC dbo.p_error '', 102038
	--------------------------------------------------------------------------------------------------------------------------------
	IF 
	[dbo].[f_is_member_of](@IdUser,'admin')=0 
	AND 
	[dbo].[f_is_member_of](@IdUser,'developer')=0
	AND
	( @IdRole = dbo.f_get_id_by_code('role','security') )
	EXEC dbo.p_error '', 102038
	--------------------------------------------------------------------------------------------------------------------------------
	
	--------------------------------------------------------------------------------------------------------------------------------
	   IF @Cell=1 BEGIN

			IF NOT EXISTS(SELECT * FROM [J].[ROLE_USER] WHERE IdRole=@IdRole AND IdUser=@IdEntity )	INSERT INTO [J].[ROLE_USER] (IdRole, IdUser) VALUES (@IdRole, @IdEntity)

		END	ELSE BEGIN

			DELETE FROM [J].[ROLE_USER] WHERE IdRole=@IdRole AND IdUser=@IdEntity
	
		END
	--------------------------------------------------------------------------------------------------------------------------------
	
	
	--------------------------------------------------------------------------------------------------------------------------------
	IF ----- Remove any other role from ADMIN of the system -----
		EXISTS(SELECT * FROM [J].[ROLE_USER] WHERE IdUser=@IdEntity AND IdRole=dbo.f_get_id_by_code('role','admin'))
		AND
		EXISTS(SELECT * FROM [J].[ROLE_USER] WHERE IdUser=@IdEntity AND IdRole!=dbo.f_get_id_by_code('role','admin'))
	DELETE FROM [J].[ROLE_USER] WHERE IdUser=@IdEntity AND IdRole!=dbo.f_get_id_by_code('role','admin') AND IdRole!=dbo.f_get_id_by_code('role','developer')
	--------------------------------------------------------------------------------------------------------------------------------

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001	
	SET @ReturnNote = 'SP [dbo].[p_user_role_update] error: Entity='+@EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR) + ';ColumnName=' + @ColumnName + ';CellValue=' + @CellValue 
		
	EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH

	SELECT @ReturnCode as ReturnCode, @IdCreatedNewObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
	RETURN @ReturnCode 

END


GO

