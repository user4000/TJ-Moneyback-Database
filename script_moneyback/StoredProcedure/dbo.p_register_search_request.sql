USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_register_search_request]

	@ApiKey varchar(100), 
	@IdSearch INTEGER,
	@GuidSearch varchar(50),
	@PhoneNumber varchar(50),
	@AccountNumber varchar(50),
	@PassportNumber nvarchar(50),
	@ClientName nvarchar(50) 

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdObject INT = 0,
	@IdUser INT = 0

	DECLARE @table table([Id] int)

BEGIN TRY

	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_search')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции поиска клиента', 100002

	/* <<<< Регистрируем запрос на поиск */

	INSERT INTO T.SEARCH_REQUEST (GuidSearch, IdUser, PhoneNumber, AccountNumber, PassportNumber, ClientName)
		OUTPUT inserted.IdSearch INTO @table
			VALUES               (@GuidSearch, @IdUser, TRY_CAST(@PhoneNumber as INT), TRY_CAST(@AccountNumber as INT) , @PassportNumber, @ClientName)

	SELECT @IdSearch = Id FROM @table 	---- SELECT @IdSearch = SCOPE_IDENTITY() ----

	SET @IdObject = @IdSearch

	/* Регистрируем запрос на поиск >>>> */

	SET @ReturnMessage = '0' 
	SET @ReturnNote = 'SP [moneyback].[dbo].[p_register_search_request] : PhoneNumber=' + @PhoneNumber + '; AccountNumber=' + @AccountNumber + '; PassportNumber=' + @PassportNumber + '; ClientName=' + @ClientName + '; GuidSearch=' + @GuidSearch 

END TRY BEGIN CATCH -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	SET @ReturnCode = ERROR_NUMBER() IF (@ReturnCode=0) SET @ReturnCode = 100001
	SET @ReturnMessage = 'Ошибка при регистрации запроса на поиск клиента! ' + CAST(@ReturnCode as VARCHAR) + ': ' + ERROR_MESSAGE()
	SET @ReturnNote = 'SP [moneyback].[dbo].[p_register_search_request] error: PhoneNumber=' + CAST(@PhoneNumber as VARCHAR) + '; AccountNumber=' + CAST(@AccountNumber as VARCHAR) + '; PassportNumber=' + @PassportNumber + '; ClientName=' + @ClientName + '; GuidSearch=' + @GuidSearch 
	
	EXEC db_app_server.dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH           -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


	SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

END








GO

