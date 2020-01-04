USE [db_app_server]
GO

CREATE TYPE [dbo].[TYPE_CLASSIFICATOR] AS TABLE(
	[IdObject] [int] NOT NULL,
	[IdParent] [int] NOT NULL,
	[CodeObject] [varchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[RankObject] [int] NOT NULL,
	[NameShort] [nvarchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NameObject] [nvarchar](1000) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NoteObject] [nvarchar](4000) COLLATE Cyrillic_General_CS_AI NULL
)
GO

