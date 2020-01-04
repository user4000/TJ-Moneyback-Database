USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [A].[BANK](
	[IdBank] [int] NOT NULL,
	[BankName] [varchar](100) COLLATE Cyrillic_General_CI_AI NOT NULL,
	[BikCode] [int] NOT NULL,
	[Mfo] [int] NOT NULL,
	[BankShortName] [varchar](50) COLLATE Cyrillic_General_CI_AI NOT NULL,
	[CorrAccount] [varchar](25) COLLATE Cyrillic_General_CI_AI NULL,
	[TaxNumber] [varchar](20) COLLATE Cyrillic_General_CI_AI NULL,
	[Filial] [int] NOT NULL,
 CONSTRAINT [PK_A_BANK] PRIMARY KEY CLUSTERED 
(
	[IdBank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

