--TempDB Metadaten 
--bei hoher Verwendung von tempdb (zB #tabellen)
--evtl Latchproblem.. 
--seit 2019 können die top systemtabellen der tempdb in Memory sein...
--allerdings kann es passieren, dass dafür andere Dinge nicht klappen,
--wie das Schätzen der Kompression
--von ColumnStore Indizes



set statistics io on

DROP TABLE IF EXISTS #tempTab

CREATE TABLE #tempTab
  (id		INT NOT NULL,
   speaker  VARCHAR(10));

INSERT INTO #tempTab
  (id, Speaker)
VALUES
  (1, 'Ich'),
  (2, 'Ricken'),
  (3, 'Raatz'),
  (4, 'Belssing'),
  (5, 'Rauch');
GO 

set statistics io , time on

SELECT  * FROM tempdb.sys.tables;
--plan

ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = on;

EXEC sys.sp_configure N'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sys.sp_configure N'tempdb metadata memory-optimized', 1;
RECONFIGURE WITH OVERRIDE;

SELECT SERVERPROPERTY('IsTempDBMetadataMemoryOptimized') AS IsTempDBMetadataMemoryOptimized;
--Neustart

--RESTART
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = off;


select * into #testx from tempdb.sys.tables
