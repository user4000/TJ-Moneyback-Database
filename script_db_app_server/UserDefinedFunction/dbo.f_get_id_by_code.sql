USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_get_id_by_code](@entity VARCHAR(100), @code VARCHAR(100)) RETURNS INTEGER
AS
BEGIN

	DECLARE @value INTEGER = -1

	SET @entity = UPPER(@entity)

	IF @entity = 'STATUS'
		SELECT @value = IdObject FROM [A].[STATUS] WHERE CodeObject = @code

	IF @entity = 'ENTITY'
		SELECT @value = IdObject FROM [A].[ENTITY] WHERE CodeObject = @code

	IF @entity = 'ROLE'
		SELECT @value = IdObject FROM [A].[ROLE] WHERE CodeObject = @code

	IF @entity = 'USER'
		SELECT @value = IdUser FROM [T].[USER] WHERE UserLogin = @code

	RETURN ISNULL(@value,-1)

END

GO

