USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_permission]  /* Проверяем доступ пользователя к данным */

@ApiKey Varchar(32), @Entity VARCHAR(100), @Action VARCHAR(100) 

AS BEGIN SET NOCOUNT ON DECLARE 

@IdStatus INTEGER = -1,
@IdUser INTEGER = -1,
@Result INTEGER = 0,
@Error VARCHAR(100),
@Now DATETIME = GETDATE()

	-----------------------------------------------------------------------------------------------------------------------------------
	SELECT @IdUser = A.IdUser, @IdStatus = B.IdStatus FROM [E].[ACCESS] A
		INNER JOIN [T].[USER] B ON A.IdUser=B.IdUser
			WHERE A.ApiKey=@ApiKey ----AND B.IdStatus = dbo.f_get_id_by_code('status','active')
	-----------------------------------------------------------------------------------------------------------------------------------
	IF ( ISNULL(@IdUser,-1) < 0 ) EXEC dbo.p_error 'Пользователь не найден', 100005
	-----------------------------------------------------------------------------------------------------------------------------------
	IF @IdStatus != dbo.f_get_id_by_code('status','active') EXEC dbo.p_error 'Пользователь не является активным', 100004
	-----------------------------------------------------------------------------------------------------------------------------------
	SELECT @Result = SIGN( COUNT(*) ) ---- Проверяем наличие явного разрешения ----
		FROM		
		( 
			SELECT IdRole 
			FROM J.ROLE_USER 
			WHERE 
			IdUser=@IdUser 
			----and GrantStart <= @Now and GrantEnd > @Now
			----and ( NOT(DenyStart <= @Now and DenyEnd > @Now)  )
		) A
		INNER JOIN  ( SELECT * FROM J.ROLE_ENTITY WHERE [IdEntity]=dbo.f_get_id_by_code('entity', @Entity) ) B
			ON A.IdRole = B.IdRole
			WHERE 
				CASE UPPER(@Action)
					WHEN 'SELECT' THEN B.ActionSelect
					WHEN 'INSERT' THEN B.ActionInsert
					WHEN 'UPDATE' THEN B.ActionUpdate
					WHEN 'DELETE' THEN B.ActionDelete
				END = 1
	-----------------------------------------------------------------------------------------------------------------------------------
	IF @Result = 0 IF dbo.f_is_member_of(@IdUser,'admin') = 1 SET @Result = 1
	-----------------------------------------------------------------------------------------------------------------------------------
	IF @Result > 0
	IF EXISTS ---- Проверяем наличие явного запрета ----
			(
			SELECT * FROM
			J.ROLE_USER A
			INNER JOIN  ( SELECT * FROM J.ROLE_ENTITY WHERE [IdEntity]=dbo.f_get_id_by_code('entity', @Entity) ) B
				ON A.IdRole = B.IdRole
				WHERE 
					A.IdUser=@IdUser 
					AND
					CASE UPPER(@Action)
						WHEN 'SELECT' THEN B.ActionSelect
						WHEN 'INSERT' THEN B.ActionInsert
						WHEN 'UPDATE' THEN B.ActionUpdate
						WHEN 'DELETE' THEN B.ActionDelete
					END = 2
			)
			BEGIN
			SET @Result = 0
			END
	-----------------------------------------------------------------------------------------------------------------------------------
	IF @Result = 0 IF dbo.f_is_member_of(@IdUser,'developer' ) = 1 SET @Result = 1
	-----------------------------------------------------------------------------------------------------------------------------------
	IF @Result = 0
	BEGIN 
		SET @Error = dbo.f_access_denied(@Action)
		EXEC dbo.p_error @Error, 100002
	END
	-----------------------------------------------------------------------------------------------------------------------------------

END


GO

