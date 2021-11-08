/*

Histogramm Verteilung der DAten rel genau
density vector Grundsätzliche verteilung der Dichte



Tabellen mit < 8MB FullScan
		> 8MB non linear
Range_Hi_Key = column value at the top of this step
Range_Rows = number of rows within this interval (excl. high and low key)
Eq_Rows = number of rows equalling high key
Distinct_Range_Rows = number of distinct values within interval (excl. high/low)
Avg_Range_Rows = average number of rows per distinct values

Parametrisierte Abfragen
geschätzte Anzahl von Zeilen= Density*total numbers of rows


Does and Donts

Statt Variablen mit Parameter arbeiten

Parameter in Procs nicht vor Verwendung in Abfrage nochmals ändern

Ausdrücke vereinfachen : Abs(-100) --> 100

bei Berechnungen evtl eine berechnet Spalte erstellen

Ergebnisse aus  Tabellenwertfunktionen mit mehreren Ausdrücken 
in eine temp Tabelle kopieren

Andererseits kann eine Tabellenvariable in einer Proz vorteilhafter sein , als eine temp Tabelle
, da weniger Neukompilierungen

Optimierungshinweise in Prozeduren


*/

/*Wo kann man nachsehen*/


select * from sys.stats where name = '_WA_Sys_00000001_6E01572D'

select * from sys.dm_db_stats_histogram(object_id('t1'),2)

select * from sys.stats_columns

/*Wann werden sie aktuaisiert*/
--AB SQL 2014 etwas anders..abhängig von der Kardinalität

select Min(500 + 0.2 * 2000000)
select min(Sqrt(1000 * 2000000))

DBCC Show_Statistics(t1,'_WA_Sys_00000004_6E01572D') 
with histogram

select * from sys.stats
select object_name(1845581613)
drop statistics t1._WA_Sys_00000006_6E01572D

/*ENDE DMVS*/



select * into  statstab from sysmessages

create nonclustered index ncl on statstab(severity)

dbcc show_statistics('statstab','ncl')

--ALL DENSITY : 0.0625
--EQ .. soviel denkt SQL Server, kommt raus
--ALL DENSITY
select 1 / CAST(count(severity) as numeric(18,2)) from 
	(select distinct severity from statstab) t --16

--IM GROUP BY .. Reziprok für 
select 0.0625* 16 --= 1
select 16/1  = 16

select severity from statstab group by severity -- = 16

--bei NCL IX Verwendung: Geschätzt Anzahl der Zeilen mit Density Vector

declare @var as int
set @var= 12 --oder 14 oder 16 oder 15 oder ...

select * from statstab where severity = @var --19424


declare @var as int
set @var= 12 --oder 14 oder 16 oder 15 oder ...

select * from statstab where severity < @var
--bei Vergelich mit < > .. 30%
select COUNT(*)* .3 from statstab


set statistics io on
----bei 3014 kein Index...??
select * from statstab where severity >20

--Tipping Point!!<--> Lookup
--CL oder Heap: 33% rows
--- Anzahl Rows unter 25% der Seiten
--zw 25 und 33 % kann irgendwas passieren...

create nonclustered Index ncl2 on statstab(severity)
include(Error,dlevel, description, msglangid)

----bei 3014 kein Index...??
alter database northwind set compatibility_level =120
alter database scoped configuration clear procedure_cache
--Jetzt IX aber mit SortSpill
select * from statstab where severity >15 order by msglangid 
--Entweder: IX mit msglangid oder SQL 2019






select error from statstab group by error --= 16
select 1 / CAST(count(error) as numeric(18,2)) from 
	(select distinct error from statstab) t --  0.0000707864373186097|14127








create or alter proc gpMess @sever tinyint
as
begin
	set nocount on;
	select *from statstab s
	where s.severity=@sever
	order by error, msglangid desc;

set nocount off
end
GO

alter database scoped configuration clear procedure_cache
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON
--Erster Aufruf-- Plan uwrde kompiliert
exec gpMess 12 --schätzt auf  22 und 1 MB RAM

--wiederverwendung des Plans
exec gpMess 16 --Sort Spill... verschätzt.. sortierung in tempdb
			   --22 Datensätze obwohl 228470
			   --select : 1 MB RAM --für 228000 DS + Sortierung!?

ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 150
alter database scoped configuration clear procedure_cache
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON

exec gpMess 16 -- RAM Bedarf !! 13 MB

exec gpMess 12 --RAM Bedarf 13 --bei SQL 2019 sinkt das bei 2ter wiederholung 5,8 MB


--Um Problem zu beheben: 
--Parameter Sniffing deaktiveren auf Server...

--dbcc traceon (4136,-1)--auf Server
 -- Sniffing ausschalten

alter database scoped configuration clear procedure_cache
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF

exec gpMess 16 -- -- RAM Bedarf !! 13 MB bei 2280000 Zeilen
exec gpMess 16 -- -- RAM Bedarf !! 97 MB

