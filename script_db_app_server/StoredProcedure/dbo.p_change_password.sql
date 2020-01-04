USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_change_password]
	@OldPassword varchar(100),
	@NewPassword varchar(100),
	@Login varchar(50)

/* WITH EXECUTE AS OWNER */ AS BEGIN SET NOCOUNT ON /* Внимание! Данная процедура меняет пароль логина MS SQL SERVER */

DECLARE 

@s VARCHAR(4000), 
@ReturnCode INT = 0, 
@ReturnMessage VARCHAR(4000) = 'Пароль пользователя изменен.', 
@ReturnNote VARCHAR(4000)


	SET @Login = LOWER(@Login)

	BEGIN TRY
	
		/*====================================================================================================*/
		IF NOT EXISTS( SELECT * FROM sys.sql_logins WHERE name=@Login AND PWDCOMPARE(@OldPassword, password_hash)=1 )
		BEGIN
			SET @s = 'Некорректный логин или пароль.' --'Login = ' + @Login + ' Новый пароль = ' + @NewPassword + ' Старый пароль = ' + @OldPassword
			EXECUTE dbo.p_error @s --'Некорректный логин или пароль.'
		END

		SET @s = 
		'
		USE [' + DB_NAME() + ']

		IF EXISTS (SELECT * FROM [sys].[server_principals] WHERE name=<login>)
		ALTER LOGIN [{login}] WITH PASSWORD=<newpassword> OLD_PASSWORD=<oldpassword>
		'

		SET @s = Replace(@s, '{login}', @Login)
		SET @s = Replace(@s, '<login>', CHAR(39) + @Login + CHAR(39))
		SET @s = Replace(@s, '<newpassword>', CHAR(39) + @NewPassword + CHAR(39))
		SET @s = Replace(@s, '<oldpassword>', CHAR(39) + @OldPassword + CHAR(39))

		EXECUTE(@s)

	END TRY
	BEGIN CATCH
		
		--IF @@NESTLEVEL < 2 
			
	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = CAST(@ReturnCode as VARCHAR) + ' ' + ERROR_MESSAGE()

	SET @ReturnNote = 'SP [dbo].[p_change_password] error: [SQL Server Login]=' + @Login 
	
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=0, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote
	
	END CATCH

	SELECT @ReturnCode as ReturnCode, 0 as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote	
	RETURN @ReturnCode

END



GO

