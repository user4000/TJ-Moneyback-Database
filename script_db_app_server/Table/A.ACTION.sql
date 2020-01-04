USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[ACTION](
	[Action] [varchar](10) COLLATE Cyrillic_General_CS_AI NOT NULL,
 CONSTRAINT [PK_A_ACTION] PRIMARY KEY CLUSTERED 
(
	[Action] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
