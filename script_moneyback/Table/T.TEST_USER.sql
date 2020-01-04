USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [T].[TEST_USER](
	[IdUser] [int] NOT NULL,
	[FlagActive] [bit] NOT NULL,
 CONSTRAINT [PK_Table_TEST_USER] PRIMARY KEY CLUSTERED 
(
	[IdUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [T].[TEST_USER] ADD  CONSTRAINT [DF_T_FlagActive]  DEFAULT ((1)) FOR [FlagActive]
GO

