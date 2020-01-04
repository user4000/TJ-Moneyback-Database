USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_apikey_delete] 

	@ApiKey Varchar(100), @AddressServer Varchar(100), @AddressClient Varchar(100) 
	
AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdObject INTEGER = 0,
	@ReturnMessage Varchar(1000) = '',
	@ReturnNote  Varchar(1000) = 'Поступил запрос на удаление APIKEY.',
	@Ban INTEGER = 0

BEGIN TRY

	SET @ReturnCode = [dbo].[f_apikey] (@ApiKey, @AddressServer, @AddressClient) 

	IF ( @ReturnCode >= 2 ) 
		BEGIN
			SET @ReturnCode = 111112 ----dbo.f_parameter_integer('ERROR_APIKEY_WRONG')
			SET @ReturnNote = 'Server='+@AddressServer + ';Client=' + @AddressClient + ';ApiKey='+@ApiKey
			EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=0, @UserLogin='', @TextEvent=@ReturnNote, @TextNote=''
			EXEC @Ban = dbo.p_access_attempt @AddressServer, @AddressClient

			/* В переменной @Ban - количество минут, на которые нужно забанить клиента */
			IF @Ban > 0 
			BEGIN
				SET @IdObject = @Ban ------ Это признак того, что добавили в бан ------
				SET @ReturnNote = 'IP адрес клиента добавлен в список блокированных адресов. Your ip-address has been added to ban list.'
			END

			EXEC dbo.p_error 'Неправильный APIKEY.', @ReturnCode
		END

	/* Если APIKEY Expired то значение @ReturnCode будет не равным 0, поэтому здесь мы принудительно ставим = 0 */
	SET @ReturnCode = 0 
	
	SELECT @ReturnMessage = 'Login = ' + UserLogin + ' = ' + SurName + ' ' + FirstName + ' ' + UserPatronymic + ' from ' + @AddressClient + ' disconnected.'
		FROM [T].[USER] 
			WHERE IdUser=dbo.f_get_id_by_apikey(@ApiKey)

	SET @ReturnMessage = ISNULL(@ReturnMessage,'Поступил запрос на удаление APIKEY. Ошибка в процедуре [dbo].[p_apikey_delete]. Переменная @ReturnMessage IS NULL')

	DELETE FROM [E].[ACCESS] WHERE ApiKey=@ApiKey

END TRY BEGIN CATCH 

	SET @ReturnMessage = ERROR_MESSAGE()
	SET @ReturnMessage = ISNULL(@ReturnMessage,'Поступил запрос на удаление APIKEY. Ошибка в процедуре [dbo].[p_apikey_delete] (cекция CATCH). Переменная @ReturnMessage IS NULL')
	
END CATCH

IF @@NESTLEVEL < 2
BEGIN
	SELECT  @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
END

RETURN @ReturnCode

END

GO

