USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[STATUS](
	[IdObject] [int] NOT NULL,
	[IdParent] [int] NOT NULL,
	[CodeObject] [varchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[RankObject] [int] NOT NULL,
	[NameShort] [nvarchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NameObject] [nvarchar](1000) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NoteObject] [nvarchar](4000) COLLATE Cyrillic_General_CS_AI NULL,
 CONSTRAINT [PK_A_STATUS] PRIMARY KEY CLUSTERED 
(
	[IdObject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
 CONSTRAINT [UK_STATUS] UNIQUE NONCLUSTERED 
(
	[CodeObject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [A].[STATUS] ADD  CONSTRAINT [DF_STATUS_IdParent]  DEFAULT ((0)) FOR [IdParent]
GO

ALTER TABLE [A].[STATUS] ADD  CONSTRAINT [DF_STATUS_RankObject]  DEFAULT ((0)) FOR [RankObject]
GO

ALTER TABLE [A].[STATUS] ADD  CONSTRAINT [DF_STATUS_NameShort]  DEFAULT ('') FOR [NameShort]
GO