exec gpMess 12 ---19000 bei 22 Zeilen und 97MB
exec gpMess 12 --5,8 MB 

--Grund Statistiken-- man hat verboten in die Stat reinzuschauen
--also statt Histogramm, die Density

select 0.0625*310794---

--OLUS SQL 2019 MEMORY GRANT Effekt

select 
	qs.plan_generation_num,
	qs.creation_time,
	qs.last_execution_time,
	qs.execution_count,
	qs.last_dop,
	qs.max_dop,
	qs.min_dop
from sys.dm_exec_query_stats qs
  cross apply sys.dm_exec_sql_text(qs.sql_handle) st
  where 
	st.text like '%gpmess%'
	and
	st.text not like N'%dm_exec_Query_Stats%'


--dbcc traceoff(4136,-1)

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = Off;
GO


--UND WANN WIRD GEUPDATET?

 drop table if exists mess

select * into mess from sysmessages

create nonclustered Index ncl on mess(severity)

select count(*) from mess --310794

select Min(500 + 0.2 * 310794)
select min(Sqrt(1000 * 310794))--17629


select top 3 * from mess

alter database northwind set compatibility_level=150

INSERT INTO dbo.mess WITH (TABLOCK)
(error, severity, msglangid, dlevel,description)
SELECT	TOP (10000)
		error, severity, msglangid, dlevel,description
FROM	sysmessages
WHERE	msglangid = 1033;
GO

-- what statistics do we have and what is the modification counter?
SELECT	S.name,
		SP.*
FROM	sys.stats AS S
		CROSS APPLY sys.dm_db_stats_properties
		(
			S.object_id,
			S.stats_id
		) AS SP
WHERE	s.object_id = OBJECT_ID(N'dbo.mess', N'U');
GO

-- let's run a query against the table to check the statistics
SELECT * FROM dbo.mess WHERE severity = 13; --67
GO
SELECT * FROM dbo.mess WHERE severity = 16; --229000
GO

-- let's add another 2.000 records into the table to hit the threshold!
INSERT INTO dbo.mess WITH (TABLOCK)
(error, severity, msglangid, dlevel,description)
SELECT	TOP (7628)
		error, severity, msglangid, dlevel,description
FROM	sysmessages
WHERE	msglangid = 1028;
GO

-- what statistics do we have and what is the modification counter?
SELECT	S.name,
		SP.*
FROM	sys.stats AS S
		CROSS APPLY sys.dm_db_stats_properties
		(
			S.object_id,
			S.stats_id
		) AS SP
WHERE	s.object_id = OBJECT_ID(N'dbo.mess', N'U');
GO

--Noch kein Update


DBCC SHOW_STATISTICS(N'dbo.mess', N'ncl') WITH HISTOGRAM
GO

-- let's run a query against the table to check the statistics
EXEC sp_executesql N'SELECT * FROM dbo.mess WHERE severity = @Id
OPTION
(
	QUERYTRACEON 3604,
	QUERYTRACEON 2363
);', N'@Id TINYINT', 13;
GO --density vector select 314794 *0.0625

EXEC sp_executesql N'SELECT * FROM dbo.mess WHERE severity = 16
OPTION
(
	QUERYTRACEON 3604,
	QUERYTRACEON 2363
);', N'@Id TINYINT', 16;
GO

-- what statistics do we have and what is the modification counter?
SELECT	S.name,
		SP.*
FROM	sys.stats AS S
		CROSS APPLY sys.dm_db_stats_properties
		(
			S.object_id,
			S.stats_id
		) AS SP
WHERE	s.object_id = OBJECT_ID(N'dbo.mess', N'U');
GO







INSERT INTO dbo.mess WITH (TABLOCK)
(error, severity, msglangid, dlevel,description)
SELECT	TOP (2)
		error, severity, msglangid, dlevel,description
FROM	sysmessages
WHERE	msglangid = 1028;
GO

UPDATE STATISTICS dbo.mess WITH FULLSCAN;
GO

-- what statistics do we have and what is the modification counter?
SELECT	S.name,
		SP.*
FROM	sys.stats AS S
		CROSS APPLY sys.dm_db_stats_properties
		(
			S.object_id,
			S.stats_id
		) AS SP
WHERE	s.object_id = OBJECT_ID(N'dbo.mess', N'U');
GO




--Kardinalsschätzung

select * into c1 
from NwindBig..Customers

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = Off;

select  city, Region from c1
where
	City='Sacramento'
	and
	Region='AZ-TL'

	--20571
	--105
	select (20571*105)/2000000

	select 2159955/2000000


select  * from c1 
--where postalcode is not null order by postalcode
where
	City='Sacramento' 
	and
	contacttitle ='sales'
--703--------3810

update statistics c1 with fullscan

dbcc show_statistics('c1',[_WA_Sys_00000006_02FC7413]) with histogram
dbcc show_statistics(c1,[_WA_Sys_00000004_02FC7413]) with histogram

select convert(bigint,(20263*33277))/2000000

--337

select ((20263/2000000)*SQRT(33277/2000000))*2000000