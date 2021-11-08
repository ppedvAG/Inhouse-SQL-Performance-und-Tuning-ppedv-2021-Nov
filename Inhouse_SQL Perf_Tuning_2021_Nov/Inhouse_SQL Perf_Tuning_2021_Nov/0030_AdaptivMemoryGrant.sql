use StackOverflow2010;
GO
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_MEMORY_GRANT_FEEDBACK = ON;

ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 110
GO


CREATE INDEX IX_Reputation ON dbo.Users(Reputation)
GO


CREATE OR ALTER PROCEDURE dbo.usp_UsersByReputation
  @Reputation int
AS
SELECT TOP 10000 *
	FROM		dbo.Users
	WHERE		Reputation=@Reputation
	ORDER BY	DisplayName;
GO


exec usp_UsersByReputation 1
 
exec usp_UsersByReputation 2152




ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 150
GO



Alter Database scoped configuration clear procedure_cache;

exec dbo.usp_UsersByReputation 1 --mem bei 1 229696, dann 2tes mal


exec dbo.usp_UsersByReputation 2152 --

