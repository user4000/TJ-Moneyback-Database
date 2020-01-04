USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_standard_code] ( @Message VARCHAR(3950), @Code INTEGER = 0 ) 
RETURNS VARCHAR(4000) /* Стандарт передачи сообщения об ошибке или успехе в тексте. Клиент может определить наличие такого текста даже без десериализации JSON  */
AS BEGIN
 RETURN ( '<<(<<' + RTRIM(LTRIM(@Message)) + '>>)>>' + ' ' + '<(<(<' + CAST(ISNULL(@Code,0) as VARCHAR) + '>)>)>' )
END

GO

