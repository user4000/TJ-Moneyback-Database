USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_user_update] 

	@ApiKey VarChar(100),
	@IdObject INTEGER, 
	@ColumnName Varchar(100),
	@CellValue NVarChar(4000)

AS BEGIN SET NOCOUNT ON DECLARE /* Процедура реализует обновление одной ячейки таблицы. При этом возможно удаление пользователя с помощью встроенной команды см. [A].[COMMAND] */

	@EntityName Varchar(100) = 'user',
	@ReturnCode INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',

	@CellValueInteger INTEGER = 0,
	
	@OuterX INTEGER,
	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000),
	@Var NVARCHAR(4000),
	@Error VARCHAR(4000) = '',
	@Quote NVarChar(10) = '',
	@ExecuteUpdate BIT = 1

BEGIN TRY 
	
	/* Проверка разрешений на изменение данных указанной сущности  */
	IF dbo.f_is_member_of([dbo].[f_get_id_by_apikey](@ApiKey),'security')=0 EXEC dbo.p_permission @ApiKey, @EntityName, 'update' 
	/* *********************************************************** */

	SET @TableName = '[T].[USER]' ---- dbo.f_get_table_by_entity(@EntityName)

	IF LEN(@TableName) = 0
	BEGIN
		SET @TableName = 'Не удалось определить имя таблицы для сущности = ' + @EntityName
		EXEC dbo.p_error @TableName, 102004
	END
	-----------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS(SELECT * FROM [T].[USER] WHERE IdUser=@IdObject)
		EXEC dbo.p_error 'Указанный вами пользователь не найден.', 100005
	-----------------------------------------------------------------------------------------------------------------
	IF (@ColumnName NOT IN ('IdUser', 'IdStatus', 'IdUnit', 'IdPosition') ) SET @Quote = ''''
	-----------------------------------------------------------------------------------------------------------------
	IF (@ColumnName IN ('IdUser', 'IdStatus', 'IdUnit', 'IdPosition') ) 
	BEGIN
		SET @Error = 'Указанное значение должно быть целым числом. Значение = ' + RTRIM(LTRIM(@CellValue))
		SET @CellValueInteger = CAST ( RTRIM(LTRIM(@CellValue)) as INTEGER ) 
		SET @Error = ''
	END
	-----------------------------------------------------------------------------------------------------------------
	IF 	(@ColumnName='IdUser') 					
		EXEC dbo.p_error 'Запрещено изменять идентификатор пользователя', 100009
	-----------------------------------------------------------------------------------------------------------------
	IF (@ColumnName = 'IdStatus') AND ( @IdObject=[dbo].[f_get_id_by_apikey] (@ApiKey) )
		EXEC dbo.p_error 'Запрещено изменять статус своей собственной учётной записи', 102028
	-----------------------------------------------------------------------------------------------------------------
	IF (@ColumnName = 'IdStatus') AND ( @CellValueInteger = [dbo].[f_get_id_by_code]('status','deleted') ) 
		IF dbo.f_is_member_of([dbo].[f_get_id_by_apikey](@ApiKey),'security')=0 EXEC dbo.p_permission @ApiKey, @EntityName, 'delete' 
	-----------------------------------------------------------------------------------------------------------------
	IF EXISTS(SELECT * FROM A.ENTITY_LOCKED WHERE CodeEntity=@EntityName and IdObject=@IdObject)
		EXEC dbo.p_error 'Запрещено изменять встроенные объекты информационной системы', 102009

	IF EXISTS(SELECT * FROM A.ENTITY_LOCKED WHERE CodeEntity=@EntityName and IdObject<0)
		EXEC dbo.p_error 'Изменение справочника пользователей заблокировано настройкой системы (см. таблицу ENTITY_LOCKED)', 102030

	/**********************************************************************************************************************************/
	----SET @Sql = 'UPDATE ' + @TableName +	' SET [' + @ColumnName + '] = ' + @Quote + @CellValue + @Quote + ' WHERE (IdObject = @IdObject)'
	----EXEC sp_executesql @Sql, N'@IdObject INT', @IdObject --- this one has vulnerability SQL INJECTION ATTACK to @CellValue variable !!!!!!
	-----------------------------------------------------------------------------------------------------------------------------------	

	--SET @Sql = 'SELECT @OuterX = COUNT(*) FROM ' + @TableName + ' WHERE IdUser=@IdObject'
	--SET @Var = N'@IdObject INT, @OuterX INT OUTPUT'
	--EXEC sp_executesql 	@Sql, @Var, @IdObject, @OuterX = @OuterX OUTPUT
	--IF (@OuterX = 0) EXEC dbo.p_error 'Указанный вами пользователь не найден.', 100005

	-----------------------------------------------------------------------------------------------------------------------------------
	IF (@ColumnName='PasswordHash') /* В этом случае в переменной @CellValue передаётся значение = Хэш + пробел + Соль */
	BEGIN
		SET @ExecuteUpdate=0
		SET @Var = dbo.f_get_word(@CellValue,' ',1) ---- Hash
		SET @Sql = dbo.f_get_word(@CellValue,' ',2) ---- Salt

		SET @Error = 'Ошибка при попытке сменить пароль пользователя!'
		
		IF LEN(@Var) < 512 EXEC dbo.p_error 'Длина хэша меньше 512 символов', 101002
		
		IF LEN(@Sql) < 10  EXEC dbo.p_error 'Длина соли для хэша меньше 10 символов', 101001

		UPDATE [T].[USER] SET PasswordHash = @Var, SaltHash = @Sql WHERE IdUser = @IdObject
		SET @Error = ''
		SET @ReturnMessage = 'Пароль пользователя изменён'
	END
	-----------------------------------------------------------------------------------------------------------------------------------
	IF (@ColumnName='UserNote') AND (LOWER(RTRIM(LTRIM(@CellValue)))='{delete}') 
		IF EXISTS(SELECT * FROM [T].[USER] WHERE IdUser=@IdObject AND IdStatus=[dbo].[f_get_id_by_code]('status','deleted'))
		BEGIN

			SET @Error = 'Ошибка при попытке удаления пользователя!'
			IF dbo.f_is_member_of([dbo].[f_get_id_by_apikey](@ApiKey),'security')=0 EXEC dbo.p_permission @ApiKey, @EntityName, 'delete' 

			SET @OuterX = [dbo].[f_get_id_by_apikey](@ApiKey)
			SELECT @Var = 'User deleted: Login=' + UserLogin + ';Name=' + SurName + ' ' + FirstName + ' ' + UserPatronymic FROM [T].[USER] WHERE IdUser=@IdObject
			SELECT @Sql = 'Operation executed by Login=' + UserLogin + ';Name=' + SurName + ' ' + FirstName + ' ' + UserPatronymic FROM [T].[USER] WHERE IdUser=@OuterX

			DELETE FROM [T].[USER] WHERE IdUser=@IdObject
				
			SET @IdObject=0      ---- Это признак того, что пользователь удалён ----
			SET @ExecuteUpdate=0 ---- Это признак того, что основную команду этой процдуры запускать не надо ----
			SET @Error = ''
					
			EXEC dbo.p_event @IdMessage=200050,	@IdUser=@OuterX, @UserLogin='',	@TextEvent=@Var, @TextNote=@Sql

		END ELSE BEGIN

			SET @TableName = 'Нельзя вводить команду удаления для пользователя, статус которого не равен [Удалён]'
			EXEC dbo.p_error @TableName, 102029

		END

	/**********************************************************************************************************************************/
	IF ( @ExecuteUpdate > 0 )
	BEGIN			
		SET @Sql = 'UPDATE ' + @TableName +	' SET [' + @ColumnName + '] = @CellValue WHERE (IdUser = @IdObject)'
		EXEC sp_executesql @Sql, N'@IdObject INT, @CellValue NVARCHAR(4000)', @IdObject, @CellValue			
	END
	/**********************************************************************************************************************************/
		
	IF ( @ExecuteUpdate > 0 ) AND (@ColumnName = 'IdStatus')
	BEGIN
		SET @OuterX = [dbo].[f_get_id_by_apikey](@ApiKey)
		SELECT @Var = NameObject FROM [A].[STATUS] WHERE CAST(IdObject as VARCHAR)=@CellValue
		SELECT @Var = 'Status=[' + @Var + '] Login=' + UserLogin + ';Name=' + SurName + ' ' + FirstName + ' ' + UserPatronymic FROM [T].[USER] WHERE IdUser=@IdObject
		SELECT @Sql = 'Operation executed by Login=' + UserLogin + ';Name=' + SurName + ' ' + FirstName + ' ' + UserPatronymic FROM [T].[USER] WHERE IdUser=@OuterX
		EXEC dbo.p_event @IdMessage=200051,	@IdUser=@OuterX, @UserLogin='',	@TextEvent=@Var, @TextNote=@Sql
		
		SELECT @Var = NameObject FROM [A].[STATUS] WHERE CAST(IdObject as VARCHAR)=@CellValue
		SET @ReturnMessage = 'Статус пользователя изменён на [' + @Var + ']'
	END	

	IF ( @ExecuteUpdate > 0 ) AND (@ColumnName = 'IdUnit')
		SET @ReturnMessage = 'Подразделение пользователя изменёно'
	
	IF ( @ExecuteUpdate > 0 ) AND (@ColumnName = 'IdPosition')
		SET @ReturnMessage = 'Должность пользователя изменёна'


END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = LTRIM( @Error + ' ' + ERROR_MESSAGE() )
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @OuterX = [dbo].[f_get_id_by_apikey](@ApiKey)
	
	SET @ReturnNote = 'SP [dbo].[p_user_update] error: Entity='+@EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR) + ';ColumnName=' + @ColumnName + ';CellValue=' + @CellValue 
		
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@OuterX, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode 

END


GO

