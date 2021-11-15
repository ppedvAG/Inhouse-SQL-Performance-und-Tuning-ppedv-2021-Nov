set statistics io, time on
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF;

--BatchMode. eigtl dem ColumnStore vorbehalten..
--Seit SQL 1019 auch in RowStore verfügbar..
--fall ColStore nicht verwendet werden soll
--nicht bei im tabellen
--auch nicht bei XML oder sparse columns
--Cursor


use AdventureWorksDW2016_EXT
go
--alter database AdventureWorksDW2016_EXT set compatibility_level = 120;
go

select salesorderlinenumber,sum(TotalProductCost) 
from dbo.FactResellerSalesXL_PageCompressed
group by salesorderlinenumber
--6500  1000
----Row Mode.. KompLevele: 140

alter database AdventureWorksDW2016_EXT set compatibility_level = 150;
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON;

go

select salesorderlinenumber,sum(TotalProductCost) 
from dbo.FactResellerSalesXL_PageCompressed
group by salesorderlinenumber
--3500 700




