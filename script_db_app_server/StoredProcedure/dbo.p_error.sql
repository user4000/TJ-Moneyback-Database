USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_error] ---- PROCEDURE RAISES AN ERROR ----
@error_message VARCHAR(8000),
@error_code INTEGER = 50001
AS BEGIN SET NOCOUNT ON;

	DECLARE @CODE INT = @error_code

	IF (@error_code < 50001) SET @CODE = 900000 + ABS(@error_code)

	IF (LEN (@error_message) < 1 ) 
	 BEGIN
		SELECT @error_message = TextMessage FROM [A].[MESSAGE] WHERE IdMessage = @error_code
		SET @error_message = ISNULL(@error_message,'Error!')
	 END
		
	;THROW @CODE, @error_message, 1; RETURN(@CODE)

END


GO

