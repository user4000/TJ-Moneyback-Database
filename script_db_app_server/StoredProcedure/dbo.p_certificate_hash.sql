USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_certificate_hash] 
/* 
Процедура производит следующие действия: 
[1]-Получает Хэш сертификата HTTP-Сервера 
[2]-Сохраняет Хэш сертификата HTTP-Сервера   
*/

	@ApiKey Varchar(100), 
	@ServerIpAddress Varchar(100),
	@Port Integer,
	@ClientIpAddress Varchar(100),
	@Action Varchar(50), ---- Множество значений = { "SELECT", "INSERT" }
	@CertificateHash Varchar(200) = ''

AS BEGIN SET NOCOUNT ON 

DECLARE 

@ReturnCode INTEGER = 0,
@IdObject INTEGER = 0,
@ReturnMessage Varchar(4000) = '',
@ReturnNote Varchar(4000) = ''

BEGIN TRY

/*
Операцию INSERT производит HTTP-Server
Операцию SELECT производит HTTP-Client (отправляя запрос на HTTP-Server)
*/

	SET @Action = UPPER(@Action)
	SET @CertificateHash = UPPER(@CertificateHash)

	--IF (@Action='SELECT') EXEC dbo.p_permission @ApiKey, 'certificate_hash', @Action
	
	IF @Action='SELECT' 
	BEGIN
			SELECT @ReturnMessage = CertificateHash 
				FROM T.CERTIFICATE_HASH	
					WHERE IpAddress = @ServerIpAddress AND Port=@Port

			IF ISNULL(@ReturnMessage,'')='' OR LEN(@ReturnMessage) < 1 SET @ReturnCode = 100007
	END

	IF @Action='INSERT'  
		IF EXISTS(SELECT * FROM T.CERTIFICATE_HASH WHERE IpAddress=@ServerIpAddress AND Port=@Port)
			UPDATE T.CERTIFICATE_HASH SET CertificateHash=@CertificateHash, TimePoint = GETDATE() 
				WHERE IpAddress=@ServerIpAddress AND Port=@Port AND CertificateHash != @CertificateHash
		ELSE
			INSERT INTO T.CERTIFICATE_HASH (IpAddress, Port, CertificateHash) 
			VALUES(@ServerIpAddress, @Port, @CertificateHash)
						
END TRY 
BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = CAST(@ReturnCode as VARCHAR) + ' ' + ERROR_MESSAGE()

	SET @ReturnNote = 'SP [dbo].[p_certificate_hash] error: Server=' 
	+ @ServerIpAddress + ':' + CAST(@Port as VARCHAR) + ';Client=' + @ClientIpAddress + ';ApiKey='+@ApiKey + ';Action='+@Action+';CertHash='+@CertificateHash
	
	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=0, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

END CATCH

SELECT @ReturnCode as ReturnCode, @IdObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote as ReturnNote
RETURN @ReturnCode  

END 


GO

