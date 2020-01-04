USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_unit_level] ( @IdUnit INTEGER )
RETURNS INT
AS
BEGIN
	DECLARE @f INTEGER = 0
	IF @IdUnit > 0  
	BEGIN
		SELECT @f = IdParent FROM A.UNIT WHERE IdObject=@IdUnit
		SET @f = dbo.f_unit_level(@f)+1
	END 
	RETURN (@f)
END

GO

