USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[T_ROUTINES](
	[SPECIFIC_CATALOG] [nvarchar](128) COLLATE Cyrillic_General_CS_AI NULL,
	[SPECIFIC_SCHEMA] [nvarchar](128) COLLATE Cyrillic_General_CS_AI NULL,
	[SPECIFIC_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NOT NULL,
	[ROUTINE_CATALOG] [nvarchar](128) COLLATE Cyrillic_General_CS_AI NULL,
	[ROUTINE_SCHEMA] [nvarchar](128) COLLATE Cyrillic_General_CS_AI NULL,
	[ROUTINE_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NOT NULL,
	[ROUTINE_TYPE] [nvarchar](20) COLLATE Cyrillic_General_CS_AI NULL,
	[MODULE_CATALOG] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[MODULE_SCHEMA] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[MODULE_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[UDT_CATALOG] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[UDT_SCHEMA] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[UDT_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[DATA_TYPE] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[CHARACTER_MAXIMUM_LENGTH] [int] NULL,
	[CHARACTER_OCTET_LENGTH] [int] NULL,
	[COLLATION_CATALOG] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[COLLATION_SCHEMA] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[COLLATION_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[CHARACTER_SET_CATALOG] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[CHARACTER_SET_SCHEMA] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[CHARACTER_SET_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[NUMERIC_PRECISION] [tinyint] NULL,
	[NUMERIC_PRECISION_RADIX] [smallint] NULL,
	[NUMERIC_SCALE] [int] NULL,
	[DATETIME_PRECISION] [smallint] NULL,
	[INTERVAL_TYPE] [nvarchar](30) COLLATE Cyrillic_General_CS_AI NULL,
	[INTERVAL_PRECISION] [smallint] NULL,
	[TYPE_UDT_CATALOG] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[TYPE_UDT_SCHEMA] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[TYPE_UDT_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[SCOPE_CATALOG] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[SCOPE_SCHEMA] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[SCOPE_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[MAXIMUM_CARDINALITY] [bigint] NULL,
	[DTD_IDENTIFIER] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[ROUTINE_BODY] [nvarchar](30) COLLATE Cyrillic_General_CS_AI NULL,
	[ROUTINE_DEFINITION] [nvarchar](4000) COLLATE Cyrillic_General_CS_AI NULL,
	[EXTERNAL_NAME] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[EXTERNAL_LANGUAGE] [nvarchar](30) COLLATE Cyrillic_General_CS_AI NULL,
	[PARAMETER_STYLE] [nvarchar](30) COLLATE Cyrillic_General_CS_AI NULL,
	[IS_DETERMINISTIC] [nvarchar](10) COLLATE Cyrillic_General_CS_AI NULL,
	[SQL_DATA_ACCESS] [nvarchar](30) COLLATE Cyrillic_General_CS_AI NULL,
	[IS_NULL_CALL] [nvarchar](10) COLLATE Cyrillic_General_CS_AI NULL,
	[SQL_PATH] [sysname] COLLATE Cyrillic_General_CS_AI NULL,
	[SCHEMA_LEVEL_ROUTINE] [nvarchar](10) COLLATE Cyrillic_General_CS_AI NULL,
	[MAX_DYNAMIC_RESULT_SETS] [smallint] NULL,
	[IS_USER_DEFINED_CAST] [nvarchar](10) COLLATE Cyrillic_General_CS_AI NULL,
	[IS_IMPLICITLY_INVOCABLE] [nvarchar](10) COLLATE Cyrillic_General_CS_AI NULL,
	[CREATED] [datetime] NOT NULL,
	[LAST_ALTERED] [datetime] NOT NULL
)

GO

