USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[ENTITY_COLUMN](
	[CodeObject] [varchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[ColumnName] [varchar](100) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[ColumnWidth] [int] NOT NULL,
	[ColumnRank] [int] NOT NULL,
 CONSTRAINT [PK_ENTITY_COLUMNS] PRIMARY KEY CLUSTERED 
(
	[CodeObject] ASC,
	[ColumnName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [A].[ENTITY_COLUMN] ADD  CONSTRAINT [DF_ENTITY_COLUMNS_ColumnRank]  DEFAULT ((0)) FOR [ColumnRank]
GO

ALTER TABLE [A].[ENTITY_COLUMN]  WITH CHECK ADD  CONSTRAINT [FK_ENTITY_COLUMNS_ENTITY] FOREIGN KEY([CodeObject])
REFERENCES [A].[ENTITY] ([CodeObject])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [A].[ENTITY_COLUMN] CHECK CONSTRAINT [FK_ENTITY_COLUMNS_ENTITY]
GO

