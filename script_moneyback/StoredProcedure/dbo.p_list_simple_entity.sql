USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[p_list_simple_entity] ---- Result Set = IList<Model.TTSimpleEntity> ----
	
	@ApiKey Varchar(8000), @A1 Varchar(8000),	@A2 Varchar(8000), @A3 Varchar(8000),	@A4 Varchar(8000), @A5 Varchar(8000)

AS BEGIN SET NOCOUNT ON DECLARE /* Универсальная многоцелевая процедура для программы moneyback */

	@TransactionStarted BIT = 0,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0
	
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

--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('check_rebalancing') ---- проверим был ли ранее проведен ребалансинг по данному IdSearch ----
		BEGIN ---- здесь @A2 = IdSearch ----

		IF TRY_CAST(@A2 as INT) IS NULL EXEC [db_app_server].dbo.p_error 'Ошибка! Некорректное значение параметра @A2', 100001

		SELECT @ReturnCode = COUNT(*) FROM T.REBALANCING WHERE IdSearch = TRY_CAST(@A2 as INT)

		SELECT @ReturnCode as IdObject, '0' as NameObject
																		
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('list_bank') ---- Список банков ----
		BEGIN 

		----------SELECT 0 as IdObject, ' ' as NameObject ---- Специальное пустое значение ----
		----------UNION
		SELECT IdObject, NameObject FROM
		(
			SELECT TOP 100 PERCENT IdBank as IdObject, BankShortName as NameObject
			FROM A.BANK
			ORDER BY IdBank
		) BANK
																		
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('list_status') ---- Список статусов ----
		BEGIN 

		SELECT IdRequestStatus as IdObject, RequestStatusName as NameObject 
			FROM A.REQUEST_STATUS 
				ORDER BY IdRequestStatus
													
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1 = UPPER('list_user') ---- Список пользователей ----
		BEGIN 

		SELECT IdUser as IdObject, SurName + ' ' + FirstName + ' ' + UserPatronymic as NameObject
			FROM V.[USER] ORDER BY IdUser
													
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------
	SET @ReturnCode = -1
	SET @ReturnMessage = 'Ошибка! Введённая вами команда не найдена.'
--------------------------------------------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	IF @TransactionStarted != 0 IF @@TRANCOUNT > 0 ROLLBACK

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_list_simple_entity] error: A1=' + @A1 + ' A2=' + @A2 + ' A3=' + @A3 + ' A4=' + @A4 + ' A5=' + @A5
	EXEC db_app_server.dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote
	---- [db_app_server].[dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as ReturnMessage

END CATCH 

	SELECT @ReturnCode as IdObject, @ReturnMessage as NameObject RETURN @ReturnCode 

END 
--------------------------------------------------------------------------------------------------------------------------------------------------

GO

