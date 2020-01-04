USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[f_date_to_string] ( @Date  DATETIME ) RETURNS VARCHAR(8) AS BEGIN 

	RETURN (CONVERT(VARCHAR, @Date, 120))

END

GO

