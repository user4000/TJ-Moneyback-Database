USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.f_remove_spaces(@str varchar(8000))
RETURNS varchar(8000) AS
BEGIN 
    WHILE CHARINDEX('  ', @str) > 0 
        SET @str = REPLACE(@str, '  ', ' ')

    RETURN @str
END
GO

