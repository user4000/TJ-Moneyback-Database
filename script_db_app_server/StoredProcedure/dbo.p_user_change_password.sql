USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_change_password] 
	
	@UserLogin	  varchar(50),
	@PasswordHash varchar(1024),
	@SaltHash     varchar(32)

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 100001,
	@IdUser INTEGER = -1,
	@IdStatus INTEGER = 0,
	@ReturnMessage VARCHAR(1000) = 'Ошибка! Не удалось изменить пароль пользователя. ',
	@ReturnNote VARCHAR(1000) = ''

BEGIN TRY /* ================================================================================================== */
	
	IF EXISTS (SELECT * FROM [A].[STATUS] WHERE CodeObject = 'active')
		BEGIN
		SELECT @IdStatus = IdObject FROM [A].[STATUS] WHERE CodeObject = 'active'
		END

	IF (LEN(@SaltHash) < 10)
		BEGIN
		EXEC dbo.p_error 'Длина [соли] для хэша не должна быть меньше 10 символов.', 101001
		END

	IF (LEN(@PasswordHash) < 512)
		BEGIN
		EXEC dbo.p_error 'Длина хэша пароля не должна быть меньше 512 символов.', 101002
		END

	IF NOT EXISTS(SELECT * FROM [T].[USER] WHERE UserLogin = @UserLogin)
		BEGIN
		EXEC dbo.p_error 'Пользователь не найден.', 100005
		END

	IF NOT EXISTS(SELECT * FROM [T].[USER] WHERE UserLogin = @UserLogin AND IdStatus=@IdStatus)
		BEGIN
		EXEC dbo.p_error 'Пользователь не активен.', 100004
		END


		UPDATE [T].[USER]
		SET 
			[PasswordHash] = @PasswordHash,
			[SaltHash]     = @SaltHash
		WHERE 
			UserLogin = @UserLogin


		SET @ReturnCode = 0
		SET @ReturnMessage = 'Пароль пользователя ' + @UserLogin + ' изменён.'

END TRY BEGIN CATCH /* ----------------------------------------------------------------------------------------- */

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = @ReturnMessage + ERROR_MESSAGE()
	IF @ReturnCode = 0 SET @ReturnCode=100001

	SET @ReturnNote = 'SP [dbo].[p_user_change_password] error: Login='+@UserLogin 

	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=0, 
		@UserLogin=@UserLogin, 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH /* ================================================================================================== */

SELECT @ReturnCode as ReturnCode, @IdUser as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

RETURN @ReturnCode

END

GO

