USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[p_entity_column_list] AS BEGIN SET NOCOUNT ON  

SELECT TOP 100 percent CodeObject, ColumnName, ColumnWidth, ColumnRank FROM
	(
		SELECT A.CodeObject, A.ColumnName, A.ColumnWidth, R2-R1+1 as ColumnRank, OldColumnRank FROM
		(
		select TOP 100 percent *, 
		RANK() OVER (ORDER BY CodeObject) as R1,
		ROW_NUMBER() OVER (ORDER BY CodeObject) as R2
		from 
			(
			SELECT TOP 100 PERCENT CodeObject, ColumnName, ColumnWidth, ColumnRank as OldColumnRank 
			FROM A.ENTITY_COLUMN 
			ORDER BY CodeObject, ColumnRank
			) B
		where OldColumnRank >= 0 AND ColumnWidth > 0
		ORDER BY OldColumnRank
		) A
	) C
ORDER BY CodeObject, OldColumnRank

END


GO

