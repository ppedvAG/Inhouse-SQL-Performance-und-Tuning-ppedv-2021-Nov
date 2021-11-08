-- You want to see 0 for process_physical_memory_low
-- You want to see 0 for process_virtual_memory_low
-- This indicates that you are not under internal memory pressure
-- If locked_page_allocations_kb > 0, then LPIM is enabled
SELECT 
	physical_memory_in_use_kb/1024 AS sql_physical_memory_in_use_MB, 
    large_page_allocations_kb/1024 AS sql_large_page_allocations_MB, 
    locked_page_allocations_kb/1024 AS sql_locked_page_allocations_MB,
    virtual_address_space_reserved_kb/1024 AS sql_VAS_reserved_MB, 
    virtual_address_space_committed_kb/1024 AS sql_VAS_committed_MB, 
    virtual_address_space_available_kb/1024 AS sql_VAS_available_MB,
    page_fault_count AS sql_page_fault_count,
    memory_utilization_percentage AS sql_memory_utilization_percentage, 
    process_physical_memory_low AS sql_process_physical_memory_low, 
    process_virtual_memory_low AS sql_process_virtual_memory_low
FROM sys.dm_os_process_memory;  


SELECT dosi.physical_memory_kb, 
       dosi.virtual_memory_kb, 
       dosi.committed_kb, 
       dosi.committed_target_kb
FROM sys.dm_os_sys_info dosi;


SELECT dosm.total_physical_memory_kb, 
       dosm.available_physical_memory_kb, 
       dosm.system_memory_state_desc
FROM sys.dm_os_sys_memory dosm;

-- dbcc dropcleanbuffers
-- dbcc freeproccache
--BUFFER -- CLEAN DIRTY
--  checkpoint
SELECT (CASE 
           WHEN ( [database_id] = 32767 ) THEN 'Resource Database' 
           ELSE Db_name (database_id) 
         END )  AS 'Database Name', 
       Sum(CASE 
             WHEN ( [is_modified] = 1 ) THEN 0 
             ELSE 1 
           END) AS 'Clean Page Count',
		Sum(CASE 
             WHEN ( [is_modified] = 1 ) THEN 1 
             ELSE 0 
           END) AS 'Dirty Page Count'
FROM   sys.dm_os_buffer_descriptors 
GROUP  BY database_id 
ORDER  BY DB_NAME(database_id);




SELECT 'Page File' AS MemoryType
    ,CONVERT(DECIMAL(10, 2), 1.0 * total_page_file_kb / 1024) AS Total_MB
    ,CONVERT(DECIMAL(10, 2), 1.0 * available_page_file_kb / 1024) AS Free_MB
    ,CONVERT(VARCHAR(5), CONVERT(DECIMAL(10, 1),
        100.0 * available_page_file_kb / total_page_file_kb)) + '%' AS Free
FROM sys.dm_os_sys_memory
UNION ALL
SELECT 'Physical (RAM)'
    ,CONVERT(DECIMAL(10, 2), 1.0 * total_physical_memory_kb / 1024)
    ,CONVERT(DECIMAL(10, 2), 1.0 * available_physical_memory_kb / 1024)
    ,CONVERT(VARCHAR(5), CONVERT(DECIMAL(10, 1),
        100.0 * available_physical_memory_kb / total_physical_memory_kb)) + '%'
FROM sys.dm_os_sys_memory
UNION ALL
SELECT 'Non-Physical'
    ,CONVERT(DECIMAL(10, 2),
         1.0 * (total_page_file_kb - total_physical_memory_kb) / 1024)
    ,CONVERT(DECIMAL(10, 2),
         1.0 * (available_page_file_kb - available_physical_memory_kb) / 1024)
    ,CONVERT(VARCHAR(5), CONVERT(DECIMAL(10, 1),
       100.0 * (available_page_file_kb - available_physical_memory_kb)
             / (total_page_file_kb - total_physical_memory_kb))) + '%'
FROM sys.dm_os_sys_memory
UNION ALL
SELECT 'System Cache',CONVERT(DECIMAL(10, 2), 1.0 * system_cache_kb / 1024),NULL,NULL
FROM sys.dm_os_sys_memory
UNION ALL
SELECT 'Kernel: Paged'
    ,CONVERT(DECIMAL(10, 2), 1.0 * kernel_paged_pool_kb / 1024),NULL,NULL
FROM sys.dm_os_sys_memory
UNION ALL
SELECT 'Kernel: Non-Paged'
    ,CONVERT(DECIMAL(10, 2), 1.0 * kernel_nonpaged_pool_kb / 1024),NULL,NULL
FROM sys.dm_os_sys_memory
ORDER BY Total_MB DESC

--Cahced pages für DB
SELECT COUNT(*)AS cached_pages_count  
    ,CASE database_id   
        WHEN 32767 THEN 'ResourceDb'   
        ELSE db_name(database_id)   
        END AS database_name  
FROM sys.dm_os_buffer_descriptors  
GROUP BY DB_NAME(database_id) ,database_id  
ORDER BY cached_pages_count DESC;


--Cached pages für Objekte in db
SELECT COUNT(*)AS cached_pages_count   
    ,name ,index_id   
FROM sys.dm_os_buffer_descriptors AS bd   
    INNER JOIN   
    (  
        SELECT object_name(object_id) AS name   
            ,index_id ,allocation_unit_id  
        FROM sys.allocation_units AS au  
            INNER JOIN sys.partitions AS p   
                ON au.container_id = p.hobt_id   
                    AND (au.type = 1 OR au.type = 3)  
        UNION ALL  
        SELECT object_name(object_id) AS name     
            ,index_id, allocation_unit_id  
        FROM sys.allocation_units AS au  
            INNER JOIN sys.partitions AS p   
                ON au.container_id = p.partition_id   
                    AND au.type = 2  
    ) AS obj   
        ON bd.allocation_unit_id = obj.allocation_unit_id  
WHERE database_id = DB_ID()  
GROUP BY name, index_id   
ORDER BY cached_pages_count DESC;


----TOP ABFRAGEN
SELECT TOP 10 (a.total_worker_time / a.execution_count) AS [Avg_CPU_Time]
,Convert(VARCHAR, Last_Execution_Time) AS [Last_Execution_Time]
,Total_Physical_Reads
,SUBSTRING(b.TEXT, a.statement_start_offset / 2, (
CASE
WHEN a.statement_end_offset = - 1
THEN len(convert(NVARCHAR(max), b.TEXT)) * 2
ELSE a.statement_end_offset
END - a.statement_start_offset
) / 2) AS [Query_Text]
,dbname = Upper(db_name(b.dbid))
,b.objectid AS 'Object_ID', B.*
FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) AS b
ORDER BY [Avg_CPU_Time] DESC


SELECT t.object_id AS ObjectID,
       OBJECT_NAME(t.object_id) AS ObjectName,
       SUM(u.total_pages) * 8 AS Total_Reserved_kb,
       SUM(u.used_pages) * 8 AS Used_Space_kb,
       u.type_desc AS TypeDesc,
       MAX(p.rows) AS RowsCount
FROM sys.allocation_units AS u
JOIN sys.partitions AS p ON u.container_id = p.hobt_id
JOIN sys.tables AS t ON p.object_id = t.object_id
GROUP BY t.object_id,
         OBJECT_NAME(t.object_id),
         u.type_desc
ORDER BY Used_Space_kb DESC,
         ObjectName;