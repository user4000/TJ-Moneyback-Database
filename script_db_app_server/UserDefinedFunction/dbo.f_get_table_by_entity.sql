USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[f_get_table_by_entity] ( @CodeObject Varchar(500)) RETURNS VARCHAR(100) AS BEGIN DECLARE

	@TableName VARCHAR(500)

	SELECT @TableName = NameShort FROM A.ENTITY WHERE LOWER(CodeObject) = LOWER(@CodeObject)

	RETURN ISNULL(@TableName, '')

END

GO

