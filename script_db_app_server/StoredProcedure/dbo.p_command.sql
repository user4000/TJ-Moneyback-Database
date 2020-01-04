USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_command] ---- Result Set = IList<string> = List of strings = Recordset with one text column ----

	@ApiKey Varchar(100), @A1 Varchar(100),	@A2 Varchar(100), @A3 Varchar(100),	@A4 Varchar(100), @A5 Varchar(100)

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@Admin INT = 0

BEGIN TRY

/* ---------------------------------------------------------------------------------------- */
	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)

	SET @A1 = ISNULL(UPPER(RTRIM(LTRIM(@A1))),'')
	SET @A2 = ISNULL(UPPER(RTRIM(LTRIM(@A2))),'')
	SET @A3 = ISNULL(UPPER(RTRIM(LTRIM(@A3))),'')
	SET @A4 = ISNULL(UPPER(RTRIM(LTRIM(@A4))),'')
	SET @A5 = ISNULL(UPPER(RTRIM(LTRIM(@A5))),'')

	IF @A5 = '' SET @A5 = 'NULL'
	IF @A4 = '' SET @A4 = 'NULL'
	IF @A3 = '' SET @A3 = 'NULL'
	IF @A2 = '' SET @A2 = 'NULL'
	IF @A1 = '' SET @A1 = 'NULL'

	----SET @ReturnNote = 'SP [dbo].[p_command] error: A1=' + @A1 + ' A2=' + @A2 + ' A3=' + @A3 + ' A4=' + @A4 + ' A5=' + @A5
	----EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent='TEST!!!!', @TextNote=@ReturnNote

/* ---------------------------------------------------------------------------------------- */
/* Блок выдачи данных без проверки каких-либо разрешений (общедоступные данные)             */
/* ---------------------------------------------------------------------------------------- */

	IF @IdUser < 0 EXEC dbo.p_error 'Пользователь не найден', 100005

	SET @Admin = dbo.f_is_member_of(@IdUser,'security') + dbo.f_is_member_of(@IdUser,'admin') + dbo.f_is_member_of(@IdUser,'developer')

--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('Help') OR @A1=UPPER('?') OR @A1=UPPER('/?')
		BEGIN
			SELECT CommandHint FROM A.COMMAND_HINT ORDER BY CommandHint
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('Check') AND @A2=UPPER('Me') AND @A3=UPPER('Role') AND @A4=UPPER('Admin')
		BEGIN
					
			SET @ReturnMessage = '0'

			IF @Admin > 0 
				SET @ReturnCode = 0
			ELSE
				SET @ReturnCode = 1

			SELECT [dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as ReturnMessage
														
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('List') AND @A2=UPPER('Action')
	BEGIN

		IF EXISTS(SELECT * FROM A.[ACTION])
			SELECT 
			[Action] as ReturnMessage
			FROM A.[ACTION]
		ELSE
			SELECT [dbo].[f_standard_code] ('Список действий пуст.', 0) as ReturnMessage

	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------	
	IF @A1=UPPER('List') AND @A2=UPPER('Banned')
	BEGIN

		IF EXISTS(SELECT * FROM E.ATTEMPT WHERE IsBanned != 0 AND ( @A3='NULL' OR AddressServer=@A3))
			SELECT 
			AddressServer + '; ' + AddressClient + '; ' + CONVERT(VARCHAR, RemoveBan, 120) as ReturnMessage
			FROM E.ATTEMPT
			WHERE IsBanned != 0 AND ( @A3='NULL' OR AddressServer=@A3 )
		ELSE
			SELECT [dbo].[f_standard_code] ('Заблокированные адреса не найдены.', 0) as ReturnMessage

	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('Ban') AND @A2=UPPER('Add') ---- A3 = AddressClient  ---- A4 = Minutes
	BEGIN

		IF @Admin < 1 EXEC dbo.p_error '', 100014

		IF ISNULL( TRY_CONVERT(INTEGER, @A4), -1 ) <= 0
		EXEC dbo.p_error 'Неправильно указано число минут. Пример бана на 5 минут: ban add 192.168.100.123 5', 100011

		SELECT @ReturnNote = AddressServer FROM E.ACCESS WHERE ApiKey=@ApiKey
		IF NOT EXISTS(SELECT * FROM E.ATTEMPT WHERE AddressServer=@ReturnNote AND AddressClient=@A3)
			INSERT INTO E.ATTEMPT (AddressServer, AddressClient, FailureCount, BanCount, IsBanned, RemoveBan)
			VALUES (@ReturnNote, @A3, 0, 0, 1, GETDATE() + TRY_CONVERT(INTEGER, @A4) * 1.0 / 1440 ) 
		ELSE
			UPDATE  E.ATTEMPT  
			SET RemoveBan = GETDATE() + TRY_CONVERT(INTEGER, @A4) * 1.0 / 1440 , LastAttempt=GETDATE(), IsBanned = 1
			WHERE AddressServer=@ReturnNote AND AddressClient=@A3

		DELETE FROM E.ACCESS WHERE AddressServer=@ReturnNote AND AddressClient=@A3
		
		IF EXISTS(SELECT * FROM E.ATTEMPT WHERE AddressServer=@ReturnNote AND AddressClient=@A3 AND IsBanned != 0 AND RemoveBan > GETDATE() )
		SELECT [dbo].[f_standard_code] ('Указанный вами адрес добавлен в список блокированных.', 0) as ReturnMessage
		ELSE
		SELECT [dbo].[f_standard_code] ('Ошибка! Не удалось заблокировать указанный вами адрес.', 0) as ReturnMessage

	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('Ban') AND @A2=UPPER('Remove')
	BEGIN

	IF @Admin < 1 EXEC dbo.p_error '', 100014

	SELECT @ReturnNote = AddressServer FROM E.ACCESS WHERE ApiKey=@ApiKey

	IF NOT EXISTS(SELECT * FROM E.ATTEMPT WHERE AddressServer=@ReturnNote AND AddressClient=@A3 AND IsBanned != 0 )
		SELECT [dbo].[f_standard_code] ('Ошибка! Указанный вами адрес не найден в списке блокированных.', 0) as ReturnMessage
	ELSE
		BEGIN
			UPDATE  E.ATTEMPT  
			SET RemoveBan = GETDATE(), LastAttempt=GETDATE(), IsBanned = 0, FailureCount = 0
			WHERE AddressServer=@ReturnNote AND AddressClient=@A3
			SELECT [dbo].[f_standard_code] ('Указанный вами адрес разблокирован.', 0) as ReturnMessage
		END

	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('Get') AND @A2=UPPER('My') AND @A3=UPPER('User') AND @A4=UPPER('Id')
	BEGIN
					
		SET @ReturnMessage = '0' ---- Признак того, что возвращаемый код не ошибка ----
		SET @ReturnCode = @IdUser
		SELECT [dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as ReturnMessage
														
	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
	SET @ReturnCode = -1
	SET @ReturnMessage = 'Ошибка! Введённая вами команда не найдена.'
--------------------------------------------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_command] error: A1=' + @A1 + ' A2=' + @A2 + ' A3=' + @A3 + ' A4=' + @A4 + ' A5=' + @A5
	EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

END CATCH 

	SELECT [dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as ReturnMessage
	RETURN @ReturnCode 

END
--------------------------------------------------------------------------------------------------------------------------------------------------

GO

