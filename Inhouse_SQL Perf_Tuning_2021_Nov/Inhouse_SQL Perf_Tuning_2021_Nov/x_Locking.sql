/*


Sperrniveau:
RID Zeile im Heap
KEY Zeile im Index
PAGE
EXTENT
HoBT
TABLE
FILE
METDATA


S Shared
für Lesevorgänge

IS intent shared lock..  
anderer Prozess können diesen nicht durch inkompatible Locks sperrendieses blocken

U Updatesperre

X eXklusiv
kein gleichzeitiger Zugriff

I IS SIX
werden gesetzt um eine freigegebene oder 
exklusive Sperre setzen zu können
Absichtliche Sperre


ISOLATIONSSTUFEN: 
READ COMMITTED
READ UNCOMMITTED
REPEATABLE READ
SERIALIZABLE
SNAPSHOT ISOLATION - READ COMMITTED

Sperrnivea Seitens Dev
 update table with (rowlock) --..tablock PAGLOCK, NOLOCK
 set ...

 select * from tabelle with (Snapshot, Rowlock, tablock, Pagelock)...

*/


--Blockierte Prozesse
select * from sysprocesses where blocked <>0 --Aktivitätsmonitor



SELECT distinct 
	session_id ,blocking_session_id ,wait_time ,tl.request_mode, wait_type ,last_wait_type
	,wait_resource ,transaction_isolation_level ,lock_timeout
FROM sys.dm_exec_requests er
inner join sys.dm_tran_locks tl on
	er.session_id=tl.request_session_id
WHERE blocking_session_id <> 0
GO


--Der blockierte: SQL Text
select text,* from sysprocesses pr 
cross apply sys.dm_exec_sql_text(pr.sql_handle)
where blocked <>0

--der blockierende
select text,* from sysprocesses pr 
cross apply sys.dm_exec_sql_text(pr.sql_handle)
 where spid = 55

--Sperren
--wer braucht die Sperre
--und welche Sperre möchte er haben
select * from sys.dm_tran_locks where request_session_id = 55 --GRANT
--KEY Sperre.. was macht der wartende damit
select * from sys.dm_tran_locks where request_session_id = 72 --WAIT

select * from sys.objects where object_id = 1861581670



--details für wartendene
--Wartedauer, Wartetyp, blockierende Session
--keylock hobtid=72057594043301888 dbid=19 id=lock2625ae17e00 mode=X associatedObjectId=72057594043301888
select * from sys.dm_os_waiting_Tasks where session_id = 91

--Auflistung alle Sperren und Anforderungen
--gleiche Ressource zeigt wer wen sperrt
select * from sys.dm_tran_locks where resource_database_id = db_id('adventureworks2014')

--Welche Art der Sperren
select tl1.request_session_id, tl2.request_session_id,* from sys.dm_tran_locks tl1
inner join sys.dm_tran_locks tl2
 on tl1.resource_description = tl2.resource_description
 where tl1.resource_database_id = db_id('adventureworks2014') and tl1.resource_description >''


 --Informationen zu den Beteiligten

select * from sys.dm_exec_sessions where session_id in (91,87)

--Alternative Scripte
sp_whoisactive --T. Mechanic

SELECT
  w.session_id,
  w.wait_duration_ms,
  w.wait_type,
  w.blocking_session_id,
  s.[host_name],
  r.command,
  r.percent_complete,
  r.cpu_time,
  r.total_elapsed_time,
  r.reads,
  r.writes,
  r.logical_reads,
  r.row_count,
  q.[text]
  ,q.dbid
  ,p.query_plan
  ,r.plan_handle
FROM
  sys.dm_os_waiting_tasks w
  INNER JOIN sys.dm_exec_sessions s
    ON w.session_id = s.session_id
  INNER JOIN sys.dm_exec_requests r
    ON s.session_id = r.session_id
  CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) q
  CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE
  w.session_id > 50
  AND w.wait_type NOT IN
  ('DBMIRROR_DBM_EVENT','ASYNC_NETWORK_IO'
    /* + add your own here*/)



select * from sys.dm_tran_locks tl
cross apply sys.dm_exec_sql_text(tl.handle)
 where resource_database_id = db_id('adventureworks2014')
