USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [E].[ATTEMPT](
	[AddressServer] [varchar](21) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[AddressClient] [varchar](15) COLLATE Cyrillic_General_CS_AI NOT NULL,
	[FailureCount] [int] NOT NULL,
	[BanCount] [int] NOT NULL,
	[IsBanned] [tinyint] NOT NULL,
	[LastAttempt] [datetime] NOT NULL,
	[RemoveBan] [datetime] NOT NULL,
 CONSTRAINT [PK_ATTEMPT] PRIMARY KEY CLUSTERED 
(
	[AddressServer] ASC,
	[AddressClient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [E].[ATTEMPT] ADD  CONSTRAINT [DF_ATTEMPT_FailureCount]  DEFAULT ((0)) FOR [FailureCount]
GO

ALTER TABLE [E].[ATTEMPT] ADD  CONSTRAINT [DF_ATTEMPT_BanCount]  DEFAULT ((0)) FOR [BanCount]
GO

ALTER TABLE [E].[ATTEMPT] ADD  CONSTRAINT [DF_ATTEMPT_IsBanned]  DEFAULT ((0)) FOR [IsBanned]
GO

ALTER TABLE [E].[ATTEMPT] ADD  CONSTRAINT [DF_ATTEMPT_LastAttempt]  DEFAULT (getdate()) FOR [LastAttempt]
GO

ALTER TABLE [E].[ATTEMPT] ADD  CONSTRAINT [DF_ATTEMPT_RemoveBan]  DEFAULT (getdate()) FOR [RemoveBan]
GO

