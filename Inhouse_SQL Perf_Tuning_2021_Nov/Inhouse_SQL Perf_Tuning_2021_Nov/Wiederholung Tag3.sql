/*




*/


declare @i as int = 10  --30%

--RAM Einsch‰tzung

select * from orders where orderid = @id


--Tipp: statt Var besser Parameter = prozeduren oder sp_execute_sql


--Zeilenweise lesen.. --> SCAN
select * from employees where year(birthdate) = 1956
--Tipp: im where keine f() um eine Spalte where orderdate between
--Tipp: warum keine Spalte Jahr, Quartal, Monat --> IX
-- Pr‰fixEmail  |MailDom
-- andreasr		| ppedv.de


--?? 44 % Sortieren
select * from customers c 
	inner join orders o on c.customerid = o.CustomerID
	--CL IX (customerid) sortiert


--Merge , Loop , Hash 
set statistics io, time on
select * from customers c 
	inner merge join orders o on c.customerid = o.CustomerID
	--wie bekomme ich den Sort weg?
	--bei where den korrekten IX
	--CL IX auf CId in orders
	--evtl temp Tabellen #t

--Loop. wenn eine sehr kleine Ergebnissmenegne besitzt
--andere Seite sortiert

select * from customers c 
	inner loop join orders o on c.customerid = o.CustomerID


--hash
--virt Vergleichstabelle mit hashwerten
--klingt teuer, passiert h‰ufig wenn keine IX
--bei sehr groﬂen Tabellen

select * from customers c 
	inner hash join orders o on c.customerid = o.CustomerID

















