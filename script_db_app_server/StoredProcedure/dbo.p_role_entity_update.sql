USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_role_entity_update] 

	@ApiKey VarChar(100),
	@IdObject INTEGER, ---------- IdRole
	@EntityName Varchar(100), ---- IdEntity
	@ColumnName Varchar(100), ---- ColumnName
	@CellValue  VarChar(100)  ---- CellValue

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewObject INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',
	
	@IdUser INTEGER,
	@IdRole INTEGER,
	@IdEntity INTEGER,
	@Cell INTEGER,
	@Action INTEGER = 0 ---- 1=select;2=insert;3=update;4=delete

BEGIN TRY 
	
	/* Проверка разрешений на изменение данных указанной сущности  */
	SET @IdUser = [dbo].[f_get_id_by_apikey](@ApiKey)
	IF dbo.f_is_member_of(@IdUser,'security')=0 EXEC dbo.p_permission @ApiKey, 'role', 'update' 
	/* ********************************************************** */

	SET @IdRole = @IdObject

	IF @IdRole=0 EXEC dbo.p_error '', 102012
	IF EXISTS(SELECT * FROM A.ENTITY_LOCKED WHERE CodeEntity='role' and IdObject=@IdRole) EXEC dbo.p_error '', 102012

	SET @IdEntity = ISNULL(TRY_CONVERT(integer, @EntityName),-1)
	SET @Cell = ISNULL(TRY_CONVERT(integer, @CellValue),-1)
	SET @ColumnName = LOWER(@ColumnName)

	IF @Action=0 BEGIN  SET @Action = CHARINDEX('select', @ColumnName) IF @Action > 0 SET @Action=1 END
	IF @Action=0 BEGIN  SET @Action = CHARINDEX('insert', @ColumnName) IF @Action > 0 SET @Action=2 END
	IF @Action=0 BEGIN  SET @Action = CHARINDEX('update', @ColumnName) IF @Action > 0 SET @Action=3 END
	IF @Action=0 BEGIN  SET @Action = CHARINDEX('delete', @ColumnName) IF @Action > 0 SET @Action=4 END

	IF @Action = 0 EXEC dbo.p_error '', 100011
	IF @IdEntity < 0 EXEC dbo.p_error '', 100013
	IF @Cell < 0 EXEC dbo.p_error '', 100013

	IF NOT EXISTS(SELECT * FROM [A].[ROLE] WHERE IdObject=@IdRole)
		EXEC dbo.p_error '', 101014

	IF NOT EXISTS(SELECT * FROM [A].[ENTITY] WHERE IdObject=@IdEntity)
		EXEC dbo.p_error '', 101015

	IF @Cell > 2 EXEC dbo.p_error '', 100012


	IF NOT EXISTS(SELECT * FROM [J].[ROLE_ENTITY] WHERE IdRole=@IdRole AND [IdEntity]=@IdEntity )
		INSERT INTO [J].[ROLE_ENTITY] (IdRole,[IdEntity],ActionSelect, ActionInsert, ActionUpdate, ActionDelete)
			VALUES (@IdRole, @IdEntity, 0, 0, 0, 0)


	IF @Action=1 UPDATE [J].[ROLE_ENTITY] SET ActionSelect=@Cell WHERE IdRole=@IdRole AND [IdEntity]=@IdEntity 
	IF @Action=2 UPDATE [J].[ROLE_ENTITY] SET ActionInsert=@Cell WHERE IdRole=@IdRole AND [IdEntity]=@IdEntity 
	IF @Action=3 UPDATE [J].[ROLE_ENTITY] SET ActionUpdate=@Cell WHERE IdRole=@IdRole AND [IdEntity]=@IdEntity 
	IF @Action=4 UPDATE [J].[ROLE_ENTITY] SET ActionDelete=@Cell WHERE IdRole=@IdRole AND [IdEntity]=@IdEntity 

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_role_entity_update] error: Entity='+@EntityName + ';IdObject=' + CAST(@IdObject as VARCHAR) + ';ColumnName=' + @ColumnName + ';CellValue=' + @CellValue 
		
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUser, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdCreatedNewObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode 

END


GO

