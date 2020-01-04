USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_classificator_select] 

	@ApiKey Varchar(100), 
	@EntityName Varchar(100),
	@IdObject Integer = 0

AS BEGIN SET NOCOUNT ON DECLARE 

	@CheckPermission BIT = 1,
	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUser INT = 0,
	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000)

BEGIN TRY

/* ---------------------------------------------------------------------------------------- */
	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)

	IF @IdUser < 0 EXEC dbo.p_error 'Пользователь не найден', 100005

	--IF dbo.f_is_member_of(@IdUser,'security')=1 SET @CheckPermission=0
		
	SET @CheckPermission=0 /* Разрешаем выборку данных из классификаторов всем пользователям ! */

	SET @EntityName = UPPER(@EntityName)

/*
	EXEC dbo.p_event @IdMessage=0, @IdUser=@IdObject, @UserLogin='', @TextEvent=@EntityName, @TextNote='DEBUG' 
*/

--------------------------------------------------------------------------------------------------------------------------
/* -------------------------------------------------------------------------------------------------------------------- */
/*Блок выдачи специализированных справочников (авторизация выключена)                                                   */
/* -------------------------------------------------------------------------------------------------------------------- */
--------------------------------------------------------------------------------------------------------------------------
	IF @EntityName='CLASSIFICATOR' ---- Список классификаторов ----
		BEGIN		
			----EXEC dbo.p_permission @ApiKey, 'role', 'select'	
			SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject 
				FROM A.ENTITY 
					WHERE IdParent = (SELECT IdObject FROM A.ENTITY WHERE Lower(CodeObject)='classificator') 
						ORDER BY RankObject, NameObject, IdObject 														
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------
	IF @EntityName=REPLACE('ROLE INNER', ' ', '') ---- Список заблокированных для редактирования ролей ----
		BEGIN			
			----EXEC dbo.p_permission @ApiKey, 'role', 'select'
			SELECT IdObject, 0 as IdParent, CodeEntity as CodeObject, 0 as RankObject, '' as NameShort, CodeEntity as NameObject, '' as NoteObject 
				FROM A.ENTITY_LOCKED 
					WHERE Lower(CodeEntity)='role'
						ORDER BY RankObject, NameObject, IdObject 														
		RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------
/* -------------------------------------------------------------------------------------------------------------------- */
/* Блок выдачи специализированных справочников (авторизация включена)                                                   */
/* -------------------------------------------------------------------------------------------------------------------- */
--------------------------------------------------------------------------------------------------------------------------
IF @EntityName=REPLACE('ROLE EDITABLE', ' ', '') ---- Список НЕ заблокированных для редактирования ролей ----
BEGIN			
	IF (@CheckPermission=1) EXEC dbo.p_permission @ApiKey, 'role', 'select'
	/*SELECT 0 as IdObject, 0 as IdParent, '.' as CodeObject, 0 as RankObject, '.' as NameShort, '.' as NameObject, '.' as NoteObject
	UNION*/
	SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject 
		FROM [A].[ROLE]
			WHERE IdObject NOT IN (	SELECT IdObject FROM A.ENTITY_LOCKED WHERE Lower(CodeEntity)='role' ) 
				ORDER BY RankObject, NameObject, IdObject 														
RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------
IF @EntityName='UNIT' 
BEGIN
	IF (@CheckPermission=1) EXEC dbo.p_permission @ApiKey, @EntityName, 'select'
	SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject 
		FROM V.UNIT_FORMATTED
			WHERE (IdObject = @IdObject) OR (@IdObject < 1)
				ORDER BY RankObject, IdParent, IdObject
RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------
/* -------------------------------------------------------------------------------------------------------------------- */
/* Блок выдачи общих стандартных справочников (авторизация включена)                                                    */
/* -------------------------------------------------------------------------------------------------------------------- */
--------------------------------------------------------------------------------------------------------------------------	

/* ********************************************************* */
/* Проверка разрешений на выборку данных указанной сущности  */
/* ********************************************************* */
IF (@CheckPermission=1) EXEC dbo.p_permission @ApiKey, @EntityName, 'select'
/* ********************************************************* */

--------------------------------------------------------------------------------------------------------------------------
/* Общие справочники                                                                                                    */
--------------------------------------------------------------------------------------------------------------------------
	SET @TableName = dbo.f_get_table_by_entity(@EntityName)

	IF LEN(@TableName) > 0
	BEGIN
		SET @Sql = 'SELECT IdObject, IdParent, CodeObject, RankObject, NameShort, NameObject, NoteObject ' +
					'FROM ' + @TableName + ' ' +
					'WHERE (IdObject = @IdObject) OR (@IdObject < 1) ' +
					'ORDER BY RankObject, IdParent, IdObject'
		EXEC sp_executesql @Sql, N'@IdObject INT', @IdObject
	RETURN 0 END
--------------------------------------------------------------------------------------------------------------------------	

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = 'Ошибка при выборке данных! ' + ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_classificator_select] error: Entity=' + @EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR)
	
	SET @Sql = @ReturnNote + ';SQL=' + @Sql

	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUser, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@Sql

	/* В случае ошибки выдадим набор строк такого же типа как и в случае обычного выполнения */
	SELECT 
		-1 as IdObject, 
		@ReturnCode as IdParent,
		'' as CodeObject,
		-1 as RankObject,
		'' as NameShort,
		'' as NameObject,
		[dbo].[f_standard_code](@ReturnMessage, @ReturnCode) as NoteObject /* Стандарт кодирования сообщения об ошибке */

---- SELECT @ReturnCode as ReturnCode, 0 as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote

END CATCH RETURN @ReturnCode END

GO

