USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_classificator_universal] ---- Result Set = List of CLASSIFICATOR TYPE ----

	@ApiKey Varchar(100), @A1 Varchar(100),	@A2 Varchar(100), @A3 Varchar(100),	@A4 Varchar(100), @A5 Varchar(100)

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@TableName VARCHAR(100),
	@SecurityAdmin INT = 0

BEGIN TRY

/* ---------------------------------------------------------------------------------------- */
	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
	SET @SecurityAdmin = dbo.f_is_member_of(@IdUser,'security')

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
/* ---------------------------------------------------------------------------------------- */
/* Блок выдачи данных без проверки каких-либо разрешений (общедоступные данные)             */
/* ---------------------------------------------------------------------------------------- */

	----EXEC dbo.p_event @IdMessage=0, @IdUser=@IdObject, @UserLogin='', @TextEvent=@EntityName, @TextNote='DEBUG' 

	IF @IdUser < 0 EXEC dbo.p_error 'Пользователь не найден', 100005

--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('List') AND @A2=UPPER('Entity') AND @A3=UPPER('NotForEdit')
		BEGIN		
			SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject 
				FROM A.ENTITY 
					WHERE IdObject IN (SELECT IdObject FROM A.ENTITY_LOCKED WHERE Lower(CodeEntity)='entity') 
						ORDER BY RankObject, NameObject, IdObject 														
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('List') AND @A2=UPPER('Role') AND @A3=UPPER('NotForEdit')
		BEGIN		
			SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject 
				FROM A.[ROLE]
					WHERE IdObject IN (SELECT IdObject FROM A.ENTITY_LOCKED WHERE Lower(CodeEntity)='role') 
						ORDER BY RankObject, NameObject, IdObject 													
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------
	IF @A1=UPPER('List') AND @A2=UPPER('Unit') 
	BEGIN

		IF @SecurityAdmin=0 EXEC dbo.p_permission @ApiKey, 'unit', 'select'

		SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject 
			FROM V.UNIT_FORMATTED			
				ORDER BY RankObject, IdParent, IdObject

	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------------------------------

			SELECT 
				0 as IdObject, 
				-1 as IdParent, 
				'ERROR' as CodeObject, 
				0 as RankObject, 
				'ERROR' as NameShort, 
				'ERROR' as NameObject, 
				[dbo].[f_standard_code] ('Ошибка! Введённая вами команда не найдена.', -1) as NoteObject 


--------------------------------------------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_classificator_universal] error: A1=' + @A1 + ' A2=' + @A2 + ' A3=' + @A3 + ' A4=' + @A4 + ' A5=' + @A5

	EXEC dbo.p_event @IdMessage=@ReturnCode, @IdUser=@IdUser, @UserLogin='', @TextEvent=@ReturnMessage, @TextNote=@ReturnNote

	/* В случае ошибки выдадим набор строк такого же типа как и в случае обычного выполнения */
	SELECT 

		-1 as IdObject, 
		@ReturnCode as IdParent,
		'ERROR' as CodeObject,
		-1 as RankObject,
		'ERROR' as NameShort,
		'ERROR' as NameObject,
		[dbo].[f_standard_code] (@ReturnMessage, @ReturnCode) as NoteObject 

END CATCH RETURN @ReturnCode END
--------------------------------------------------------------------------------------------------------------------------------------------------

GO

