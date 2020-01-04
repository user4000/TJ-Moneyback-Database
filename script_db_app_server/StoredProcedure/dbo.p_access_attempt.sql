USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_access_attempt] @AddressServer Varchar(100), @AddressClient Varchar(100)
	
AS BEGIN SET NOCOUNT ON /* Процедура увеличивает счётчик несанкционированной попытки доступа и устанавливает отметку БАН при превышении количества допустимых попыток */

DECLARE @Ban INTEGER = 0, @TextEvent VARCHAR(4000)

BEGIN TRY

	SET @AddressServer=LTRIM(RTRIM(@AddressServer))
	SET @AddressClient=LTRIM(RTRIM(@AddressClient))

	IF EXISTS(SELECT * FROM E.ATTEMPT WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient AND IsBanned != 0)
	BEGIN
		
		SELECT @Ban = (ABS(BanCount))*dbo.f_parameter_integer('FIRST_BAN_DURATION_MINUTES') FROM E.ATTEMPT 		 
			WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient

		----UPDATE E.ATTEMPT SET RemoveBan = RemoveBan + 1.0/1440 WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient
	END

	IF @Ban=0 
	BEGIN
	-------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF EXISTS(SELECT * FROM E.ATTEMPT WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient)
		BEGIN

			UPDATE E.ATTEMPT SET FailureCount=ABS(FailureCount)+1, LastAttempt = GETDATE()
				WHERE RTRIM(AddressServer)=@AddressServer AND RTRIM(AddressClient)=@AddressClient

			IF EXISTS
			(
			SELECT * FROM E.ATTEMPT 
			WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient
			AND FailureCount >= dbo.f_parameter_integer('UNAUTHORIZED_ACCESS_ATTEMPTS')
			)
			BEGIN /* В этом блоке мы баним IP-адрес клиента */

				/* В переменной @Ban - количество минут, на которые нужно забанить клиента */
				/* Если при разбане не сбрасывать BanCount до нуля то каждый следующий бан будет на всё больший период */
				SELECT @Ban = (ABS(BanCount)+1)*dbo.f_parameter_integer('FIRST_BAN_DURATION_MINUTES') FROM E.ATTEMPT 
				WHERE AddressServer=@AddressServer AND AddressClient=@AddressClient

				UPDATE E.ATTEMPT 
				SET 
					BanCount = ABS(BanCount)+1, 
					IsBanned = 1, 
					FailureCount = 0,
					RemoveBan = GETDATE() + ABS( 1.0 * @Ban / 1440.0 )
				WHERE RTRIM(AddressServer)=@AddressServer AND RTRIM(AddressClient)=@AddressClient

				/* Заодно удаляем APIKEY клиента если он был */
				DELETE FROM E.ACCESS WHERE RTRIM(AddressServer)=@AddressServer AND RTRIM(AddressClient)=@AddressClient

				SET @TextEvent = 'Server='+@AddressServer+'; Client='+@AddressClient+'; UNAUTHORIZED_ACCESS_ATTEMPTS='+CAST(dbo.f_parameter_integer('UNAUTHORIZED_ACCESS_ATTEMPTS') as VARCHAR)

				EXEC dbo.p_event @IdMessage=111113, @IdUser=0, @UserLogin='', @TextEvent=@TextEvent, @TextNote=''

			END

		END
		ELSE
			INSERT INTO E.ATTEMPT (AddressServer, AddressClient, FailureCount, BanCount, IsBanned)
				VALUES (@AddressServer, @AddressClient, 1, 0, 0)
	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	END

END TRY BEGIN CATCH 
	
END CATCH

IF @@NESTLEVEL < 2
BEGIN
	SELECT @Ban as ReturnCode, @Ban as IdObject, @TextEvent as ReturnMessage, '' as ReturnNote
END

RETURN @Ban

END

GO

