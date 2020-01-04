USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_get_word](@text VARCHAR(8000), @separator CHAR(1), @number INTEGER) RETURNS VARCHAR(8000)
AS
BEGIN

DECLARE @L INTEGER = 0
DECLARE @J INTEGER = 1
DECLARE @K INTEGER = 0
DECLARE @C INTEGER = 0
DECLARE @W VARCHAR(8000) = ''

WHILE CHARINDEX ( @separator+@separator , @text , 0) > 0
	BEGIN
		SET @text = REPLACE(@text, @separator+@separator, @separator)
	END

SET @text = @text + @separator
SET @text = REPLACE(@text, @separator+@separator, @separator)
IF CHARINDEX ( @separator , @text , 0) = 1 SET @J = 2

SET @L = LEN(@text) 

WHILE @J <= @L
BEGIN

	SET @K = CHARINDEX ( @separator , @text , @J )  
	
	IF @K > 0 
	BEGIN
		
		SET @C = @C + 1

		IF (@number = @C)
		BEGIN		
			SET @W = SUBSTRING ( @text, @J, @K - @J )	
			BREAK
		END 

		SET @J = @K + 1

	END ELSE BEGIN

		SET @J = @L
		SET @W = ''

	END

END

RETURN @W

END

GO

