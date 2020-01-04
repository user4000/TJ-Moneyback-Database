USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_parameter_integer](@name VARCHAR(500)) RETURNS integer
AS
BEGIN

	DECLARE @value integer

	SELECT @value = ValueInteger
	FROM A.PARAMETER
	WHERE ParameterName=@name

	RETURN ISNULL(@value,-1)

END

GO

