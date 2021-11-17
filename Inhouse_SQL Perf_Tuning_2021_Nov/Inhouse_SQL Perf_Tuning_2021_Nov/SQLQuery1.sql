--Welche Tabelle ist vermutlich schneller?


--TABA 10000 Zeilen

--TABB 10000000000000000 Zeilen

--Abfrage: man bekomt 10 Zeilen zurück

--TABA und TABB absolut identisch

--3 ungefähr gleich

--21 sek die mit weniger 


--Wenn weniger schneller ist, dann kleiner machen



--var1: Kompression (Page, Row) 40 bis 60 %
--> Ergebnis: man bezahlt mit CPU 
-- der Client bekommt immer dekomprimierte Daten
-- auf Server komprimiert


--var2

--> Riesentabelle.. dh sehr breite Tabelle

--GERICHT   SALZ PFEFFER Eier Milch Semmelbrösel..uiuiui  400 Spalten ... 1024

W Sch        1            1             1        NULL NULL NULL NULL 



--> ein NULL kostet PLATZ abhängig von Datentyp



create table rezept
	( id int ,
		rname nvarchar(50),
		Salz varchar(50) null sparse,  ---Sparse??  Spars dir die NULL

--aber wenn mal kein NULL.. dann kostet das mehr als sonst
--ab wann ist das trotzdem Werte vorkommen rentable...
--dec mind 42% NULL
--oft 60%
--bit  98%


--bis zu 30000 Spalten.. explizit wg Sharepoint eingeführt


---

--Tab UMSATZ wächst wächst wächst
--jeder SCAN muss alles durchgehen

--KW03202021
--partition0 .. bis partition31
create table u2021 (id int identity, jahr int, spx int)

create table u2020 (id int identity, jahr int, spx int)

create table u2019 (id int identity, jahr int, spx int)

create table u2018 (id int identity, jahr int, spx int)


--Problem: Anwendung... select * from umsatz

--Sicht

create view Umsatz
as
select * from u2021
UNION ALL--sucht doppelte
select * from u2020
UNION ALL
select * from u2019
UNION ALL
select * from u2018



--Messung
--Sicht ist gleich schnell wie adhoc

select * from umsatz where jahr = 2019 --bisher nicht besser


--Idee 1: proc 2019, 4 

select * from 'u+2019'  --bad code


--Garantie für best Werte in Spalten  CHECK 

ALTER TABLE dbo.u2018 ADD CONSTRAINT
	CK_u2018 CHECK (jahr=2018)
GO



--bis dahin ok...

select * from umsatz where ID = 2020 


--geht bei Sichten INS UP DEL ?

insert into umsatz (jahr, spx) values (2019, 100)
--kein Primärschlüssel für die [Graphdb].[dbo].[u2021] Error

--PK: Zweck ref Integrität, dazu braucht eindeutig


-- [Graphdb].[dbo].[u2021]-Tabelle eine IDENTITY-Einschränkung aufweist. ERROR!

insert into umsatz (id,jahr, spx) values (next value for uid,2018, 100) --jetzt gehts....

--ID .. fortlaufenden Zahl..  Sequenz

select next value for uid

select * from umsatz


----- 1NF atomar  in jeder Zelle ein Wert  datetime --> Jahr Monat Quartal


--Sicht.....


--with schemabinding: zwingt zur sauberen Arbeit

drop table slf
drop view vslf

create table slf (id int identity, stadt int, land int)


insert into slf
select 10, 100
UNION ALL
select 20,200
UNION ALL 
select 30, 300


select * from slf

create view vslf with schemabinding
as
select id, stadt, land from dbo.slf


select * from slf

alter table slf add fluss int
update slf set fluss = id *1000


select * from vslf --sollte er alle Spalten zurückbringen

alter table slf drop column land


select * from vslf --???? OOH OOOH


--wenn zweckentfremdet werden

create view vdemo as
SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.EmployeeID, Orders.OrderDate, Orders.ShipVia, Orders.Freight, Orders.ShipCity, Orders.ShipCountry, [Order Details].OrderID, [Order Details].ProductID, [Order Details].UnitPrice, [Order Details].Quantity, Employees.FirstName, Employees.LastName, Employees.BirthDate, Products.ProductName, 
         Products.UnitsInStock
FROM   Customers INNER JOIN
         Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
         Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
         [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
         Products ON [Order Details].ProductID = Products.ProductID


select country, count(*) from customers
group by country --wir haben nur 91 Kunden

select country, count(*) from vdemo
group by country --wir haben nur 91 Kunden



































