USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [A].[CLASSIFICATOR] AS
SELECT TOP 100 PERCENT * FROM A.ENTITY 
WHERE Lower(NoteObject) LIKE 'class%'
ORDER BY RankObject, NameObject, IdObject

GO
