--statt Startparameter des Servers
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = OFF
GO



ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = On;
GO



----------------------------------------
--MAXDOP
----------------------------------------
--serversettings:
EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO


--MAXDOP in DB
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO


Use nwindbig

select * into o1 from Orders
select * into c1 from customers

--BEISPIELL 1
--Anzahl gelesener Zeilen.. THREADS...??
set statistics io, time on
select * 
from 
		Customers c inner join orders o 
		on
		c.CustomerID=o.CustomerID
where 
		o.OrderID < 100000
		AND
		c.CustomerID like '%G'
		option (maxdop 6)



--BEISPIEL 2:

set statistics io , time on

--TABLE SCAN: Threads und Anzahl
--SELECT Branches und Threads
select * from c1 inner join o1
	on c1.CustomerID=o1.CustomerID
	where	
	c1.CustomerID like  'bl%'
	and
	o1.employeeid < 3500	
	order by EmployeeID desc, o1.CustomerID desc

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
	st.text like '%c1.customerid%'
	and
	st.text not like N'%dm_exec_Query_Stats%'


----Paramter Sniefing
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

-------------------------------------------------------
--OPTIMZE FOR AD_HOC_WORKLOADS
------------------------------------------------------

alter database scoped configuration set optimize_for_ad_hoc_workloads=OFF
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO


declare @stmt nvarchar(128)= N'SELECT * from dbo.orders where orderid = %i;'
DECLARE @exec nvarchar(128) = N''
declare @i int = 100


while @i > 0 
begin
	set @exec = REPLACE(@stmt,'%i', CAST(@i as nvarchar(10)));
	print @exec
	exec (@exec);
	set @i-=1
end
GO

declare @stmt nvarchar(128)= N'SELECT * from dbo.orders where orderid = %i;'
DECLARE @exec nvarchar(128) = N''
declare @i int = 100


while @i > 0 
begin
	set @exec = REPLACE(@stmt,'%i', CAST(@i as nvarchar(10)));
	print @exec
	exec (@exec);
	set @i-=10
end
GO

--´Stets neue Pläne "compiled plan" mit 16k
select st.text, cp.size_in_bytes, cp.usecounts,cp.cacheobjtype
from 
			sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
where 
			objtype = 'Adhoc' and st.text like '%orders%'

--nun mit adhocworkload optimized

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
alter database scoped configuration set optimize_for_ad_hoc_workloads=ON
--ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

declare @stmt nvarchar(128)= N'SELECT * from dbo.orders where orderid = %i;'
DECLARE @exec nvarchar(128) = N''
declare @i int = 100


while @i > 0 
begin
	set @exec = REPLACE(@stmt,'%i', CAST(@i as nvarchar(10)));
	print @exec
	exec (@exec);
	set @i-=1
end
GO

declare @stmt nvarchar(128)= N'SELECT * from dbo.orders where orderid = %i;'
DECLARE @exec nvarchar(128) = N''
declare @i int = 100


while @i > 0 
begin
	set @exec = REPLACE(@stmt,'%i', CAST(@i as nvarchar(10)));
	print @exec
	exec (@exec);
	set @i-=10
end
GO

--´Nujn werden Pläne aus Kopie gezogen... 136bytes
--Compiled Stub plan
select st.text, cp.size_in_bytes, cp.usecounts,cp.cacheobjtype
from 
			sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
where 
			objtype = 'Adhoc' and st.text like '%orders%'


--richtiger Weg
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
alter database scoped configuration set optimize_for_ad_hoc_workloads=OFF

declare @stmt nvarchar(128) =N'SELECT * from orders where orderid = @i'
declare @i int = 100
while @i>0
begin
	exec sp_executesql @stmt, N'@i int', @i;
	set @i-=1
end


select st.text, cp.size_in_bytes, cp.usecounts,
		cp.cacheobjtype
from 
			sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(cp.plan_handle) st
where 
			 st.text like '%orders%' and
			 st.text not like '%dm_exec%'
	
------------------------------------------------
--Accelerated database recovery on
------------------------------------------------
select name,sd.is_accelerated_database_recovery_on from sys.databases sd
alter database nwindbig set accelerated_database_recovery = Off 