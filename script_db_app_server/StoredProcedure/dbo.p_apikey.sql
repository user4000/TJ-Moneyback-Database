USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Процедура выдаст ReturnCode 
= 0 Если указан правильный APIKEY срок действия которого не закончен
= 1 Если указан правильный APIKEY срок действия которого закончен
= 2 Если указан неправильный APIKEY
*/
CREATE PROCEDURE [dbo].[p_apikey] 

	@ApiKey Varchar(100), @AddressServer Varchar(100), @AddressClient Varchar(100) 
	
AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdObject INTEGER = 0,
	@ReturnMessage Varchar(1000) = '',
	@ReturnNote  Varchar(1000) = '',
	@Ban INTEGER = 0

BEGIN TRY

	SET @ReturnCode = [dbo].[f_apikey] (@ApiKey, @AddressServer, @AddressClient) 

	IF ( @ReturnCode >= 2 ) 
		BEGIN
			SET @ReturnCode = 111112 ----dbo.f_parameter_integer('ERROR_APIKEY_WRONG')
			SET @ReturnNote = 'Server='+@AddressServer + '; Client=' + @AddressClient + '; ApiKey='+@ApiKey
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

	IF ( @ReturnCode = 1 ) 
		BEGIN
			SET @ReturnCode = 111111 ----dbo.f_parameter_integer('ERROR_APIKEY_EXPIRED')
			EXEC dbo.p_error 'Срок действия APIKEY закончен.', @ReturnCode
		END

END TRY BEGIN CATCH 

	SET @ReturnMessage = ERROR_MESSAGE()
	
END CATCH

IF @@NESTLEVEL < 2
BEGIN
	SELECT  @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
END

RETURN @ReturnCode

END


GO

