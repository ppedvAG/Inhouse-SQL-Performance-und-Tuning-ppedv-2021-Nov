--Ressourcenpool 
create resource pool PoolAdmin

--Ressourcenpool
create resource pool PoolMarketing

--Arbeitsauslastungsgruppe
create workload group GroupAdmins
using PoolAdmin
go

create workload group GroupMAAzubis
using PoolMarketing
go
--Arbeitsauslastungsgruppe
create workload group GroupMarketing
using PoolMarketing
go
--- Klassifizierungsfunktion

use master;
GO

Create or alter function classifier_Hans_Susi()
returns sysname with schemabinding
begin
	declare @val varchar(30)
	if 'Hans' = Suser_sname()
		set @val='GroupAdmins'
	else if 'Susi' = suser_sname()
		set @val='GroupMarketing'
	else if 'Peter' = suser_sname()
		set @val='GroupMAAzubis'
	
	return @val
end


alter resource governor reconfigure

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = [dbo].[classifier_Hans_Susi]);
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

ALTER RESOURCE POOL [PoolAdmin] WITH(
		min_cpu_percent=50, 
		AFFINITY SCHEDULER = AUTO)
GO

ALTER RESOURCE POOL [PoolMarketing] WITH(
		min_cpu_percent=5, 
		max_cpu_percent=20, 
		AFFINITY SCHEDULER = AUTO)
GO

ALTER WORKLOAD GROUP [GroupMAAzubis] WITH(group_max_requests=1)
GO

ALTER WORKLOAD GROUP [GroupMarketing] WITH(group_max_requests=5, 
		importance=High)
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;
GO



	




--LOADING TRaffic

declare @i as int
set @i = 1


while 1=1

begin
set @i = @i +1

if @i > 500000
break
end