USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* 

Проверяет наличие APIKEY: вернет значение

0 если ApiKey существует и его срок действия актуален
1 если ApiKey существует и его срок действия уже истёк
2 если ApiKey не существует

*/

CREATE FUNCTION [dbo].[f_apikey] ( @ApiKey Varchar(100), @AddressServer VARCHAR(100), @AddressClient VARCHAR(100) ) 

RETURNS INTEGER AS BEGIN DECLARE 
--------------------------------------------------------------------------------------------------------------
	@Result INTEGER = 2,
	@Count  INTEGER = 0
--------------------------------------------------------------------------------------------------------------
	SELECT @Count = COUNT(*) FROM E.ACCESS 
		WHERE 
			ApiKey=@ApiKey 
			AND 
			LTRIM(AddressClient)=LTRIM(@AddressClient)	
			AND 
			LTRIM(AddressServer)=LTRIM(@AddressServer)	
			AND
			DATEDIFF(SECOND, TimeEvent, GETDATE()) < dbo.f_parameter_integer('APIKEY_EXPIRATION_SECONDS')

	IF @Count > 0 SET @Result = 0

	IF (@Result != 0)
	BEGIN
	
		SELECT @Count = COUNT(*) FROM E.ACCESS 
			WHERE 
				ApiKey=@ApiKey 
				AND 
				LTRIM(AddressClient)=LTRIM(@AddressClient)	
				AND 
				LTRIM(AddressServer)=LTRIM(@AddressServer)

		IF @Count > 0 SET @Result = 1

	END

	RETURN @Result

END

GO

