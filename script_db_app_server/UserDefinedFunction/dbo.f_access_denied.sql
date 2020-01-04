USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_access_denied] ( @Action VARCHAR(100) ) 
RETURNS VARCHAR(100)
AS BEGIN
				RETURN
				
				 CASE UPPER(@Action)
					WHEN 'SELECT' THEN 'Нет доступа на выборку данных'
					WHEN 'INSERT' THEN 'Нет доступа на добавление данных'
					WHEN 'UPDATE' THEN 'Нет доступа на изменение данных'
					WHEN 'DELETE' THEN 'Нет доступа на удаление данных' 
					ELSE ''
				END
END

GO

