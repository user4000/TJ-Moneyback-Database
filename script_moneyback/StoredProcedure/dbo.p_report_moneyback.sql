USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_report_moneyback]

	@ApiKey Varchar(100), 
	@DateReport Integer

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@SUM_CASH NUMERIC(38, 32) = 0,
	@SUM_CARD NUMERIC(38, 32) = 0,
	@STR_CASH VARCHAR(50) = '',
	@STR_CARD VARCHAR(50) = '',
	@IdObject INT = 0,
	@IdUser INT = 0

BEGIN TRY

	--IF @ApiKey != 'TJ_TEST'	BEGIN

	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_report')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к просмотру отчётов.', 100002

	--END

	--IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Поиск отменён.', 100001
	
	--IF NOT EXISTS(SELECT * FROM T.SEARCH_RESULT WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Результаты поиска не найдены. Возможно поиск не был завершён.', 100001

	IF NOT EXISTS (	SELECT * FROM T.MONEY_REQUEST WHERE db_app_server.dbo.f_date_to_int(DateCreate) = @DateReport)
		EXEC db_app_server.dbo.p_error 'Данные на указанную дату не найдены.', 100010

	---------------------------------------------------------------------------------------------------------------
	SELECT @SUM_CASH = SUM(BalanceNumeric) 
	FROM T.MONEY_REQUEST	
	WHERE 
	db_app_server.dbo.f_date_to_int(DateCreate) = @DateReport
	AND
	( ISNULL(IdBank,0) = 0 OR ISNULL(BankAccount,'?') = '?' )
	---------------------------------------------------------------------------------------------------------------
	SET @STR_CASH = convert( varchar(50), convert(decimal(38,2), @SUM_CASH) )
	---------------------------------------------------------------------------------------------------------------
	SELECT @SUM_CARD = SUM(BalanceNumeric) 
	FROM T.MONEY_REQUEST	
	WHERE 
	db_app_server.dbo.f_date_to_int(DateCreate) = @DateReport
	AND
	( IdBank > 0 AND LEN(BankAccount) > 0 )
	---------------------------------------------------------------------------------------------------------------
	SET @STR_CARD = convert( varchar(50), convert(decimal(38,2), @SUM_CARD) )
	---------------------------------------------------------------------------------------------------------------

	SELECT ---- Cумма за 1 день наличными ----

		0 as IdSearch,
		0 as IdStatus,
		'' as DateCreate,
		0 as AccountNumber,
		0 as IdBank,
		'' as BankAccount,
		'' as CardNumber,
		@STR_CASH as BalanceText,
		0 as BalanceNumeric,
		'' as ClientName,
		'cash' as MoneybackType

	UNION

	SELECT ---- Cумма за 1 день перечислением ----

		0 as IdSearch,
		0 as IdStatus,
		'' as DateCreate,
		0 as AccountNumber,
		1 as IdBank,
		'' as BankAccount,
		'' as CardNumber,
		@STR_CARD as BalanceText,
		0 as BalanceNumeric,
		'' as ClientName,
		'card' as MoneybackType

	UNION

	SELECT ---- Данные за 1 день: 1 строка = 1 возврат ----

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
		'' as MoneybackType

	FROM T.MONEY_REQUEST
	WHERE db_app_server.dbo.f_date_to_int(DateCreate) = @DateReport
	ORDER BY DateCreate, IdSearch

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при выводе отчёта! ' + CAST(@ReturnCode as VARCHAR) + ': ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_report_moneyback] error: DateReport=' + CAST(@DateReport as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	----db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName /* Стандарт кодирования сообщения об ошибке */

	SELECT 
	0 as IdSearch,
	'?' as DateCreate,
	0 as AccountNumber,
	0 as IdBank,
	'?' as BankAccount,
	'?' as CardNumber,
	'?' as BalanceText,
	0 as BalanceNumeric,
	db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName,
	'' as MoneybackType

END CATCH END








GO

