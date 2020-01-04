USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_moneyback_command] ---- Result Set = IList<string> = List of strings = Recordset with one text column ----
	
	@ApiKey Varchar(8000), @A1 Varchar(8000),	@A2 Varchar(8000), @A3 Varchar(8000),	@A4 Varchar(8000), @A5 Varchar(8000)

AS BEGIN SET NOCOUNT ON DECLARE /* Универсальная многоцелевая процедура для программы moneyback */

	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@IdSearch INTEGER = 0

BEGIN TRY
	
/* ---------------------------------------------------------------------------------------- */
	 
	SET @IdUser = [db_app_server].[dbo].[f_get_id_by_apikey](@ApiKey)
	IF @IdUser < 0 EXEC [db_app_server].dbo.p_error 'Пользователь не найден', 100005

	SET @A1 = ISNULL(UPPER(RTRIM(LTRIM(@A1))),'') IF @A1 = '' SET @A1 = 'NULL'
	SET @A2 = ISNULL(UPPER(RTRIM(LTRIM(@A2))),'') IF @A2 = '' SET @A2 = 'NULL'
	SET @A3 = ISNULL(UPPER(RTRIM(LTRIM(@A3))),'') IF @A3 = '' SET @A3 = 'NULL'
	SET @A4 = ISNULL(UPPER(RTRIM(LTRIM(@A4))),'') IF @A4 = '' SET @A4 = 'NULL'
	SET @A5 = ISNULL(UPPER(RTRIM(LTRIM(@A5))),'') IF @A5 = '' SET @A5 = 'NULL'

	---- SET @ReturnNote = 'SP [dbo].[p_command] error: A1=' + @A1 + ' A2=' + @A2 + ' A3=' + @A3 + ' A4=' + @A4 + ' A5=' + @A5
	---- EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent='TEST!!!!', @TextNote=@ReturnNote
/* ---------------------------------------------------------------------------------------- */
/* Блок выдачи данных без проверки каких-либо разрешений (общедоступные данные)             */
/* ---------------------------------------------------------------------------------------- */
	---- SET @Admin = [db_app_server].dbo.f_is_member_of(@IdUser,'security') + [db_app_server].dbo.f_is_member_of(@IdUser,'admin') + [db_app_server].dbo.f_is_member_of(@IdUser,'developer')
	---- SELECT [db_app_server].[dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as ReturnMessage

--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('Test') 
		BEGIN				
		SELECT '1' UNION SELECT '2' UNION SELECT '3' UNION	SELECT CAST(IdSearch as VARCHAR) FROM T.SEARCH_REQUEST													
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('list_completed_search_request') ---- Список законченных поисков ----
		BEGIN ---- @A2 = number of days 

		SELECT '0' as IdSearch UNION			
		SELECT CAST(IdSearch as VARCHAR) FROM T.SEARCH_REQUEST
			WHERE 
			--CHARINDEX(',' + CAST(IdSearch as VARCHAR) + ',' , @A4) > 0
			--AND
			--DateEnd IS NOT NULL 
			LEN(DateEnd) > 0 ---- Признак того, что поиск закончен ----
			AND
			ABS ( CONVERT( INT,  GETDATE() - DateStart ) ) <= ISNULL(TRY_CAST(@A2 as INT),1) ---- Число дней прошедших после DateStart ----
			--AND
			--IdUser = @IdUser	
																		
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('list_bank') ---- Список банков ----
		BEGIN 

		SELECT '0| ' as Column1 ---- Специальное пустое значение ----
		UNION
		SELECT Column1 FROM
		(
			SELECT TOP 100 PERCENT CAST(IdBank as VARCHAR) + '| ' + BankShortName  as Column1 
			FROM A.BANK
			ORDER BY IdBank
		) BANK
																		
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('check_client_application_version') 
		BEGIN ---- Здесь @A2 = версия клиентского приложения ----

		IF EXISTS(SELECT * FROM [H].[CLIENT_APPLICATION_VERSION] WHERE ProhibitionIsActive > 0 AND GETDATE() > DateProhibition AND ClientApplicationVersion=RTRIM(LTRIM(@A2))  )
			SELECT [db_app_server].[dbo].[f_standard_code] ('Ошибка! Данная версия вашей программы запрещена к использованию', 1) as ReturnMessage
		ELSE
			SELECT [db_app_server].[dbo].[f_standard_code] ('0', 0) as ReturnMessage
																	
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('cancel_rebalancing') 
		BEGIN ---- Здесь @A2 = IdSearch ----

			SET @IdSearch = ISNULL( TRY_CAST(@A2 as INT), 0)

			IF EXISTS(SELECT * FROM T.MONEY_REQUEST WHERE IdSearch = @IdSearch )
			BEGIN
				SELECT [db_app_server].[dbo].[f_standard_code] ('Ошибка! По данному ребалансингу уже создана заявка на возврат денежных средств', 1) as ReturnMessage
			RETURN 0 END

			IF NOT EXISTS(SELECT * FROM T.REBALANCING WHERE IdSearch = @IdSearch )
			BEGIN
				SELECT [db_app_server].[dbo].[f_standard_code] ('Ошибка! Ребалансинг не найден. Отмена не требуется', 2) as ReturnMessage
			RETURN 0 END
				
			DELETE FROM T.REBALANCING WHERE IdSearch = @IdSearch
			
			UPDATE T.SEARCH_RESULT SET IdAction=0 WHERE IdSearch = @IdSearch

			SELECT [db_app_server].[dbo].[f_standard_code] ('0', 0) as ReturnMessage
			 																													
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('money_phrase') 
		BEGIN ---- Здесь @A2 = IdSearch ----

			SET @IdSearch = ISNULL( TRY_CAST(@A2 as INT), 0)
			
			IF EXISTS(SELECT * FROM T.MONEY_REQUEST WHERE IdSearch = @IdSearch )
			BEGIN
				SELECT dbo.f_money_as_phrase(BalanceNumeric) as ReturnMessage FROM T.MONEY_REQUEST WHERE IdSearch = @IdSearch
			END
			ELSE
			BEGIN
				SELECT ' ' as ReturnMessage
			END

		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('bank_name') 
		BEGIN ---- Здесь @A2 = IdSearch ----

			SET @IdSearch = ISNULL( TRY_CAST(@A2 as INT), 0)
			
			IF EXISTS(SELECT * FROM A.BANK WHERE IdBank = (SELECT IdBank FROM T.MONEY_REQUEST WHERE IdSearch = @IdSearch) )
			BEGIN
				SELECT BankName as ReturnMessage FROM A.BANK WHERE IdBank = (SELECT IdBank FROM T.MONEY_REQUEST WHERE IdSearch = @IdSearch) 
			END
			ELSE
			BEGIN
				SELECT ' ' as ReturnMessage
			END

		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------









--------------------------------------------------------------------------------------------------------------------------------------------------
	SET @ReturnCode = -1
	SET @ReturnMessage = 'Ошибка! Введённая вами команда не найдена.'
--------------------------------------------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [moneyback].[dbo].[p_moneyback_command] error: A1=' + @A1 + ' A2=' + @A2 + ' A3=' + @A3 + ' A4=' + @A4 + ' A5=' + @A5
	EXEC db_app_server.dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH 

	SELECT [db_app_server].[dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as ReturnMessage
	RETURN @ReturnCode 

END 
--------------------------------------------------------------------------------------------------------------------------------------------------

GO

