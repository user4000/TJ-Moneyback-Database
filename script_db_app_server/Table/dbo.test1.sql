USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[test1](
	[id] [int] NOT NULL,
	[textname] [nchar](10) COLLATE Cyrillic_General_CS_AI NOT NULL
)

GO

