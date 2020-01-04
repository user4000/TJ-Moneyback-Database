USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_ban_list] @AddressServer Varchar(100)
	
AS BEGIN SET NOCOUNT ON /* Процедура вернёт список забаненных клиентов */

BEGIN TRY

SELECT AddressClient FROM E.ATTEMPT
 WHERE ( AddressServer=@AddressServer OR LEN(@AddressServer) < 2 ) AND IsBanned != 0 AND GETDATE() < RemoveBan
UNION
SELECT '0' as AddressClient FROM (SELECT TOP 1 * FROM [A].[ACTION]) A

END TRY BEGIN CATCH END CATCH RETURN 0 END

--EXEC [dbo].[p_ban_list] @AddressServer=''

GO

