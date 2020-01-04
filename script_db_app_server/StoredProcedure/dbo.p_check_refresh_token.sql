USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_check_refresh_token] 

@AddressServer Varchar(50), 
@AddressClient Varchar(50),
@ApiKey Varchar(200),
@RefreshToken Varchar(200)

AS BEGIN SET NOCOUNT ON DECLARE 
/* Процедура вернет ReturnCode = 0 если пользователю можно выдать новые APIKEY и RefreshToken */

@IdUser INTEGER = [dbo].[f_get_id_by_apikey] (@ApiKey),
@ReturnCode INTEGER = 0,
@IdObject INTEGER = -1,
@ReturnMessage VARCHAR(4000) = '', ---- Здесь должен быть логин пользователя в конце выполнения,
@ReturnNote VARCHAR(4000) = '',
@IdStatusActive INTEGER = [dbo].[f_get_id_by_code] ('status','active')

BEGIN TRY

	IF NOT EXISTS ( SELECT * FROM [T].[USER] WHERE IdUser = @IdUser )
		EXEC dbo.p_error 'Ошибка! Пользователь не найден.', 100005

	IF NOT EXISTS ( SELECT * FROM [T].[USER] WHERE  IdUser = @IdUser AND IdStatus = @IdStatusActive)
		EXEC dbo.p_error 'Ошибка! Пользователь не является активным.', 100004  

	IF NOT EXISTS 
	( 
	SELECT * FROM [E].[ACCESS] 
	WHERE 
	IdUser=@IdUser and
	AddressServer=@AddressServer and
	AddressClient=@AddressClient and
	ApiKey=@ApiKey and
	RefreshToken=@RefreshToken
	)
	EXEC dbo.p_error 'Ошибка при проверке refresh token.', 100006  

	SELECT @ReturnMessage = UserLogin FROM [T].[USER] WHERE IdUser = @IdUser 

END TRY 
BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	SET @ReturnNote = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_check_refresh_token] error: Server='+@AddressServer + ';Client=' + @AddressClient + ';ApiKey='+@ApiKey + ';RefreshToken='+@RefreshToken
	EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=0, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

RETURN @ReturnCode

END


GO

