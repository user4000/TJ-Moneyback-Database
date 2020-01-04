USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_list_search_request]

	@ApiKey Varchar(100), 
	@Days Integer = 0,
	@IdUser Integer = 0,
	@IdSearch Integer = 0

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@UserName VARCHAR(100) = '',
	@IdUserInvoker INT = 0

BEGIN TRY

	SET @IdUserInvoker = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUserInvoker < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUserInvoker,'moneyback_search')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции поиска клиента', 100002
	
	/*
	EXEC db_app_server.dbo.p_event 
		@IdMessage=0, 
		@IdUser=@IdUserInvoker, 
		@UserLogin='', 
		@TextEvent='dbo.p_search_list', 
		@TextNote='debug point 1'
	*/

	----SET @ReturnCode = 1 / (23 - 20 -3)

	SELECT 

		IdSearch,
		A.IdUser,
		B.SurName + ' ' + B.FirstName as UserName,
		CONVERT(VARCHAR, DateStart, 120) as DateStart,
		CONVERT(VARCHAR, DateEnd, 120) as DateEnd,
		NULLIF(CAST(PhoneNumber as VARCHAR), '0') as PhoneNumber,
		NULLIF(CAST(AccountNumber as VARCHAR), '0') as AccountNumber,
		PassportNumber,
		ClientName,
		GuidSearch

	FROM T.SEARCH_REQUEST A
		LEFT JOIN V.[USER] B 
			ON A.IdUser = B.IdUser
	WHERE
	( A.IdUser = @IdUser OR @IdUser = 0 )
	AND
	( @Days = 0 OR ABS ( CONVERT( INT,  GETDATE() - DateStart ) ) <= @Days )
	AND
	( IdSearch = @IdSearch OR @IdSearch = 0 )
	AND 
	IdSearch NOT IN (SELECT IdSearch FROM T.MONEY_REQUEST) ---- Исключим те запросы на поиск по которым уже созданы запросы на возврат ----
	AND 
	A.IdUser NOT IN (SELECT IdUser FROM T.TEST_USER WHERE FlagActive=1 AND IdUser!=@IdUserInvoker)


	ORDER BY IdSearch DESC

	/*
	EXEC db_app_server.dbo.p_event 
		@IdMessage=0, 
		@IdUser=@IdUserInvoker, 
		@UserLogin='', 
		@TextEvent='dbo.p_search_list', 
		@TextNote='debug point 2'
	*/

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при выборке данных! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_list_search_request] error: Days=' + CAST(@Days as VARCHAR) + '; IdUser=' + CAST(@IdUser as VARCHAR) + '; IdSearch=' + CAST(@IdSearch as VARCHAR) 
					
	EXEC db_app_server.dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUserInvoker, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

	/* В случае ошибки выдадим набор строк такого же типа как и в случае обычного выполнения */
	SELECT 

		0 as IdSearch,
		0 as IdUser,
		'?' as UserName,
		'?' as DateStart,
		'?' as DateEnd,
		'?' as PhoneNumber,
		'?' as AccountNumber,
		'?' as PassportNumber,
		db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName,		 /* Стандарт кодирования сообщения об ошибке */
		'?' as GuidSearch

END CATCH RETURN @ReturnCode END
GO

