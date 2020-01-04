USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_is_member_of] ( @IdUser INTEGER, @Role VARCHAR(100) ) RETURNS INTEGER AS BEGIN 

	RETURN [dbo].[f_is_member]( @IdUser,  dbo.f_get_id_by_code('role', @Role) )

END

GO

