USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_create_admin] 
		
	@PasswordHash varchar(1024),
	@SaltHash varchar(32),
	@SurName nvarchar(100) = '',
	@FirstName nvarchar(100) = '',
	@UserPatronymic nvarchar(100) = '',
	@UserNote nvarchar(4000) = ''
	
AS BEGIN SET NOCOUNT ON DECLARE 

	@UserLogin varchar(50) = 'admin', ---- built-it ADMIN account ----
	@ReturnCode INTEGER = -1,
	@IdUser INTEGER = -1,
	@ReturnMessage VARCHAR(1000) = 'Ошибка! Не удалось сохранить данные администратора. ',
	@ReturnNote VARCHAR(1000) = '',
	@IdRole INTEGER =0,
	@IdStatus INTEGER = 0,
	@IdUnit INTEGER = 0,
	@IdPosition INTEGER = 0

BEGIN TRY /* ================================================================================================== */
	
	SET @UserLogin = dbo.f_parameter_string('BUILTIN_ADMINISTRATOR')

	IF EXISTS (SELECT * FROM [A].[STATUS] WHERE CodeObject = 'active')
		BEGIN
		SELECT @IdStatus = IdObject FROM [A].[STATUS] WHERE CodeObject = 'active'
		END

	IF EXISTS (SELECT * FROM [A].[ROLE] WHERE CodeObject = 'admin')
		BEGIN
		SELECT @IdRole = IdObject FROM [A].[ROLE] WHERE CodeObject = 'admin'
		END

	IF (LEN(@SaltHash) < 10)
		BEGIN
		EXEC dbo.p_error 'Длина [соли] для хэша не должна быть меньше 10 символов.', 101001
		END

	IF (LEN(@PasswordHash) < 512)
		BEGIN
		EXEC dbo.p_error 'Длина хэша пароля не должна быть меньше 512 символов.', 101002
		END

	IF (LEN(@SurName) < 1 ) SET @SurName = '?'
	IF (LEN(@FirstName) < 1 ) SET @FirstName = '?'


		/*
	IF EXISTS ( SELECT * FROM sys.sql_logins WHERE name=@UserLogin ) 
		BEGIN 
		EXEC dbo.p_error 'Нельзя указывать логин, который уже существует в MS SQL Server.' 
		END
		*/

		IF EXISTS(SELECT * FROM [T].[USER] WHERE UserLogin = @UserLogin)
			DELETE FROM [T].[USER] WHERE UserLogin = @UserLogin

		INSERT INTO [T].[USER]
				   ([UserLogin]
				   ,[PasswordHash]
				   ,[SaltHash]
				   ,[IdStatus]
				   ,[IdUnit]
				   ,[IdPosition]
				   ,[SurName]
				   ,[FirstName]
				   ,[UserPatronymic]
				   ,[UserNote])
			 VALUES
				   (
				   @UserLogin,
				   @PasswordHash, 
				   @SaltHash, 
				   @IdStatus, 
				   @IdUnit, 
				   @IdPosition, 
				   @SurName, 
				   @FirstName, 
				   @UserPatronymic,
				   @UserNote
				   )

		SELECT @IdUser = IdUser FROM [T].[USER] WHERE UserLogin = @UserLogin

		INSERT INTO [J].[ROLE_USER] (IdUser, IdRole) VALUES (@IdUser, @IdRole)

		SET @ReturnCode = 0

END TRY BEGIN CATCH /* ----------------------------------------------------------------------------------------- */

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = @ReturnMessage + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_create_admin] error.'
		
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=0, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH /* ================================================================================================== */

SELECT @ReturnCode as ReturnCode, @IdUser as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

RETURN @ReturnCode

END

GO

