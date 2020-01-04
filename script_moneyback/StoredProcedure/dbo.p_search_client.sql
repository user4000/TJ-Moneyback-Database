USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_search_client]

	@ApiKey Varchar(100), 
	@IdSearch Integer

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdObject INT = 0,
	@IdUser INT = 0,
	@TestSearch BIT = 0

BEGIN TRY

	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)

	EXEC db_app_server.dbo.p_event 	@IdMessage=0, @IdUser=@IdUser, @UserLogin='', @TextEvent='[dbo].[p_search_client] Вызов процедуры поиска', @TextNote=@ReturnNote

	IF @IdUser < 0 EXEC db_app_server.dbo.p_error 'Пользователь не найден', 100005

	IF db_app_server.dbo.f_is_member_of(@IdUser,'moneyback_search')=1 SET @Authorization=1

	IF @Authorization=0 EXEC db_app_server.dbo.p_error 'У вас нет доступа к операции поиска клиента', 100002


	IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Поиск отменён.', 100001





	IF db_app_server.dbo.f_parameter_integer('MONEYBACK_SEARCH_TEST_MODE')=1
		SET @TestSearch = 1

	IF EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch AND UPPER(RTRIM(LTRIM(PassportNumber))) = 'TEST' )
		SET @TestSearch = 1




	IF @TestSearch = 1
	BEGIN /* Тестовый поиск */

		EXECUTE dbo.p_search_client_test @IdSearch

	END
	ELSE
	BEGIN /* Поиск на реальных данных */
		
		EXECUTE [INVOICE_RESERV].[dbo].[P_GET_CLIENTS_BY_SEARCH_ID] @IdSearch
				
		IF NOT EXISTS(SELECT * FROM T.SEARCH_RESULT WHERE IdSearch=@IdSearch)
		BEGIN

			INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric, BalanceText, PassportNumber, ClientName)
				VALUES ( @IdSearch,0,0,0,'0','Клиенты не найдены','Поиск не дал результатов' )
			
		END

		UPDATE T.SEARCH_REQUEST SET DateEnd = GETDATE() WHERE IdSearch=@IdSearch

	END

	/* <<<< Выдаём результат поиска */
	/*
	WAITFOR DELAY '00:00:01'

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric, BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 1, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 103298',  dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric, BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 1, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 103198', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 2, 1000+FLOOR(RAND()*1000000),ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 107398', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 3, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 195099', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 234078', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	IF FLOOR(RAND()*100) > 50

		INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
		VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 134095', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))


	IF FLOOR(RAND()*100) < 50

		INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
		VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.0000001, '', 'I-AS 112998', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))


	IF FLOOR(RAND()*100) > 50

		INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
		VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.0000001, '', 'I-AS 112301', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	IF FLOOR(RAND()*100) < 50

		INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
		VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), -1 * ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.0000001, '', 'I-AS 167334', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))


	IF FLOOR(RAND()*100) > 90

		INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
		VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), -1 * ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.000001, '', 'I-AS 134005', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))



	UPDATE T.SEARCH_REQUEST SET DateEnd = GETDATE() WHERE IdSearch = @IdSearch

	UPDATE T.SEARCH_RESULT SET BalanceText = CAST(BalanceNumeric as VARCHAR(50)) WHERE IdSearch = @IdSearch
	*/

	EXEC db_app_server.dbo.p_event 	@IdMessage=0, @IdUser=@IdUser, @UserLogin='', @TextEvent='[dbo].[p_search_client] Поиск закончен без ошибок', @TextNote=@ReturnNote


END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при поиске данных! ' + CAST(@ReturnCode as VARCHAR) + ': ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_search_client] error: IdSearch=' + CAST(@IdSearch as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	----db_app_server.dbo.f_standard_code (@ReturnMessage, @ReturnCode) as ClientName /* Стандарт кодирования сообщения об ошибке */

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric, BalanceText, PassportNumber, ClientName)
		VALUES ( @IdSearch,0,0,0,'0','Ошибка при поиске данных!', CAST(ERROR_NUMBER() as VARCHAR(50)) + ': ' + ERROR_MESSAGE() )

	UPDATE T.SEARCH_REQUEST SET DateEnd = GETDATE() WHERE IdSearch=@IdSearch

END CATCH 

	SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

END








GO

