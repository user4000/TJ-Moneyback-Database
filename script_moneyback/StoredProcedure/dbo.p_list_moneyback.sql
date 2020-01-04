USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[p_list_moneyback]

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

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_return')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к просмотру заявок на возврат.', 100002

	--END

	--IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Поиск отменён.', 100001
	
	--IF NOT EXISTS(SELECT * FROM T.SEARCH_RESULT WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Результаты поиска не найдены. Возможно поиск не был завершён.', 100001

	SELECT 

		IdSearch,
		IdStatus,
		CONVERT(VARCHAR, DateCreate, 120) as DateCreate,
		AccountNumber,
		IdBank,
		BankAccount,
		CardNumber,
		BalanceText,
		0 as BalanceNumeric,
		ClientName,
		CASE WHEN IdBank=0 THEN 'Наличные' ELSE 'Перечисление' END as MoneybackType

	FROM T.MONEY_REQUEST
	WHERE IdSearch = @IdSearch OR @IdSearch = 0
	ORDER BY IdSearch DESC, DateCreate DESC

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при поиске данных! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_list_moneyback] error: IdSearch=' + CAST(@IdSearch as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	----db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName /* Стандарт кодирования сообщения об ошибке */

	SELECT 

	0 as IdSearch,
	0 as IdStatus,
	'?' as DateCreate,
	0 as AccountNumber,
	0 as IdBank,
	'?' as BankAccount,
	'?' as CardNumber,
	'?' as BalanceText,
	0 as BalanceNumeric,
	db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName,
	'?' as MoneybackType

END CATCH END








GO

