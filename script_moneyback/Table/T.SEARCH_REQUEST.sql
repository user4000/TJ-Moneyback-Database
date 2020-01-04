USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [T].[SEARCH_REQUEST](
	[IdSearch] [int] IDENTITY(1,1) NOT NULL,
	[GuidSearch] [varchar](50) COLLATE Cyrillic_General_CI_AI NOT NULL,
	[IdUser] [int] NOT NULL,
	[DateStart] [datetime] NOT NULL,
	[DateEnd] [datetime] NULL,
	[PhoneNumber] [int] NULL,
	[AccountNumber] [int] NULL,
	[PassportNumber] [nvarchar](50) COLLATE Cyrillic_General_CI_AI NULL,
	[ClientName] [nvarchar](50) COLLATE Cyrillic_General_CI_AI NULL,
 CONSTRAINT [PK_SEARCH] PRIMARY KEY CLUSTERED 
(
	[IdSearch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [T].[SEARCH_REQUEST] ADD  CONSTRAINT [DF_SEARCH_REQUEST_GuidSearch]  DEFAULT ('?') FOR [GuidSearch]
GO

ALTER TABLE [T].[SEARCH_REQUEST] ADD  CONSTRAINT [DF_T_SEARCH_DateStart]  DEFAULT (getdate()) FOR [DateStart]
GO

