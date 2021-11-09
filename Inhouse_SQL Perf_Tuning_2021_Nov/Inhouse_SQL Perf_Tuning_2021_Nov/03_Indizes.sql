/*


Indizes:

! Clustered (gruppierter) Index = Tabelle
Nicht gruppierter (non clustestered) Index

! eindeutiger IX
! gefilterter IX
! zusammengesetzter IX
! IX mit eingeschl Spalten
indizierte Sicht
realer hypoth Index
part. IX
! abdeckender IX = der ideale IX zur Abfrage  covered Index

ColumnStore gr und nicht gr..
select * from sys.dm_db_column_store_row_group_physical_stats




*/


--NICHT GR IX

/*

Kopie von Daten
 wie Telefonbuch... im IX müssen nicht alle Infos sein
 den kann es pro Tabelle auch 1000 mal geben



 was wenn : where vorname < 'Z'

 je mehr Ergebnisse desto schlechter.. 
 --vor allem mit Lookup (wenn die gesuchte Information nicht IX enthalten ist)

 daher Lookup vermeiden, wo es auch immer geht

 --hauptsache weniger Ergebnisse
 where 
	<
	>
	= guter Kandidat für N GR IX
	like
	in
	between
	!=
	not




	GR IX  = TABELLE... es gibt keinen HEAP mehr
	aber seine Fähigkeiten sind besonders bei Bereichssuchen optimal

	wie oft gibts den GR IX pro Tabelle? 1 mal 


	where 
		=
		<
		>
		in
		between
		like



*/

use Northwind

--Spieltabelle
SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.EmployeeID, Orders.OrderDate, Orders.ShipVia, Orders.Freight, Orders.ShipCity, Orders.ShipCountry, [Order Details].OrderID, [Order Details].ProductID, [Order Details].UnitPrice, [Order Details].Quantity, Employees.FirstName, Employees.LastName, Employees.BirthDate, Products.ProductName, 
         Products.UnitsInStock
