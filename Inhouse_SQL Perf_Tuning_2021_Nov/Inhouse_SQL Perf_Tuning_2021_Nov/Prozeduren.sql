/*

Warum schreibt man Prozeduren?

wie ein Batch -- Wiederverwendbarkeit


Code liegt auf dem Server 


a) Proz  b) adhoc Abfrage c) Sicht  d) F()

---d                    b|c         a
-- 
langsam							schnell-->

Weil Proz den Plan kompiliert und wiederholbar hinterlegt (auch nach Neustart)
beim ersten Aufruf



*/


select * from Customers where CustomerID like 'A%'
select * from Customers where CustomerID like 'ALFKI%'
select * from Customers where CustomerID like '%' --nchar(5)

--IDEE: 

exec gpKDSuche 'ALFKI'  -- 1 Zeile 

exec gpKDSuche '%'  -- alle Zeile

exec gpKDSuche 'A%'  -- alle mit A beginnend 

create or alter proc gpKDSuche @kdid  nvarchar(5) ='%' --default Wert 
as
select * from Customers where CustomerID like @kdid + '%'
GO


exec gpKDSuche 'ALFKI' --ideal ein NCL IX

exec gpKDSuche 'A'  --geht nicht solange param nchar(5).. erst bei nvarchar(5) --NCL IX

exec gpKDSuche '%' --nix -- SCAN


--eigtl sollten das 2 versch Pläne sein


--KU Tabelle hat nur einen Index NIX_ID


set statistics io, time on
select * from KU where id < 2 --IX SEEK!!

select * from KU where id < 1000000 --SCAN!

dbcc freeproccache -- der gesamte Procedurecache 

alter datebase scope configuration set force_parametrization = off

create proc gpSucheID @id int
as
IF < 11000
exec proc1  --IXSEEK
else
exec proc2 --alle  mit SCAN
select * from KU where id < @id;
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;--Löschen des Cahce der aktuelle DB





exec gpSucheID 2 --IX SEEK -- 4seiten --SEEK als PLAN !!!

exec gpSucheID 1000000 --ca 1 MIO Seiten für eiue Tabelle mit 43000 --wg IX SEEK
GO 3
--Schwäche von Proz ist der fixe Plan


--Wird immer ein Table Scan ausgeführt, dann immer 43000 Seioten
--wird ein Seek ausgeführt, dann entweder 4 Seiten oder 1 MIO Seiten
--Was soll ich tun?
--den mit Seek oder den mit Scan?


--Wie oft...



--woher kann ich denn rausfinden, ob Proz Mist machen...








--beschissene Prozedure



--Hohe CPU Last

--Kompilierungen von Proz

with recompile --> hohe CPU



set statistics io, time on

select country, city , SUM(freight) from ku
group by Country, City order by Country, City desc --43000, CPU 532  Dauer 114


--CPU deutlich höher als gesamte Dauer.. mehrere Cores
--Hat das was gebracht , dass mehr Cpu die Arbeit erledigen?
--mit einer CPU sonst 500ms

--Wieviele Prozessoren setzt SQL pro Abfrage ein?
-- MAXDOP: bis SQL 2014=0 heisst alle Kerne, ab SQL 2016 Anzahl der Kerne max 8
-- Kostenschwellenwert (SQL Dollar): 5 ,ab diesen Wert alle Kerne 
-- Kerne bekommen verschiedene Anzahl an Datensätzen

select country, city , SUM(freight) from ku
group by Country, City order by Country, City desc
option (maxdop 1)  --350ms-- ca 35% CPU Mehraufwand bei 8 Cores


select country, city , SUM(freight) from ku
group by Country, City order by Country, City desc
option (maxdop 8)  --350ms-- ca 35% CPU Mehraufwand bei 8 Cores

--mit 4 Kernen fast identische Zeiten

select country, city , SUM(freight) from ku
group by Country, City order by Country, City desc
option (maxdop 4)

---mit 4 Kernen teilweise schneller!!!!

--Kostenschwellwert

--BEI OLTP 50 und OLAP  25--auf dem Server??????


--Auf Server 8 Kerne  auf Northwind 4 --> Was gilt, das der DB  4
select country, city , SUM(freight) from ku
group by Country, City order by Country, City desc
option (maxdop 2)

--wird bei der Abfrage angegeben, gilt das der Abfrage

--Kostensenkungung--> richtige IX
--COLUMNSTORE oder Kompression


--SUPSENDED  RUNNING  RUNNABLE































create proc gptest @id int
as
begin
	select * from t1 where id < @id
	OPTION (optimize for (@id =1000000))
end
GO
exec gptest 2