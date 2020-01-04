USE [db_app_server]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [V].[EVENT] AS
SELECT TOP 100 PERCENT
A.IdEvent, 
A.TimeEvent, 
A.IdMessage, 
A.IdUser, 
ISNULL(C.UserLogin,'') as UserLogin,
ISNULL(C.SurName + ' ' + C.FirstName,'') as UserFullName,
B.TextMessage, 
A.TextEvent,
A.TextNote 
FROM 
[E].[EVENT] A
LEFT JOIN [A].[MESSAGE] B ON A.IdMessage=B.IdMessage
LEFT JOIN [T].[USER] C ON A.IdUser=C.IdUser
ORDER BY A.IdEvent DESC

GO

