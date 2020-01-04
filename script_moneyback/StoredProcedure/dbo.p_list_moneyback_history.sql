USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_list_moneyback_history]

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

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к просмотру истории заявок на возврат.', 100002

	-- END

	SELECT 

		A.IdSearch,
		B.IdHistory,
		B.IdUser,
		A.AccountNumber,
		B.IdStatus,
		CONVERT(VARCHAR, B.DateHistory, 120) as DateHistory,
		B.StatementNumber,
		CONVERT(VARCHAR, B.DateStatement, 120) as DateStatement,
		B.HistoryNote

	FROM T.MONEY_REQUEST A 
		INNER JOIN H.MONEY_REQUEST B
			ON A.IdSearch = B.IdSearch
	WHERE A.IdSearch = @IdSearch 
	ORDER BY B.IdHistory

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при попытке выдачи истории заявки! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001
	SET @ReturnNote = 'SP [moneyback].[dbo].[p_list_moneyback_history] error: IdSearch=' + CAST(@IdSearch as VARCHAR)
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	SELECT 
		0 as IdSearch,
		0 as IdHistory,
		0 as IdUser,
		0 as AccountNumber,
		0 as IdStatus,
		'?' as DateHistory,
		'?' as StatementNumber,
		'?' as DateStatement,
		db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as HistoryNote

END CATCH END








GO

