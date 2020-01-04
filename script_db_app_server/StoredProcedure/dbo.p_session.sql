USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_session] @UserLogin Varchar(100) = ''
	
AS BEGIN SET NOCOUNT ON 

DECLARE 

@ReturnCode INTEGER = -1,
@CodeSession VARCHAR(100) = '',
@BinaryData varbinary(max)

BEGIN TRY
	
	SET @BinaryData = crypt_gen_random (32)
	SET @CodeSession = cast('' as xml).value('xs:hexBinary(sql:variable("@BinaryData"))', 'varchar(max)') --REPLACE(NEWID(),'-','')
	IF (@UserLogin='') 
	BEGIN 
	SET @UserLogin = ORIGINAL_LOGIN() 
	END

	DELETE FROM T.[SESSION] WHERE TimeLogin < GETDATE()-7

	INSERT INTO T.[SESSION] 
		(UserLogin, CodeSession)
		VALUES        
		(@UserLogin, @CodeSession)

	SET @ReturnCode = 0

END TRY BEGIN CATCH END CATCH

SELECT @ReturnCode as ReturnCode, 0 as IdObject, @CodeSession as ReturnMessage, '' as ReturnNote

RETURN @ReturnCode

END


GO

