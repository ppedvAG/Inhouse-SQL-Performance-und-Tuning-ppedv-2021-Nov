use Tuning
create resource pool rpOLTP with
 (
  max_cpu_percent = 100
 ,min_cpu_percent = 40
 ,max_memory_percent = 100
 ,min_memory_percent = 90
 )
go


create resource pool rpReporting with
 (
  max_cpu_percent = 25
 ,min_cpu_percent = 0
 ,max_memory_percent = 25
 ,min_memory_percent = 0
 )
go


create workload group wlgOLTP
  with (importance = high)
  using rpOLTP
go


create workload group wlgReporting
  with (importance = low)
  using rpReporting
go


use master
go
create function dbo.rgClassification()
   returns sysname
   with schemabinding as
  begin
    declare @wlgName      sysname
           ,@current_time time
    set @current_time = cast(current_timestamp as time)
    if (@current_time between '09:00' and '20:00')
      begin
        if (app_name() like '%Reporting%')
           or (app_name() like '%Bericht%')
          set @wlgName = 'wlgReporting'
        else
          set @wlgName = 'wlgOLTP'  
      end
    return @wlgName
  end
go


use master;
alter resource governor
  with (classifier_function = dbo.rgClassification)
go
alter resource governor reconfigure;
go



--Klassifizierung vorhanden und aktiv?
--- Get the classifier function Id and state (enabled).
SELECT * FROM sys.resource_governor_configuration
GO
--- Get the classifer function name and the name of the schema
--- that it is bound to.
SELECT 
      object_schema_name(classifier_function_id) AS [schema_name],
      object_name(classifier_function_id) AS [function_name]
FROM sys.dm_resource_governor_configuration


---
--Auslastung der Ressourcenpools und Gruppen
SELECT * FROM sys.dm_resource_governor_resource_pools
SELECT * FROM sys.dm_resource_governor_workload_groups
GO


--Live Anzeige über Zuordnung zum Pool

SELECT s.group_id, CAST(g.name as nvarchar(20)), s.session_id, s.login_time, CAST(s.host_name as nvarchar(20)), CAST(s.program_name AS nvarchar(20))
          FROM sys.dm_exec_sessions s
     INNER JOIN sys.dm_resource_governor_workload_groups g
          ON g.group_id = s.group_id
ORDER BY g.name
GO


--Anziege über Abfrage je Gruppe

SELECT r.group_id, g.name, r.status, r.session_id, r.request_id, r.start_time, r.command, r.sql_handle, t.text 
           FROM sys.dm_exec_requests r
     INNER JOIN sys.dm_resource_governor_workload_groups g
            ON g.group_id = r.group_id
     CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
ORDER BY g.name
GO


--Anforderungen nach Klassifizierung
SELECT s.group_id, g.name, s.session_id, s.login_time, s.host_name, s.program_name 
           FROM sys.dm_exec_sessions s
     INNER JOIN sys.dm_resource_governor_workload_groups g
           ON g.group_id = s.group_id
              --   AND 'preconnect' = s.status
ORDER BY g.name
GO
 
SELECT r.group_id, g.name, r.status, r.session_id, r.request_id, r.start_time, r.command, r.sql_handle, t.text 
           FROM sys.dm_exec_requests r
     INNER JOIN sys.dm_resource_governor_workload_groups g
           ON g.group_id = r.group_id
                 AND 'preconnect' = r.status
     CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
ORDER BY g.name
GO