INTO KU
FROM   Customers INNER JOIN
         Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
         Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
         [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
         Products ON [Order Details].ProductID = Products.ProductID



insert into KU
select * from ku

--bis ca 1,1 MIO in KU...


alter table ku add id int identity --eindeutige DS



--DDL Trigger ALTER DROP CREATE


select top 3 * from ku

set statistics io, time on
select id from KU where id= 100 -- im PLAN TABLE SCAN.. Anzahl der Seiten  57529 -700ms/114ms

--auf welche Spalte den gr IX: OrderDate ==> alles andere nur noch n gr ix

--Idee: NIX_ID
create nonclustered index NIX_ID on KU(id) --default asc


select ID from KU where id = 100 -->NCL IX SEEK -- Seiten 3 .. Dauer 0/0 ms


select id, freight from KU where id = 100 -->IX SEEK Lookup .. 4 Seiten 0/0 ms


select id, freight from KU where id < 13000 --Table Scan


select id, freight from KU where id < 11000 --bei ca 11000 noch ein Seek.. ca 1% der DS


--besser , wenn man die Info in den IX rein

--zusammengesetzter IX

create nonclustered index NIX_ID_FR on KU(id,freight)

select id, freight from KU where id < 13000 --IX SEEK.. 45 Seiten statt TAB SCAN


select id, freight from KU where id < 900000 --IX SEEK.. 45 Seiten statt TAB SCAN, selbst bei 900000 noch

--..der zusamm macht dann Sinn, wenn im where mehr Argumente
--kann max 16 Spalten oder 900bytes


--noch nicht die beste Wahl
--IX mit eingeschlossenen Spalten

select id, freight, city from KU where id = 200
--     I N C L U D E ----              SCHLÜSSELSPALTEN: bis zu 1023 Spalten einschliessen


--wenn 20 Indizes auf einer Tabelle, dann 20 INS UP DEL--> überflüssige Indizes

NIX_FR_EMPID:incl_CYCIUPQU
select country, city, SUM(unitprice*quantity)
from ku
where Freight < 2 and EmployeeID = 3 --was ist selektiver.. die zuerst
group by  Country, city

--2 Indizes: --aber SQL Server.. dem ist das zuviel...
select country, city, SUM(unitprice*quantity)
from ku
where Freight < 2 or EmployeeID = 3 --was ist selektiver.. die zuerst
group by  Country, city

select distinct freight from ku
select distinct employeeid from ku

--COUNTRY , CITY

select * from KU where Freight = 10.98  --1024

select * from KU where EmployeeID = 3 --164000


--noch schlimmer hier...
select country, city, SUM(unitprice*quantity)
from ku
where (Freight < 2 or EmployeeID = 3) and ShipVia = 2 --das and ist stärke bindend..Klammern setzen!!!!
group by  Country, city


--IX über alle Datensätze

--gefilterter IX.. wir tun nicht alle DS rein-...!
--macht nur dann SInn, wenn gegenüber dem ungefilterten wir auf weniger Ebenen kommen..
--statt 4 Ebenene zb 3 oder 2
--von 4 auf 4.. sinnlos.. eher schlechter

--weil der Baum evtl kleiner wird, anstatt mit allen DS
--liber 2 Ebenen als 3 
--lieber 3 als 4

--where id < 50 and country = 'UK' --hier gef IX
--where id < 50 and country = 'USA' --kein IX




--Indizierte Sicht


select country, COUNT(*) from KU --57529 --= 969 ms, verstrichene Zeit = 153 ms.
group by country


--Sicht / View


--View = Abfrage, die so tut , als wäre sie eine Tabelle.. INS UP DEL IND Security
create view vKu
as
select country, COUNT(*) Anzahl from KU 
group by country
GO

--Sicht gleich schnell wie adhoc Abfrage
select * from vKU


select country, COUNT(*) Anzahl from KU 
group by country






create or alter view vKu with schemabinding --wir müssen pedantisch genau arbeiten
as
select country, COUNT_BIG(*) Anzahl from dbo.KU 
group by country
GO

--IX auf LAND

--Sicht gleich schnell wie adhoc Abfrage
select * from vKU --2 Seiten --0 sec

--er schiebt der ANW eine ind Sicht unter, ohne dasss die Anw das merkt
select country, COUNT(*) Anzahl from KU --2 Seiten ???? nur bei ENT.. (auch STD ..)
group by country


--extrem viele Randbedingungen.. Count_BIG !! eindeutige Eregbnisse der Sicht

--1 Trillion DS  Umsatz pro Land...> Wieviele Seiten? --Anzahl Länder ca 200
--2 Seiten
--aber .. jeder INS UP DEL muss das Ergebnis der Sicht aktualisieren.. bzw IX
--Idee: nicht bei tägliche Umsatztabellen.. eher bei Archiv


--Cooler...
select * into ku2 from ku

select top 3 * from ku2

--Abf mit where und Aggregaten

--Wie groß ist der Wert des Lager pro Lieferland
--

select shipcountry, SUM(unitprice*unitsinstock) 
from ku
where Country = 'Mexico'
group by shipcountry

CREATE NONCLUSTERED INDEX NIX1
ON [dbo].[KU] ([Country])
INCLUDE ([ShipCountry],[UnitPrice],[UnitsInStock])

--252 Seiten ...     30 und 27

--MIT Columnstore
select shipcountry, SUM(unitprice*unitsinstock) 
from ku2
where Country = 'Mexico'
group by shipcountry ---0 und 3 ms... Lesevorgänge 0 ..39 LOB


--KU hat 340MB Daten und KU2 hat 4,3MB 

^--REBUILD:::
-- A: stimmt   B: stimmt nicht

--A!

--Gut bei sich wenig verändernden Daten
--ein DEL löscht nicht
--INS schreibt Heap



--wir haben soeben max 4,3 MB in RAM getan statt 330MB

--gibt nur einen Grund für 4,3 MB: 

CREATE CLUSTERED COLUMNSTORE INDEX CSIX ON KU2
       WITH ( DATA_COMPRESSION = COLUMNSTORE_ARCHIVE );


--nun 3,0 MB


