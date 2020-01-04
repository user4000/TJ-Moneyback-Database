USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_moneyback_status_change]

	@ApiKey Varchar(100), 
	@IdSearch INTEGER,
	@IdStatus INTEGER,
	@StatementNumber VARCHAR(20),
	@DateStatement VARCHAR(20),
	@HistoryNote VARCHAR(4000)

AS BEGIN SET NOCOUNT ON DECLARE 
	
	@Authorization BIT = 0,
	@TransactionStarted BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdObject INT = 0,
	@IdUser INT = 0

BEGIN TRY

	--IF @ApiKey != 'TJ_TEST'	BEGIN

	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_return')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции изменения статуса заявки', 100002

	--END

	IF NOT EXISTS(SELECT * FROM T.MONEY_REQUEST WHERE IdSearch=@IdSearch)
		EXEC db_app_server.dbo.p_error 'Не найдена заявка на возврат.', 100001

	IF NOT EXISTS(SELECT * FROM A.REQUEST_STATUS WHERE IdRequestStatus=@IdStatus)
		EXEC db_app_server.dbo.p_error 'Указан некорректный код статуса.', 100001

	IF EXISTS(SELECT * FROM T.MONEY_REQUEST WHERE IdSearch=@IdSearch AND IdStatus=@IdStatus)
		EXEC db_app_server.dbo.p_error 'Вы указали текущий статус заявки на возврат. Изменения не требуются.', 100001

	SET @TransactionStarted = 1

	BEGIN TRANSACTION

		UPDATE T.MONEY_REQUEST SET IdStatus = @IdStatus 
			WHERE IdSearch=@IdSearch AND IdStatus != @IdStatus

		INSERT INTO H.MONEY_REQUEST (IdSearch, IdUser, IdStatus, StatementNumber, DateStatement, HistoryNote)
			VALUES (@IdSearch, @IdUser, @IdStatus,  @StatementNumber, @DateStatement, @HistoryNote)

	COMMIT

	SET @IdObject = @IdSearch

END TRY BEGIN CATCH 

	IF @TransactionStarted != 0 IF @@TRANCOUNT > 0 ROLLBACK

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при изменении статуса! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_moneyback_status_change] error: IdSearch=' + CAST(@IdSearch as VARCHAR) + ' IdStatus=' + CAST(@IdStatus as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	----db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName /* Стандарт кодирования сообщения об ошибке */

END CATCH 

	SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

END








GO

