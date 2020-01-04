USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_apikey_save] 

	@UserLogin Varchar(50), 
	@ApiKey Varchar(32), 
	@RefreshToken Varchar(32), 
	@AddressServer Varchar(100), 
	@AddressClient Varchar(100) 

AS BEGIN SET NOCOUNT ON DECLARE 

@ReturnCode INTEGER = -1,
@IdObject INTEGER = -1,
@ReturnMessage VARCHAR(4000) = '',
@ReturnNote VARCHAR(4000) = '',
@IdUser INTEGER = [dbo].[f_get_id_by_code] ('user', @UserLogin)

BEGIN TRY
	
	IF (@IdUser < 0) EXEC dbo.p_error 'Ошибка! Пользователь не найден.', 100005

	/*
	IF NOT EXISTS ( SELECT * FROM [T].[USER] WHERE UserLogin = @UserLogin AND IdStatus = @IdStatusActive)
		EXEC dbo.p_error 'Доступ запрещен! Пользователь не активен.' 
	*/

	SET @AddressServer = LTRIM(RTRIM(@AddressServer))
	SET @AddressClient = LTRIM(RTRIM(@AddressClient))

	DELETE FROM [E].[ACCESS]
		WHERE IdUser = @IdUser AND AddressServer = @AddressServer AND DATEDIFF(hour, TimeEvent, Getdate()) > 48

	/* Строка закомментарена, так как иначе с одного компьютера можно будет работать только в одной клиентской программе 
	DELETE FROM [E].[ACCESS]
		WHERE IdUser = @IdUser AND AddressServer = @AddressServer AND AddressClient = @AddressClient
	*/

	IF EXISTS( SELECT * FROM E.ATTEMPT WHERE AddressServer = @AddressServer AND AddressClient = @AddressClient AND IsBanned !=0 AND RemoveBan > GETDATE() )
		BEGIN
			SELECT @ReturnNote = CONVERT(VARCHAR, RemoveBan, 120) FROM E.ATTEMPT WHERE AddressServer = @AddressServer AND AddressClient = @AddressClient
			SET @ReturnNote = 'Ваш IP-адрес заблокирован. Время окончания блокировки = ' +  @ReturnNote + '. Обратитесь к администратору системы.'
			EXEC dbo.p_error @ReturnNote, 111113
		END

	IF EXISTS( SELECT * FROM E.ATTEMPT WHERE AddressServer = @AddressServer AND AddressClient = @AddressClient AND IsBanned !=0 AND RemoveBan <= GETDATE() )
		UPDATE E.ATTEMPT SET IsBanned = 0 WHERE AddressServer = @AddressServer AND AddressClient = @AddressClient

	INSERT INTO [E].[ACCESS] 
		( IdUser,   ApiKey,  RefreshToken,  AddressServer,  AddressClient )
	VALUES 
		( @IdUser, @ApiKey, @RefreshToken, @AddressServer, @AddressClient )

	/* Если у данного IP-адреса уже были несанкционированные попытки доступа то здесь мы сбросим счётчик ошибок до нуля */
	IF EXISTS (SELECT * FROM E.ATTEMPT WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient AND FailureCount > 0)
		UPDATE E.ATTEMPT SET FailureCount = 0 WHERE RTRIM(AddressServer)=@AddressServer AND RTRIM(AddressClient)=@AddressClient

	SET @ReturnCode = 0
	SET @IdObject = @IdUser

	SELECT @ReturnMessage = /* 'Login = ' + UserLogin + ' = ' + */ SurName + ' ' + FirstName + ' ' + UserPatronymic  /* + ' from ' + @AddressClient + ' connected.' */
		FROM [T].[USER] 
			WHERE IdUser=@IdUser

	SET @ReturnNote    = 'Server=' + @AddressServer 
	SET @ReturnMessage = 'Client=' + @AddressClient
	EXEC dbo.p_event @IdMessage=200010, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END TRY 
BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_apikey_save] error: Server='+@AddressServer + ';Client=' + @AddressClient + ';ApiKey='+@ApiKey + ';RefreshToken='+@RefreshToken
	EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=0, @UserLogin=@UserLogin, @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

RETURN @ReturnCode

END

GO

