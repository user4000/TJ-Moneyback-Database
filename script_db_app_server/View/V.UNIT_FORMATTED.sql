USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [V].[UNIT_FORMATTED] AS
SELECT [IdObject]
      ,[IdParent]
      ,[CodeObject]
      ,[RankObject]
      ,[NameShort]
      , CASE WHEN (UnitLevel > 1) THEN SPACE(UnitLevel) ELSE '' END + [NameObject] as NameObject
      ,[NoteObject]
  FROM [V].[UNIT_LEVEL] 


GO

