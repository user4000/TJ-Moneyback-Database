USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_get_id_by_apikey] 
( @ApiKey Varchar(32) ) 
RETURNS INTEGER AS BEGIN DECLARE

@IdUser INTEGER = -1,
@Result INTEGER = 0

	SELECT @IdUser = A.IdUser FROM [E].[ACCESS] A
		INNER JOIN [T].[USER] B ON A.IdUser=B.IdUser
			WHERE A.ApiKey=@ApiKey ----AND B.IdStatus = dbo.f_get_id_by_code('status','active')


	RETURN ISNULL(@IdUser, -1)

END

GO

