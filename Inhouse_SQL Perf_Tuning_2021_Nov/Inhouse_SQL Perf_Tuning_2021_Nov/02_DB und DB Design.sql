/*


DB Design...

Normalisierung

'Otto'

varchar(50) 'otto'  4
nvarchar(50) 'otto' 4 * 2   8
char(50)   'otto                               '  50
nchar(50) 'otto                                 ' 50 * 2  = 100
text()


datetime ms
date




*/

select country, customerid from customers

select * from orders where year(OrderDate) =1997 --korrekt ..langsam

select * from orders where OrderDate between '1.1.1997' and '31.12.1997' --falsch: 31.12.1997 00:00:00.000

--1998
select * from orders where OrderDate between '1.1.1997' and '31.12.1997 23:59:59:999'--schnell aber falsch





create table tx (id int identity, spx char(4100))



insert into tx
select 'XY'
GO 20000 --Dauer: ca 49 Sekunden

--Wie groß ist tx?
--statt 80 mb erwartet ist die Tabelle ca 160MB


--Seiten 

/*

1 Seiten 8192 bytes
1 Seite hat max 8072 bytes Nutzlast
1 DS kann max (normalerweise) nicht mehr als 8060bytes haben

1 Seite ist nur zu etwa 51% gefüllt--> 20000 Seiten--> 160MB

1 Seite kommt 1 :1 in RAM

set statistics io , time on

--Lesevorgänge: 20000 von HDD in RAM 
--> von 20000 Seiten --> 5000 Seiten --> weniger IO--Weniger RAM --> weniger CPU

--Tabelle mit viele Zeilen und vielen Spalten

--Kann man das auch einfach messen

*/


set statistics io , time on


select * from tx

set statistics io , time off


--logische Lesevorgänge: 20000,


dbcc showcontig('tx')
--- Gescannte Seiten.............................: 20000
--- Mittlere Seitendichte (voll).....................: 50.79%--


--bei sehr vielen Seiten wird der Füllfaktor immer wichtiger


--ADMIN: Kompression--> Page, Row--> ColumnStore
--Row-PageKompression: ca 40-60% Kompression

--DEV: datentyp, evtl TabSonstiges--> App muss geändert werden


--DB Settings

--statt 7 oder 16 MB Anfagsgröße: besser: was kommt in 3 Jahren
--man beobachtet allerdings und justiert

Wachstumrate: 1 MB oder 64.. beides doof.--> neuen Wert.. eher bei Logfile 1000MB
--kurz,schmerzlos und selten


--Formatierung: 64k