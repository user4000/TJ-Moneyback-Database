USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_search_client_test]

	@IdSearch Integer

AS BEGIN SET NOCOUNT ON DECLARE 

	@Authorization BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdObject INT = 0,
	@IdUser INT = 0

BEGIN TRY

	IF NOT EXISTS(SELECT * FROM T.SEARCH_REQUEST WHERE IdSearch = @IdSearch) EXEC db_app_server.dbo.p_error 'Запрос на поиск не найден. Поиск отменён.', 100001
	
	/* Выдаём результат поиска. Данные - не настоящие */

	----WAITFOR DELAY '00:00:01'

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric, BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 1, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 103999',  dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric, BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 1, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 103999', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 2, 1000+FLOOR(RAND()*1000000),ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 103999', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 3, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 195022', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
	VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 195022', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

	IF FLOOR(RAND()*100) > 50

		INSERT INTO T.SEARCH_RESULT (IdSearch, CardNumber, AccountNumber, BalanceNumeric,  BalanceText, PassportNumber, ClientName)
		VALUES (@IdSearch, 4, 1000+FLOOR(RAND()*1000000), ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) * 0.00000001, '', 'I-AS 195022', dbo.f_get_random_name(FLOOR(RAND()*7865084)+1))

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

	UPDATE T.SEARCH_RESULT SET AccountNumber = AccountNumber + 1000000000 WHERE IdSearch = @IdSearch

	EXEC db_app_server.dbo.p_event 	@IdMessage=0, @IdUser=@IdUser, @UserLogin='', @TextEvent='[dbo].[p_search_client] Поиск закончен без ошибок', @TextNote=@ReturnNote

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при поиске данных! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_search_client_test] error: IdSearch=' + CAST(@IdSearch as VARCHAR)
	
	EXEC db_app_server.dbo.p_event 	@IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH 

	SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

END








GO

