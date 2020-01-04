USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [V].[UNIT_LEVEL] AS
SELECT [IdObject]
      ,[IdParent]
      ,[CodeObject]
      ,[RankObject]
      ,[NameShort]
      ,[NameObject]
      ,[NoteObject]
	  ,dbo.f_unit_level(IdObject) as UnitLevel
  FROM [A].[UNIT]


GO

