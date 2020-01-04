USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_empty_template] 

	@IdObject INTEGER, 
	@EntityName Varchar(100),
	@ColumnName Varchar(100),
	@Value NVarChar(4000)

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0,
	@IdCreatedNewObject INTEGER = 0,
	@ReturnMessage Varchar(4000) = '',
	@ReturnNote Varchar(4000) = '',

	@TableName VARCHAR(100),
	@Sql NVARCHAR(4000)

BEGIN TRY

	SET @ReturnCode = 1

END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()

END CATCH

SELECT @ReturnCode as ReturnCode, @IdCreatedNewObject as IdObject, @ReturnMessage as ReturnMessage, @ReturnNote RETURN @ReturnCode 


END


GO

