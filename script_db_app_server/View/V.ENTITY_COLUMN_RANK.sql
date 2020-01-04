USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [V].[ENTITY_COLUMN_RANK] AS
SELECT A.CodeObject, A.ColumnName, A.ColumnWidth, R2-R1+1 as ColumnRank, OldColumnRank FROM
(
select TOP 100 percent *, 
RANK() OVER (ORDER BY CodeObject) as R1,
ROW_NUMBER() OVER (ORDER BY CodeObject) as R2
from 
(SELECT TOP 100 PERCENT *, ColumnRank as OldColumnRank FROM A.ENTITY_COLUMN ORDER BY CodeObject, ColumnRank) R3
where ColumnRank >= 0 AND ColumnWidth > 0
ORDER BY ColumnRank
) A



GO

