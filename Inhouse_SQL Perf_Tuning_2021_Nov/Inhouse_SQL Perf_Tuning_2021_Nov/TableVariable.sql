CREATE TABLE [dbo].[TableVariableExample](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [total] [money] NULL,
    [navn] [char](10) NULL
) ON [PRIMARY]
GO

begin tran
DECLARE @i INT, @val MONEY
SET @i=1
WHILE @i <= 2000000
BEGIN
    SELECT @val=CONVERT(MONEY,RAND()*150)
       IF @i IN ( 10000,20000,30000,40000,50000,60000,70000,80000,90000,100000)
       BEGIN
       INSERT INTO [TableVariableExample] Values(@val, 'it-Craft')
       END
       ELSE
       BEGIN
        INSERT INTO [TableVariableExample] Values(@val, REPLICATE('c',10))
       END
       SET @i=@i+1    
END
commit
---------------TEST mit DB auf SQL 2012/2014 Modus
USE [master]
GO
ALTER DATABASE northwind SET COMPATIBILITY_LEVEL = 150
GO

DECLARE @MyTableVariable TABLE (
       Id int,
       total money,
       navn char(10)
)

INSERT INTO @MyTableVariable
SELECT* FROM TableVariableExample

SET STATISTICS IO, TIME ON;

SELECT 
    Navn,
    Total 
FROM @MyTableVariable
WHERE Navn = 'it-Craft'
--OPTION (USE HINT('DISABLE_DEFERRED_COMPILATION_TV'));

SET STATISTICS IO OFF;

--bei JOIN

--hash  loop  merge