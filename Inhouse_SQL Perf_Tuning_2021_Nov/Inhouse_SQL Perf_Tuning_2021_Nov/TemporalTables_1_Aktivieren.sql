--https://docs.microsoft.com/de-de/sql/relational-databases/tables/temporal-tables?view=sql-server-ver15
--https://docs.microsoft.com/de-de/azure/azure-sql/database/temporal-tables-retention-policy


Create database TemporalTables
GO

Use TemporalTables
GO

Create table contacts  
( 
Cid int identity primary key, 
Lastname varchar(50), 
Firstname varchar(50), 
Birthday date, 
Phone varchar(50), 
email varchar(50), 
StartDatum datetime2 Generated always as row start not null, 
EndDatum datetime2 Generated always as row end not null, 
Period for system_time (Startdatum, Enddatum) 
) 
with (system_Versioning = ON (History_table=dbo.Contactshistory)) 
GO


--Aktivieren bei bestehenden Tabellen
CREATE TABLE Demo2 
( 
SP1 int identity primary key, 
SP2 int, 
StartFrom datetime2 not null, EndTo datetime2 not null
); 

--Aktivierung der PERIOD 

ALTER TABLE demo2 
ADD PERIOD FOR SYSTEM_TIME(StartFrom,EndTo) 

--Aktivierung des SYSTEM_VERSIONING 

ALTER TABLE demo2
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.demohistory, DATA_CONSISTENCY_CHECK = ON)) 

--falls Datumsspalten für Versionierung nich  nicht vorhanden sind
CREATE TABLE Demo3 
( 
SP1 int identity primary key, SP2 int 
) 
 

ALTER TABLE demo3 
ADD PERIOD FOR SYSTEM_TIME (StartFrom, EndTo), 
StartFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT GETUTCDATE(), 
EndTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT CONVERT(DATETIME2,'9999.12.31'); 
     

ALTER TABLE demo3 
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.demo3history, DATA_CONSISTENCY_CHECK = ON)) 


Alter Table contacts 
set (system_versioning=on)

drop table contacts


---NEU

--historie autom löschen

 -- HISTORY_RETENTION_PERIOD = 6 MONTHS

 ALTER TABLE dbo.contacts
SET (SYSTEM_VERSIONING = ON (HISTORY_RETENTION_PERIOD = 9 DAYS));


SELECT DB.is_temporal_history_retention_enabled,
SCHEMA_NAME(T1.schema_id) AS TemporalTableSchema,
T1.name as TemporalTableName,  SCHEMA_NAME(T2.schema_id) AS HistoryTableSchema,
T2.name as HistoryTableName,T1.history_retention_period,
T1.history_retention_period_unit_desc
FROM sys.tables T1  
OUTER APPLY (select is_temporal_history_retention_enabled from sys.databases
where name = DB_NAME()) AS DB
LEFT JOIN sys.tables T2
ON T1.history_table_id = T2.object_id WHERE T1.temporal_type = 2