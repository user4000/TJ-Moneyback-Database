USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_is_member] ( @IdUser INTEGER, @IdRole INTEGER ) RETURNS INTEGER AS BEGIN DECLARE

@Result INTEGER = 0

	SELECT @Result = SIGN ( COUNT(*) ) 
	FROM [J].[ROLE_USER] A
		INNER JOIN [T].[USER] B ON A.IdUser=B.IdUser
			WHERE 
			(
			/* ---- */ A.IdRole = @IdRole 
			OR 
			/* ---- */ ( A.IdRole = dbo.f_get_id_by_code('role','admin') AND @IdRole != dbo.f_get_id_by_code('role','developer')  )
			OR 
			/* ---- */ A.IdRole = dbo.f_get_id_by_code('role','developer') 
			) 
			AND 
			B.IdUser = @IdUser 
			AND 
			B.IdStatus = dbo.f_get_id_by_code('status','active')

	
	RETURN ISNULL(@Result, 0)

END

--SELECT [dbo].[f_is_member] (15,9001)

GO

