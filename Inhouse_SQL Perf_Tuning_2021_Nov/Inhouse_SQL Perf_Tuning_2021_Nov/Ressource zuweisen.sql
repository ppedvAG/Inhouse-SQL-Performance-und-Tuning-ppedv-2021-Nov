select * from sys.dm_resource_governor_workload_groups
select * from sys.dm_resource_governor_resource_pools
select * from sys.dm_resource_governor_configuration

alter resource pool PoolAdmin
with (min_CPU_percent = 50)
	
alter resource pool PoolAdmin
with (max_CPU_percent = 70)

alter resource pool poolmarketing
	with (max_cpu_percent=30)

alter resource governor reconfigure


select * from sysprocesses 
