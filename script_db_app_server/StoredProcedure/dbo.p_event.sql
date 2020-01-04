USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[p_event]    Script Date: 10.12.2018 8:56:44 ******/

CREATE PROCEDURE [dbo].[p_event]

	@IdMessage INT = 0,
	@IdUser INT = 0,
	@UserLogin varchar(50) = '',
	@TextEvent varchar(4000) = '',
	@TextNote varchar(4000) = ''
	
AS BEGIN SET NOCOUNT ON

DECLARE @IdUserChecked INT = ISNULL( (SELECT IdUser FROM T.[USER] WHERE IdUser=@IdUser), 0)
	
	IF @UserLogin != '' SET @IdUser = ISNULL( (SELECT IdUser FROM T.[USER] WHERE UserLogin=@UserLogin), @IdUserChecked)
	IF @IdMessage < 0   SET @IdMessage = 0
	IF (@IdMessage > 0) AND NOT EXISTS(SELECT * FROM A.MESSAGE WHERE IdMessage=@IdMessage) SET @IdMessage = 100001

	BEGIN TRY
		INSERT INTO [E].[EVENT] (IdMessage, IdUser, TextEvent, TextNote)
		VALUES (@IdMessage, @IdUser, @TextEvent, @TextNote)
	END TRY BEGIN CATCH END CATCH

END


GO

