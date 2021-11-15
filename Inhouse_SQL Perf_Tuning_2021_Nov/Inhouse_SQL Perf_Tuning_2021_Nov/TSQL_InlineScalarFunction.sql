--Scalar Function 
--SQL kann zu Beginn der Ausfürhung keinen ordentlichen Plan erstellen
--mit SQL 2019 wird die Planerstellung verzögert um für die Funktion eine bessere Einschätzung zu bekommen
--klappt aber nur beim rel einfachen Funktionen..
--das geht nur bei einfachen Skalawertfunktionen






use northwind;
GO

select * from sys.dm_exec_function_stats

create or alter function dbo.fbrutto
	(
		@Fracht money,
		@MwSt decimal (4,2)
	) returns money
as
Begin
	return (@Fracht*@MwST)
End
--Skalarfunction kann vorab nicht exakt geschätzt werden..
--jetzt versteht SQL Server wie das intern funktioniert

--zB: f(spalte, Wert) --> Spalte * Wert
--... begrenzt machbar
set statistics io, time on


update ku2 
	set freight = 
		freight * RAND(convert(varbinary, newid()))*100




--select freight, count(*) from o2 group by freight
ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 110
GO
set statistics io, time on --wieviele Zeilen werden geschätzt ;-) ----   €0Prozent
select * from ku2
		where 
			dbo.fbrutto(freight,1.19) < 2
--, CPU-Zeit = 5800 ms, verstrichene Zeit = 6500 ms.
-- kein Parallelismus


ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 150
GO

select * from ku2
		where 
			dbo.fbrutto(freight,1.19) < 2
--870   215

select inline_type, * from sys.sql_modules
where is_inlineable=1


--Bsp mit mehr Daten--->


















use StackOverflow2010;
GO

CREATE OR ALTER FUNCTION dbo.ScalarFunction ( @uid INT )
RETURNS BIGINT
    WITH RETURNS NULL ON NULL INPUT, SCHEMABINDING
AS
    BEGIN
        DECLARE @BCount BIGINT;
        SELECT  @BCount = COUNT_BIG(*)
        FROM    dbo.Badges AS b
        WHERE   b.UserId = @uid
        GROUP BY b.UserId;
        RETURN @BCount;
    END;
GO

ALTER DATABASE [StackOverflow2010] SET COMPATIBILITY_LEVEL = 150
set statistics io , time on
go
SELECT TOP 1000 u.DisplayName, dbo.ScalarFunction(u.Id)
FROM dbo.Users AS u
GO



select inline_type, * from sys.sql_modules

