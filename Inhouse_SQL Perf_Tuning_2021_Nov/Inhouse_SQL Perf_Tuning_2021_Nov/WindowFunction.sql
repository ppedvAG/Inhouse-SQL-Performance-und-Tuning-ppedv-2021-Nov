--Window Functions

--Wie findet man die best verlauften Produkte pro Mitarbeiter und jahr
--bis hierhin noch rel einfach...aber was nun 
select lastname, productname, year(orderdate), sum(od.unitprice*quantity)
from employees e inner join orders o on o.EmployeeID=e.EmployeeID
			 inner join [Order Details] od on od.OrderID=o.orderid
			 			 inner join products p on p.ProductID=od.ProductId
group by lastname, productname, year(orderdate)
order by 1,3,4 desc



--Window Function.. man vergebe eine Rang pro Mitarbeiter, Jahr, Produkt und Verkaufszahlen
select orderid, employeeid, customerid, freight,
	row_number() over (partition by employeeid order by freight desc)
from orders

--row_number.. fortlaufendes durchnummerieren

--RANK.. bei gleichen Werten wird der nächste übersprungen


--ABC Analyse zb
--ntile  mehrer Teile... gleichverteilt

select 
ntile(3) over (order by freight asc), freight
 from orders




 --best verkaufte Product pro Jahr und MItarbeiter und im Verglich zu Gesamtumsatz
--Wie hoch war also der Anteil eines Verkäufers pro Produkt und Jahr am Gesamtumsatz





;WITH CTE
as
(
select distinct 
		e.LastName, p.ProductName,	year(orderdate) as jahr
		,sum(od.unitprice*quantity) over (partition by e.lastname, productname order by year(orderdate)) as UpLP
		,sum(od.unitprice*quantity)over (partition by year(orderdate),productname ) as UpJP
from orders o 
				inner join [order details] od on o.OrderID=od.OrderID
				inner join Employees e on e.EmployeeID=o.EmployeeID
				inner join products p on p.ProductID=od.ProductID
--order by e.LastName, year(orderdate),UpLP desc--,productname 
)
select lastname, productname, jahr, UpLP, convert(decimal(4,2),Uplp/UpJP) AnteilamGesamtUmsatz from cte
where productname = 'Pavlova' and jahr = 1996
order by lastname,jahr,productname



select EmployeeID, YEAR(orderdate),
		sum(freight) as aktFracht,
		LAG(sum(Freight),1,0) over (partition by employeeid 
									order by year(orderdate)) 
									as VorJahr,
		sum(freight) 

from orders 
group by EmployeeID, YEAR(OrderDate)
order by 1





--Window Function

----F() OVER(PARTITION BY Col1 ORDER BY Col2 DESC)

--ROW_NUMBER------------
--fortlaufende Zahl--

SELECT
		orderid,
		employeeid,
		customerid,
		freight,
		row_number () OVER ( 
			PARTITION BY employeeid
			ORDER BY freight DESC
		) Rang
	FROM orders





-------------RANK-----------------
--RANK überspringt gleichen Rang----
	SELECT
		orderid,
		employeeid,
		customerid,
		freight,
		RANK () OVER ( 
			PARTITION BY employeeid
			ORDER BY freight DESC
		) Rang
	FROM orders


---------dense_rank----------
--vergibt gleichen Rang mehrmals---


select freight , rank() over (order by freight),
				dense_Rank() over (order by freight) from orders
order by freight asc


----NTILE----
--aufteilen in gleiche Anzahl ---

select ntile(10) over (order by freight)
, freight from orders


---auch mit AGG---
--Prozentanteil

select 
	orderid,productid, 
	sum(unitprice*quantity) over (partition by orderid),
	 cast(1 *  (unitprice*quantity)/sum(unitprice*quantity) over (partition by orderid) 
		* 100 as Decimal(5,2))
	 from [Order Details]
	 order by 1,4

---,SUM(Col1) OVER (PARTITION BY Col2)
---ORDER BY Col3   ROWS UNBOUNDED PRECEDING)--aufsummieren


select orderid, sum(unitprice*quantity)
over ( order by orderid ROWS UNBOUNDED PRECEDING) 
from [order details]

select orderid, 
	sum(unitprice*quantity)
		over ( order by orderid ROWS UNBOUNDED PRECEDING) ,
	sum(unitprice*quantity)
		over ( order by orderid RANGE UNBOUNDED PRECEDING),
	sum(unitprice*quantity)
		OVER(ORDER BY orderid ROWS Between CURRENT ROW and 2 Following )    	
  ,sum(unitprice*quantity)
		OVER(ORDER BY orderid ROWS Between 2 FOLLOWING and 3 Following )    
  ,sum(unitprice*quantity)
		OVER(ORDER BY orderid ROWS Between 2 Preceding and 2 Following ) 
from [order details]




  ,SUM(Col2) OVER(ORDER BY Col1 RANGE UNBOUNDED PRECEDING) "Range" 
  ,SUM(Col2) OVER(ORDER BY Col1 ROWS UNBOUNDED PRECEDING) "Rows"   
  ,SUM(Col2) OVER(ORDER BY Col1 ROWS Between CURRENT ROW and 2 Following )     
  ,SUM(Col2) OVER(ORDER BY Col1 ROWS Between 2 FOLLOWING and 3 Following )    
  ,SUM(Col2) OVER(ORDER BY Col1 ROWS Between 2 Preceding    and 2 Following ) 


--best verkaufte Product pro Jahr und MItarbeiter und im Vergelich zu Gesamtumsatz
--Wie hoch war also der Antei eines Verkäufers pro Produkt und Jahr am Gesamtumsatz

;WITH CTE
as
(
select distinct 
		e.LastName, p.ProductName,	year(orderdate) as jahr
		,sum(od.unitprice*quantity) over (partition by e.lastname, productname order by year(orderdate)) as UpLP
		,sum(od.unitprice*quantity)over (partition by year(orderdate),productname ) as UpJP
from orders o 
				inner join [order details] od on o.OrderID=od.OrderID
				inner join Employees e on e.EmployeeID=o.EmployeeID
				inner join products p on p.ProductID=od.ProductID
--order by e.LastName, year(orderdate),UpLP desc--,productname 
)
select lastname, productname, jahr, UpLP, convert(decimal(4,2),Uplp/UpJP) AnteilamGesamtUmsatz from cte
where productname = 'Pavlova' and jahr = 1996
order by lastname,jahr,productname



select EmployeeID, YEAR(orderdate),
		sum(freight) as aktFracht,
		LAG(sum(Freight),1,0) over (partition by employeeid 
									order by year(orderdate)) 
									as VorJahr,
		sum(freight) 

from orders 
group by EmployeeID, YEAR(OrderDate)
order by 1
