USE [moneyback]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW V.[USER] as 
SELECT * FROM db_app_server.T.[USER]
GO

