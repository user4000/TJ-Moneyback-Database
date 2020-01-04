USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[dtproperties](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[objectid] [int] NULL,
	[property] [varchar](64) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[value] [varchar](255) COLLATE Cyrillic_General_CS_AI NULL,
	[uvalue] [nvarchar](255) COLLATE Cyrillic_General_CS_AI NULL,
	[lvalue] [image] NULL,
	[version] [int] NOT NULL,
 CONSTRAINT [pk_dtproperties] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[property] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [dbo].[dtproperties] ADD  CONSTRAINT [DF__dtpropert__versi__5F141958]  DEFAULT ((0)) FOR [version]
GO

