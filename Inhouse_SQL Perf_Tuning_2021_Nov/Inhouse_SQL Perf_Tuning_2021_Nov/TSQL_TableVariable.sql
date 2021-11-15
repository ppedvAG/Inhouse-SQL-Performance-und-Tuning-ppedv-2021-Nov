
alter database northwind set compatibility_level=150 --120


set statistics io, time on
DECLARE @MyTab TABLE			(
       orderid int,
       freight money,
       customerid nchar(5),
	   orderdate datetime,
	   employeeid int,
	   shipccountry nvarchar(50),
	   shipcity nvarchar(50)	)

insert into @MyTab
select orderid ,
       freight ,
       customerid ,
	   orderdate ,
	   employeeid ,
	   shipcountry ,
	   shipcity 	from nwindbig..orders


select * from @MyTab where orderid < 5

set statistics io, time off