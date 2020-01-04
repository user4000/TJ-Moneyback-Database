USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_rebalancing]

	@ApiKey VARCHAR(100), 
	@IdSearch INTEGER,
	@IdResult VARCHAR(8000) ---- Последовательность натуральных чисел через запятую ---- ,1,2,3,4,5, ----

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@Rebalancing BIT = 1, ---- Флаг показывает следует ли проводить ребалансинг или он уже был проведён ранее по указанным данным ----
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@EmptyString VARCHAR(10) = '',
	@Account INTEGER = 0,
	@IdUser INTEGER = 0

BEGIN TRY 

	--IF @ApiKey != 'TJ_TEST' BEGIN
	
	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_rebalancing')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции ребалансинга', 100002

	--END

	IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Ребалансинг отменён.', 100001
	
	IF NOT EXISTS(SELECT * FROM T.SEARCH_RESULT WHERE IdSearch = @IdSearch)  EXEC db_app_server.dbo.p_error 'Результаты поиска не найдены. Возможно поиск не был завершён.', 100001

	IF EXISTS(SELECT * FROM T.REBALANCING WHERE IdSearch = @IdSearch) SET @Rebalancing=0 ----EXEC db_app_server.dbo.p_error 'Ребалансинг уже был произведён ранее по указанным вами данным.', 100001

	IF EXISTS(SELECT * FROM T.REBALANCING WHERE CHARINDEX( ',' + CAST(IdResult as Varchar) + ',', @IdResult ) > 0 ) SET @Rebalancing=0 ----EXEC db_app_server.dbo.p_error 'Ребалансинг уже был произведён ранее по указанным вами данным.', 100001
	
	IF EXISTS
	(
	SELECT * FROM T.SEARCH_RESULT 
			WHERE 
				IdSearch = @IdSearch
				AND
				CHARINDEX( ',' + CAST(IdResult as Varchar) + ',', @IdResult ) > 0 
				AND 
				AccountNumber IN (SELECT AccountNumber FROM T.REBALANCING)
	)
	EXEC db_app_server.dbo.p_error 'Найден лицевой счёт, по которому уже был проведён ребалансинг.', 100001
	
	IF @IdSearch=0 
	BEGIN
		SET @ReturnNote = 'Ошибка! Клиент отправил некорректные данные. ' + @IdResult
		EXEC db_app_server.dbo.p_error @ReturnNote, 100001
	END

	IF @Rebalancing=1 
	BEGIN

		BEGIN TRANSACTION

			INSERT INTO T.REBALANCING
				SELECT * FROM T.SEARCH_RESULT 
			WHERE 
				IdSearch = @IdSearch
				AND
				CHARINDEX( ',' + CAST(IdResult as Varchar) + ',', @IdResult ) > 0 
			
			SELECT @Account = MIN(AccountNumber) 
				FROM T.REBALANCING 
			WHERE IdSearch = @IdSearch

			UPDATE T.REBALANCING 
				SET BalanceNumeric = ( SELECT SUM(BalanceNumeric) FROM T.REBALANCING WHERE IdSearch = @IdSearch )
			WHERE IdSearch = @IdSearch AND AccountNumber = @Account


			IF EXISTS( SELECT * FROM T.REBALANCING WHERE BalanceNumeric <= 0 AND IdSearch = @IdSearch AND AccountNumber = @Account )
				EXEC db_app_server.dbo.p_error 'Итоговая сумма при ребалансинге не является положительным числом. Операция отменена', 100001

			IF EXISTS( SELECT * FROM T.REBALANCING WHERE IdSearch = @IdSearch AND AccountNumber IN (SELECT ACCOUNT FROM INVOICE_RESERV.dbo.INVOICE_MONEYBACK) )
				EXEC db_app_server.dbo.p_error 'Найден лицевой счёт который уже оформил возврат по предыдущей программе MONEYBACK. Операция отменена', 100001

			IF (SELECT COUNT(*) FROM (SELECT DISTINCT PassportNumber FROM T.REBALANCING WHERE IdSearch=@IdSearch) A) > 1
				EXEC db_app_server.dbo.p_error 'Вы указали клиентов у которых номера паспорта разные. Операция отменена', 100001

			IF EXISTS
			( 
			SELECT * FROM T.SEARCH_RESULT 
			WHERE IdSearch=@IdSearch 
			AND 
			PassportNumber IN (SELECT PassportNumber FROM T.REBALANCING WHERE IdSearch = @IdSearch)
			AND
			IdResult NOT IN (SELECT IdResult FROM T.REBALANCING WHERE IdSearch = @IdSearch)
			)
			EXEC db_app_server.dbo.p_error 'Вы забыли указать клиента, другие клиенты которого попали в ребалансинг. Операция отменена', 100001




			UPDATE T.REBALANCING 
				SET BalanceNumeric = 0
			WHERE IdSearch = @IdSearch AND AccountNumber != @Account

			UPDATE T.REBALANCING 
				SET BalanceText = '' + convert( varchar(50), convert(decimal(38,2), BalanceNumeric) ) + ''
			WHERE IdSearch = @IdSearch ---- AND BalanceNumeric > 0

			UPDATE T.REBALANCING 
				SET BalanceText = '0'
			WHERE IdSearch = @IdSearch AND BalanceNumeric = 0

			UPDATE T.SEARCH_RESULT 
				SET IdAction = 1
			WHERE IdSearch = @IdSearch AND IdResult IN (SELECT IdResult FROM T.REBALANCING WHERE IdSearch = @IdSearch)


		COMMIT

	END 

	SELECT 
		IdResult,
		IdSearch,
		0 as IdAction, 
		CardNumber, 
		AccountNumber, 
		0 as BalanceNumeric, 
		BalanceText, 
		PassportNumber, 
		ClientName
	FROM T.REBALANCING
		WHERE IdSearch = @IdSearch
			ORDER BY CardNumber, AccountNumber

END TRY BEGIN CATCH 

	IF @Rebalancing=1 
		IF @@TRANCOUNT > 0 ROLLBACK

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка ребалансинга! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_rebalancing] error: IdSearch=' + CAST(@IdSearch as VARCHAR) + ' IdResult=' + @IdResult
	
	--EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin=@EmptyString, @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

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

END CATCH RETURN 0 END












GO

