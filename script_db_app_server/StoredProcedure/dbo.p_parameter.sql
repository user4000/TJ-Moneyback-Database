USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_parameter] @ParameterName varchar(200)
	
AS BEGIN SET NOCOUNT ON DECLARE 

@ReturnCode INTEGER = 100007,
@ValueInteger INTEGER = -1,
@ValueString VARCHAR(4000) = '',
@ParameterNote VARCHAR(8000) = ''

BEGIN TRY /* ================================================================================================== */

	IF EXISTS(SELECT * FROM [A].[PARAMETER] WHERE ParameterName = @ParameterName)
	BEGIN

		SELECT @ValueInteger=ValueInteger, @ValueString=ValueString, @ParameterName=ParameterName
		FROM [A].[PARAMETER]
		WHERE ParameterName = @ParameterName

		SET @ReturnCode = 0

	END
	
END TRY BEGIN CATCH /* ---------------------------------------------------------------------------------------- */

	SET @ReturnCode = ERROR_NUMBER()
	SET @ValueString = @ValueString + ' ' + ERROR_MESSAGE()

END CATCH /* ================================================================================================== */

SELECT 
	@ReturnCode as ReturnCode, 
	@ValueInteger as IdObject, 
	@ValueString as ReturnMessage, 
	@ParameterNote as ReturnNote

RETURN @ReturnCode

END


GO

