USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_check] @UserLogin Varchar(50) AS BEGIN SET NOCOUNT ON DECLARE 
/* Процедура должна вернуть ХЭШ пароля и СОЛЬ для вычисления этого хэша */
@ReturnCode INTEGER = 0,
@IdObject INTEGER = -1,
@ReturnMessage VARCHAR(4000) = '',
@ReturnNote VARCHAR(4000) = '',
@IdStatusActive INTEGER = [dbo].[f_get_id_by_code] ('status','active')

BEGIN TRY

	--SET @IdStatusActive  = [dbo].[f_get_id_by_code] ('status','active')
	
	IF NOT EXISTS ( SELECT * FROM [T].[USER] WHERE UserLogin = @UserLogin )
		EXEC dbo.p_error 'Ошибка! Пользователь не найден.', 100005 /* It is an ERROR ! Procedure will NOT return PasswordHash and SaltHash */
	
	 
	IF NOT EXISTS ( SELECT * FROM [T].[USER] WHERE UserLogin = @UserLogin AND IdStatus = @IdStatusActive) /* User is NOT active = User Account is locked */
		SET @ReturnCode = 100004 /* It is an ERROR but nevertheless procedure will return PasswordHash and SaltHash */

	SELECT 
		@ReturnMessage = PasswordHash, 
		@ReturnNote = SaltHash,
		@IdObject = IdUser
	FROM [T].[USER] 
	WHERE UserLogin = @UserLogin /* AND IdStatus = @IdStatusActive */

END TRY 
BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100007

	SET @ReturnNote = 'SP [dbo].[p_user_check] error: Login='+@UserLogin
	
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=0, 
		@UserLogin=@UserLogin, 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

RETURN @ReturnCode

END


GO

