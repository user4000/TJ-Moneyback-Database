USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_parameter_string](@name VARCHAR(500)) RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @value VARCHAR(100)

	SELECT @value = ValueString
	FROM A.PARAMETER
	WHERE ParameterName=@name

	RETURN ISNULL(@value,'')

END

GO

