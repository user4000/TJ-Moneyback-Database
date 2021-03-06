USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[COMMAND_HINT](
	[IdCommandHint] [int] IDENTITY(1,1) NOT NULL,
	[CommandHint] [varchar](500) COLLATE Cyrillic_General_CS_AI NOT NULL,
 CONSTRAINT [PK_COMMAND_HINT] PRIMARY KEY CLUSTERED 
(
	[IdCommandHint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

