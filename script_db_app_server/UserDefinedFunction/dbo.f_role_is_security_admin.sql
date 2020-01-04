USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_role_is_security_admin] ( @IdRole INTEGER ) RETURNS INTEGER AS BEGIN DECLARE

@Result INTEGER = 0

	IF 
		(@IdRole=dbo.f_get_id_by_code('role', 'developer')) OR
		(@IdRole=dbo.f_get_id_by_code('role', 'admin')) OR
		(@IdRole=dbo.f_get_id_by_code('role', 'security')) 
	SET @Result = 1

	RETURN ISNULL(@Result, 0)

END

--SELECT [dbo].[f_is_member] (15,9001)

GO

