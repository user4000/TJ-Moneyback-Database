USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [V].[ENTITY_COLUMN_RANK2] AS
select  TOP 100 percent
CodeObject, 
ColumnName, 
ColumnWidth, 
ColumnRank 
from [V].[ENTITY_COLUMN_RANK] ORDER BY CodeObject, OldColumnRank

GO

