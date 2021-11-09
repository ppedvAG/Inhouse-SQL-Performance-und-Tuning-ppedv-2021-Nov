/*

TEMPDB
--> gib der tempdb eig HDDs
--> Anzahl der kerne = Anzahl der Datendateien (max 8)
--> T1117   T1118 --> immer gleiche Größen der Datendateien (geht nur bei automat Vergrößerungen)
				  --> mixed extents --> uniform extents (jede Tab vbekommt einene Block)  --Latch

Volumewartungstask
--> SQL Server bekommt das Recht Datendateien selbst zu vergrößeren ohne auszunullen
---nett, aber einem guten Admin ist das egal: weil der aktiv kontrolliert, und entsprechend selbst vorsorglich vergößerung

MAXDOP
--regelt die max Anzahl der Kerne pro Abfrage (nie mehr als 8).. früher war der Wert auf 0

Arbeitsspeicher
Gesamter RAM - OS als Limit
TaskManager: Max Arbeitssatz (Speicher) .. das hätte er gerne wieder
DMVs

Pfade für DBs
Trenne Log von Datendateien pyhsikalisch (eigtl pro DB)


INDIZES

NON CL IX (ca 1000/Tabelle) gut bei rel geringer Ergebnismengen  

CL IX: pro Tab nur 1* gut bei Bereichsabfragen
--> PK muss nur ein eindeutiger IX sein (auch als NCL )


--Kann es sein, dass ein CL auf eindeutige Werte vorteilhaft

-- Single Thread auf Seiten
--was wäre wenn: ID identity Wert und Messdatenerfassung (100 Messwerte / Sek von verschied Maschinen)

1 2 3 4 5 6 7  --> LATCH

select newid()-- eindeutiger Wert weltweit.. Vereilung der Last auf die Seiten

--IM Memory Tabellen --haben keine Latches


ColumnStore "WunderIndex" große Mengen werden extrem komprimiert (Batchmodus) --CPU schonend
----weniger RAM Verbrauch

Dilemma: INS UP DEL ..nicht fein--> DeltaStore = HEAP






PK wird automatisch immer als CL IX eindeutig angelegt, ausser es gibt schon einene CL IX 

select * from bestdemo




*/

--Anzahl der Seiten? --> 57529 .. Table SCAN
set statistics io, time on
select * from ku where productid= 24

--Stelle fest wie voll die Seiten sind..? --> 98,08%, aber wieso  42773??
dbcc showcontig('ku') --depricated

--woher kommt das?
--DDL Trigger (CR DROP ALTER)

-->wg ID ca 15000 Seiten.. muss nicht dazusagen, dass das auch in RAM kommt!!

--Was müssen wir tun: ID müssen zum DS vorne wieder rein
--Tabelle pyhsikalisch neu schön ablegen

--> CL IX !

select 
	ips.forwarded_record_count --die muss eigtl 0 sein
from sys.dm_db_index_physical_stats(db_id(),object_id('ku'),NULL, NULL, 'detailed') ips


--ein CL IX hat keine Forward record counts.. 
--ohne frc = 43570 Seiten!!

--Brent Ozar
sp_blitzIndex --





