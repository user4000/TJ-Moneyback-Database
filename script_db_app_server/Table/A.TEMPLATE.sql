USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[TEMPLATE](
	[IdObject] [int] NOT NULL,
	[IdParent] [int] NOT NULL,
	[CodeObject] [varchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[RankObject] [int] NOT NULL,
	[NameShort] [nvarchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NameObject] [nvarchar](1000) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[NoteObject] [nvarchar](4000) COLLATE Cyrillic_General_CS_AI NULL,
 CONSTRAINT [PK_A_TEMPLATE] PRIMARY KEY CLUSTERED 
(
	[IdObject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
 CONSTRAINT [UK_TEMPLATE] UNIQUE NONCLUSTERED 
(
	[CodeObject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [A].[TEMPLATE] ADD  CONSTRAINT [DF_TEMPLATE_IdParent]  DEFAULT ((0)) FOR [IdParent]
GO

ALTER TABLE [A].[TEMPLATE] ADD  CONSTRAINT [DF_TEMPLATE_RankObject]  DEFAULT ((0)) FOR [RankObject]
GO

ALTER TABLE [A].[TEMPLATE] ADD  CONSTRAINT [DF_TEMPLATE_NameShort]  DEFAULT ('') FOR [NameShort]
GO

ALTER TABLE [A].[TEMPLATE]  WITH CHECK ADD  CONSTRAINT [FK_A_TEMPLATE] FOREIGN KEY([IdParent])
REFERENCES [A].[TEMPLATE] ([IdObject])
GO

ALTER TABLE [A].[TEMPLATE] CHECK CONSTRAINT [FK_A_TEMPLATE]
GO

