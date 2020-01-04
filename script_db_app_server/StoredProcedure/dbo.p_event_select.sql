USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_event_select] 

	@ApiKey Varchar(100), 
	@Command Varchar(100),
	@IdUser Integer,
	@RowCount Integer = 0,
	@Day Integer = 0 ---- YYYYMMDD format

AS BEGIN SET NOCOUNT ON DECLARE 

	@ReturnCode INTEGER = 0, 
	@ReturnMessage VARCHAR(4000) = '',
	@ReturnNote VARCHAR(4000) = '',
	@IdUserInvoker INT = 0,
	@TableName VARCHAR(100)

BEGIN TRY
	
SET @Command = UPPER(@Command)
SET @IdUserInvoker = [dbo].[f_get_id_by_apikey](@ApiKey)

IF @RowCount = 0 SET @RowCount = 100000

/*
	SET @ReturnMessage = 
	'DEBUG: @RowCount = ' + CAST(@RowCount as VARCHAR) +
	'Command = ' + @Command +
	'IdUser = ' + CAST(@IdUser as VARCHAR) +
	'Day = ' + CAST(@Day as VARCHAR) 

	EXEC dbo.p_event 
		@IdMessage=0, 
		@IdUser=@IdUserInvoker, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote='DEBUG PROCEDURE [p_event_select]'
*/

IF @Command = '' SET @Command = 'USER_EVENTS'
IF @Command = 'USER_EVENTS' AND @IdUser=0 SET @Command = 'ALL_EVENTS'

--------------------------------------------------------------------------------------------------------------
IF @Command='USER_HIS_OWN_EVENTS' ---- Пользователь просматривает свои собственные события ----
BEGIN
	
	SELECT [IdEvent],[TimeEvent],[IdMessage],[IdUser],[UserLogin],[UserFullName],[TextMessage],[TextEvent],[TextNote]
	FROM 
	(
	SELECT TOP(@RowCount) * FROM [V].[EVENT] 
	WHERE 
		IdUser=@IdUserInvoker 
		AND
		( [dbo].[f_date_to_int]([TimeEvent]) <= @Day OR @Day=0 )
	ORDER BY IdEvent DESC
	) A
	ORDER BY IdEvent DESC

RETURN 0 END
--------------------------------------------------------------------------------------------------------------
IF [dbo].[f_is_member_of](@IdUserInvoker,'security')=0 EXEC dbo.p_error '', 102013
--------------------------------------------------------------------------------------------------------------
IF @Command='USER_EVENTS'
BEGIN

	SELECT [IdEvent],[TimeEvent],[IdMessage],[IdUser],[UserLogin],[UserFullName],[TextMessage],[TextEvent],[TextNote]
	FROM 
	(
	SELECT TOP(@RowCount) * FROM [V].[EVENT] 
	WHERE 
		IdUser=@IdUser
		AND
		( [dbo].[f_date_to_int]([TimeEvent]) <= @Day OR @Day=0 )
	ORDER BY IdEvent DESC
	) A
	ORDER BY IdEvent DESC

RETURN 0 END
--------------------------------------------------------------------------------------------------------------
IF @Command='ALL_EVENTS'
BEGIN

	SELECT [IdEvent],[TimeEvent],[IdMessage],[IdUser],[UserLogin],[UserFullName],[TextMessage],[TextEvent],[TextNote]
	FROM 
	(
	SELECT TOP(@RowCount) * FROM [V].[EVENT] 
	WHERE 
		( [dbo].[f_date_to_int]([TimeEvent]) <= @Day OR @Day=0 )
	ORDER BY IdEvent DESC
	) A
	ORDER BY IdEvent DESC

RETURN 0 END
--------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
END TRY BEGIN CATCH 

	SET @ReturnCode = ERROR_NUMBER()
	SET @ReturnMessage = ERROR_MESSAGE()
	IF (@ReturnCode=0) SET @ReturnCode = 100001

	SET @ReturnNote = 'SP [dbo].[p_event_select] error: Command=' + @Command 
		+ ';RowCount=' + CAST(@RowCount as VARCHAR) 
		+ ';IdUserInvoker=' + CAST(@IdUserInvoker as VARCHAR)
		+ ';IdUser=' + CAST(@IdUser as VARCHAR)

	EXEC dbo.p_event 
		@IdMessage=@ReturnCode, 
		@IdUser=@IdUserInvoker, 
		@UserLogin='', 
		@TextEvent=@ReturnMessage, 
		@TextNote=@ReturnNote

	SELECT 
		-1 as [IdEvent],
		GETDATE() as [TimeEvent],
		-1 as [IdMessage],
		-1 as [IdUser],
		'' as [UserLogin],
		'' as [UserFullName],
		'' as [TextMessage],
		'' as [TextEvent],
		[dbo].[f_standard_code](@ReturnMessage, @ReturnCode) as [TextNote]

END CATCH RETURN @ReturnCode END

GO

