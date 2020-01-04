USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_list_search_result]

	@ApiKey Varchar(100), 
	@IdSearch Integer

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdObject INT = 0,
	@IdUser INT = 0

	DECLARE @table table([Id] int)

BEGIN TRY

	--IF @ApiKey != 'TJ_TEST'	BEGIN

	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_search')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции поиска клиента', 100002

	--END

	IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Поиск отменён.', 100001
	
	IF NOT EXISTS(SELECT * FROM T.SEARCH_RESULT WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Результаты поиска не найдены. Возможно поиск не был завершён.', 100001

	/* <<<< Выдаём результат поиска */

	SELECT 
	IdResult,
	IdSearch,
	IdAction, 
	CardNumber, 
	AccountNumber, 
	0 as BalanceNumeric, 
	BalanceText, 
	PassportNumber, 
	ClientName
	FROM T.SEARCH_RESULT 
	WHERE IdSearch = @IdSearch
	ORDER BY CardNumber, AccountNumber

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при попытке просмотра результатов поиска! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_list_search_result] error: IdSearch=' + CAST(@IdSearch as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=100001, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	----db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName /* Стандарт кодирования сообщения об ошибке */

	SELECT 
	0 as IdResult,
	0 as IdSearch, 
	0 as IdAction,
	0 as CardNumber, 
	0 as AccountNumber, 
	0 as BalanceNumeric, 
	'?' as BalanceText, 
	'?' as PassportNumber, 
	db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName

END CATCH END








GO

