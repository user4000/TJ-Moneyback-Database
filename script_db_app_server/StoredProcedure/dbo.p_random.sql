USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SELECT FLOOR(RAND()*(5-3+1))+3


CREATE PROCEDURE [dbo].[p_random] @a int, @b int
AS begin return FLOOR(RAND()*(@b-@a+1))+@a end


GO

