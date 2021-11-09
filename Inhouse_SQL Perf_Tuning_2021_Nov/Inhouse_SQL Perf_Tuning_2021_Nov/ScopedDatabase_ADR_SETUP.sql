
DROP database IF EXISTS oldstyle;
DROP database IF EXISTS NewStyle;



CREATE DATABASE OldStyle;
GO
CREATE DATABASE NewStyle;
ALTER  DATABASE NewStyle SET ACCELERATED_DATABASE_RECOVERY = ON; --ADR
GO

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO 
sp_configure 'ADR Preallocation Factor', 2;
RECONFIGURE;
GO

--https://docs.microsoft.com/de-de/sql/relational-databases/accelerated-database-recovery-concepts?view=sql-server-ver15