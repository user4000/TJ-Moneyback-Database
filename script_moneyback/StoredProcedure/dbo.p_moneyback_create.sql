USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_moneyback_create]

	@ApiKey Varchar(100), 
	@IdSearch Integer,
	@AccountNumber Integer,
	@IdBank Integer,
	@BankAccount Varchar(23),
	@CardNumber Varchar(25),
	@ClientName nvarchar(200) 

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@TransactionStarted BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdObject INT = 0,
	@IdUser INT = 0,
	@BalanceText VARCHAR(50) = '',
	@BalanceNumeric decimal(38,32) = 0,
	@IdStatus INT = 10

BEGIN TRY

	--IF @ApiKey != 'TJ_TEST'	BEGIN

	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_return')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции создания запроса на возврат', 100002

	--END

	--IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) 
	--EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Поиск отменён.', 100001
	
	SET @AccountNumber = ISNULL(@AccountNumber, 0)
	SET @IdBank = ISNULL(@IdBank, 0)
	SET @BankAccount = ISNULL(@BankAccount, '')
	SET @CardNumber = ISNULL(@CardNumber, '')
	SET @BalanceText = ISNULL(@BalanceText, '')
	SET @ClientName = ISNULL(@ClientName, '')

	IF (@IdBank=0)
	BEGIN
		SELECT @BankAccount = '', @CardNumber = ''
	END


	IF EXISTS(SELECT * FROM T.MONEY_REQUEST WHERE IdSearch=@IdSearch)
		EXEC db_app_server.dbo.p_error 'Возврат по данному поиску уже был создан ранее.', 100001

	IF LEN(@ClientName) < 2 
		EXEC db_app_server.dbo.p_error 'Не указано имя (или название) клиента.', 100001

	IF @IdBank > 0 AND NOT EXISTS(SELECT * FROM A.BANK WHERE IdBank=@IdBank)
		EXEC db_app_server.dbo.p_error 'Некорректное значение кода банка.', 100001		

	IF (@IdBank > 0) AND (LEN(@BankAccount) != 23)
		EXEC db_app_server.dbo.p_error 'Некорректное значение банковского счёта клиента.', 100001

	/*IF (@IdBank > 0) AND (LEN(@CardNumber) < 1)
		EXEC db_app_server.dbo.p_error 'Некорректное значение номера карты клиента.', 100001 */

	IF EXISTS(SELECT * FROM T.REBALANCING WHERE IdSearch = @IdSearch AND AccountNumber=@AccountNumber AND BalanceNumeric <= 0)
		EXEC db_app_server.dbo.p_error 'На данном счету нет положительного баланса.', 100001

	IF @AccountNumber != (SELECT AccountNumber FROM T.REBALANCING WHERE IdSearch = @IdSearch AND BalanceNumeric > 0)
		EXEC db_app_server.dbo.p_error 'Неправильно указан номер лицевого счёта клиента.', 100001


	SELECT @BalanceText = BalanceText, @BalanceNumeric = BalanceNumeric
	FROM T.REBALANCING
	WHERE IdSearch = @IdSearch AND BalanceNumeric > 0


	SET @TransactionStarted = 1

	BEGIN TRANSACTION

	INSERT INTO T.MONEY_REQUEST (IdSearch, IdStatus, AccountNumber, IdBank, BankAccount, CardNumber, BalanceText, BalanceNumeric, ClientName)
	VALUES (@IdSearch, @IdStatus, @AccountNumber, @IdBank, @BankAccount, @CardNumber, @BalanceText, @BalanceNumeric, @ClientName)

	INSERT INTO H.MONEY_REQUEST (IdSearch, IdUser, IdStatus)
	VALUES (@IdSearch, @IdUser, @IdStatus)

	COMMIT

	SET @IdObject = @IdSearch

END TRY BEGIN CATCH 

	IF @TransactionStarted != 0 IF @@TRANCOUNT > 0 ROLLBACK

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при создании заявки на возврат! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_moneyback_create] error: IdSearch=' + CAST(@IdSearch as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	----db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName /* Стандарт кодирования сообщения об ошибке */

END CATCH 

	SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

END








GO

