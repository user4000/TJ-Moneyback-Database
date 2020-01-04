USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_is_banned] @AddressServer Varchar(100), @AddressClient Varchar(100)
	
AS BEGIN SET NOCOUNT ON /* Процедура вернёт код возврата = 0 если клиент НЕ забанен или бан истёк иначе вернёт = 1 */

DECLARE 

	@Ban INTEGER = 0, @Minutes INTEGER = 0,  @TextEvent VARCHAR(4000) = '', @now DATETIME = GETDATE()

BEGIN TRY

IF EXISTS
(
SELECT * FROM E.ATTEMPT 
WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient AND IsBanned > 0 AND @now < RemoveBan
)
	SELECT 
		@Ban=1, 
		@TextEvent='Your ip address is banned for ' + DATEDIFF(MINUTE,@now, RemoveBan) + ' minutes.', 
		@Minutes = DATEDIFF(MINUTE, @now, RemoveBan)
	FROM E.ATTEMPT WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient AND IsBanned > 0 AND @now < RemoveBan

ELSE

	IF EXISTS
	(
	SELECT * FROM E.ATTEMPT 
	WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient AND IsBanned > 0 AND @now >= RemoveBan
	)
		---- Если здесь не сделать BanCount=0 то все последующие баны период блокирования будет возрастать линейно ----
		UPDATE  E.ATTEMPT SET IsBanned=0, BanCount=0 
		WHERE  RTRIM(AddressServer)=@AddressServer AND RTRIM(AddressClient)=@AddressClient AND IsBanned != 0 AND @now >= RemoveBan





---- Если здесь не сделать BanCount=0 то все последующие баны период блокирования будет возрастать линейно ----
IF LEN(@AddressServer) < 2 AND LEN(@AddressClient) < 2 /* Провести разбан тех у кого истёк срок бана */
	UPDATE  E.ATTEMPT SET IsBanned=0, BanCount=0 WHERE IsBanned != 0 AND @now >= RemoveBan



END TRY BEGIN CATCH 
	
END CATCH

IF @@NESTLEVEL < 2
BEGIN
	SELECT @Ban as ReturnCode, @Minutes as IdObject, @TextEvent as ReturnMessage, '' as ReturnNote
END

RETURN @Ban

END

GO

