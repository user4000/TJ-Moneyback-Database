USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_insert] 

	@ApiKey VarChar(100),
	@UserLogin VarChar(50),
	@PasswordHash VarChar(1024),
	@SaltHash VarChar(32),
	@IdStatus INTEGER,
	@IdUnit INTEGER,
	@IdPosition INTEGER,
	@SurName NVarchar(100),
	@FirstName NVarchar(100),
	@UserPatronymic NVarchar(100),
	@UserNote NVarchar(4000) = ''

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewUser INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',

	@EntityName VARCHAR(100) = 'user',
	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000),
	@Var NVARCHAR(4000),
	@Quote NVarChar(10) = ''''

BEGIN TRY

	/* Проверка разрешений на добавление данных указанной сущности  */
	IF dbo.f_is_member_of([dbo].[f_get_id_by_apikey](@ApiKey),'security')=0 EXEC dbo.p_permission @ApiKey, @EntityName, 'insert'
	/* ********************************************************** */

	SET @UserLogin = RTRIM(LTRIM(@UserLogin))
	SET @PasswordHash = RTRIM(LTRIM(@PasswordHash))
	SET @SaltHash = RTRIM(LTRIM(@SaltHash))
	SET @SurName = RTRIM(LTRIM(@SurName))
	SET @FirstName = RTRIM(LTRIM(@FirstName))
	SET @UserPatronymic = RTRIM(LTRIM(@UserPatronymic))
	SET @UserNote = RTRIM(LTRIM(@UserNote))

	IF LEN(@UserLogin) < 1 EXEC dbo.p_error '', 102024
	IF LEN(@PasswordHash) < 512 EXEC dbo.p_error '', 101002
	IF LEN(@SaltHash) < 10 EXEC dbo.p_error '', 101001

	IF EXISTS(SELECT * FROM [T].[USER] WHERE UserLogin=@UserLogin) EXEC dbo.p_error '', 102027

	IF NOT EXISTS(SELECT * FROM [A].[STATUS] WHERE IdObject=@IdStatus) SET @IdStatus=0 
	IF NOT EXISTS(SELECT * FROM [A].[UNIT] WHERE IdObject=@IdUnit) SET @IdUnit=0 
	IF NOT EXISTS(SELECT * FROM [A].[POSITION] WHERE IdObject=@IdPosition) SET @IdPosition=0 

	IF NOT EXISTS(SELECT * FROM [A].[STATUS] WHERE IdObject=@IdStatus)     EXEC dbo.p_error '', 101011
	IF NOT EXISTS(SELECT * FROM [A].[UNIT] WHERE IdObject=@IdUnit)         EXEC dbo.p_error '', 101012
	IF NOT EXISTS(SELECT * FROM [A].[POSITION] WHERE IdObject=@IdPosition) EXEC dbo.p_error '', 101013

	IF LEN(@SurName) < 1   EXEC dbo.p_error '', 102025
	IF LEN(@FirstName) < 1 EXEC dbo.p_error '', 102026

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

		SELECT @IdCreatedNewUser = IdUser 
		FROM [T].[USER]
		WHERE UserLogin=@UserLogin AND PasswordHash=@PasswordHash AND SaltHash=@SaltHash

		IF EXISTS(SELECT * FROM [T].[USER] WHERE IdUser!=@IdCreatedNewUser AND PasswordHash=@PasswordHash )
			EXEC dbo.p_event 
				@IdMessage=100001, 
				@IdUser=@IdCreatedNewUser, 
				@UserLogin=@UserLogin, 
				@TextEvent='Хэш пароля нового пользователя совпадает с хэшем пароля уже имеющегося пользователя.', 
				@TextNote='Обнаружено ошибочное поведение подсистемы генерации хэша пароля.'

		IF EXISTS(SELECT * FROM [T].[USER] WHERE IdUser!=@IdCreatedNewUser AND SaltHash=@SaltHash )
			EXEC dbo.p_event 
				@IdMessage=100001, 
				@IdUser=@IdCreatedNewUser, 
				@UserLogin=@UserLogin, 
				@TextEvent='[Соль] для хэша пароля нового пользователя совпадает с [солью] уже имеющегося пользователя.', 
				@TextNote='Обнаружено ошибочное поведение подсистемы генерации соли для хэша пароля.'

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_user_insert] error: Login=' + @UserLogin + '; Name=' + @SurName + ' ' + @FirstName + ' ' + @UserPatronymic
	
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdCreatedNewUser, 
		@UserLogin=@UserLogin, 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdCreatedNewUser as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode 

END


GO

