USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[UNIT](
	[IdObject] [int] NOT NULL,
	[IdParent] [int] NOT NULL,
	[CodeObject] [varchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[RankObject] [int] NOT NULL,
	[NameShort] [nvarchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NameObject] [nvarchar](1000) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NoteObject] [nvarchar](4000) COLLATE Cyrillic_General_CS_AI NULL,
 CONSTRAINT [PK_A_UNIT] PRIMARY KEY CLUSTERED 
(
	[IdObject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
 CONSTRAINT [UK_UNIT] UNIQUE NONCLUSTERED 
(
	[CodeObject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [A].[UNIT] ADD  CONSTRAINT [DF_UNIT_IdParent]  DEFAULT ((0)) FOR [IdParent]
GO

ALTER TABLE [A].[UNIT] ADD  CONSTRAINT [DF_UNIT_RankObject]  DEFAULT ((0)) FOR [RankObject]
GO

ALTER TABLE [A].[UNIT] ADD  CONSTRAINT [DF_UNIT_NameShort]  DEFAULT ('') FOR [NameShort]
GO

ALTER TABLE [A].[UNIT]  WITH CHECK ADD  CONSTRAINT [FK_UNIT_UNIT] FOREIGN KEY([IdParent])
REFERENCES [A].[UNIT] ([IdObject])
GO

ALTER TABLE [A].[UNIT] CHECK CONSTRAINT [FK_UNIT_UNIT]
GO

