/*
Ola Hallengren 

dieses Script brauchte ich auf jeden Fall bei SQL 2014 und früher!
--> Wartungsplan war bis dorthin MIST!!!


Fragmentierungsgrad

> 30% REBUILD
< 10% nix
dazwischen REORG

Aufwand: 200MB HEAP --> 1 CL IX + 2 NCL IX ==> 363 MB 


REBUILD 
	mit tempdb oder ohne (Sortieren)
	offline oder online

	Aufwendigste: Online + temdb  (Teilweise gelogen)  ==>1100
			      Offline ohne tempdb   ==> 860MB

REORG



--> DTA --> reale hypthotische IX
--> QueryStore

select 13000*8=104MB
select 104*.67



Überflüssige Indizes müssen weg

--das sind die, die: weder IX SCAN nocht IX SEEK




*/
--kein Neustart des SQL Server!!!!!!!
select * from sys.dm_db_index_usage_Stats where database_id=DB_ID()

--Wann wurde er das letzte mal geseek.. wie oft seek und Scan.. welche ohne Seek und scans ber updates

--Index-ID= 0 = HEAP 
--          1 = CL IX
--         >  NCL IX
select * from sys.indexes


select GETDATE()



select object_name(i.object_id) as TableName
      ,i.type_desc,i.name
      ,us.user_seeks, us.user_scans
      ,us.user_lookups,us.user_updates
      ,us.last_user_scan, us.last_user_update
  from sys.indexes as i
       left outer join sys.dm_db_index_usage_stats as us
                    on i.index_id=us.index_id
                   and i.object_id=us.object_id
 where objectproperty(i.object_id, 'IsUserTable') = 1
go



--und fehlende Indizes

select p.query_plan
   from sys.dm_exec_cached_plans
        cross apply sys.dm_exec_query_plan(plan_handle) as p
  where p.query_plan.exist(
         'declare namespace
          mi="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
            //mi:MissingIndexes')=1
go


set showplan_xml off

;with XmlNameSpaces('http://schemas.microsoft.com/sqlserver/2004/07/showplan'
                      as qp)
  ,MissingIndexPlans(query_plan) as 
   (
    select p.query_plan
      from sys.dm_exec_cached_plans
           cross apply sys.dm_exec_query_plan(plan_handle) as p
     where p.query_plan.exist(
            'declare namespace
             mi="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
               //mi:MissingIndexes')=1
   )
  ,Statements(StatementId, StatementText, StatementType
             ,StatementCost, StatementRows, MissingIndexesXml) as 
   (
     select stmt.value('(//qp:Statements/qp:StmtSimple)[1]/@StatementId'
                      ,'int')
       ,stmt.value('(//qp:Statements/qp:StmtSimple)[1]/@StatementText'
                       ,'nvarchar(max)')
       ,stmt.value('(//qp:Statements/qp:StmtSimple)[1]/@StatementType'
                      ,'nvarchar(80)')
       ,stmt.value('(//qp:Statements/qp:StmtSimple)[1]/@StatementSubTreeCost'
                   ,'float')
       ,stmt.value('(//qp:Statements/qp:StmtSimple)[1]/@StatementEstRows'
                  ,'float')
       ,stmt.query('//qp:MissingIndexes')
       from MissingIndexPlans
            cross apply query_plan.nodes('//qp:StmtSimple') as qp(stmt)
   )
   ,MissingIndexGroup(StatementId, StatementText, StatementType
                      ,StatementCost, StatementRows
                      ,Impact, MissingIndexXml) as
   (
     select StatementId, StatementText, StatementType
           ,StatementCost, StatementRows
           ,mi.value('@Impact', 'float')
           ,mi.query('.[position()]/qp:MissingIndex')
       from Statements
            cross apply MissingIndexesXml.nodes('//qp:MissingIndexGroup')
                        as mig(mi)
   )
   ,MissingIndex(StatementId, StatementText, StatementType
            ,StatementCost, StatementRows
            ,Impact, DbName, TableName
            ,EqualityColumnsXml, InEqualityColumnsXml, IncludeColumnsXml) as
   (
     select StatementId, StatementText, StatementType
           ,StatementCost, StatementRows
           ,Impact
           ,mi.value('@Database', 'sysname')
           ,mi.value('@Table', 'sysname')
           ,mi.query('//qp:ColumnGroup[@Usage="EQUALITY"]')
           ,mi.query('//qp:ColumnGroup[@Usage="INEQUALITY"]')
           ,mi.query('//qp:ColumnGroup[@Usage="INCLUDE"]')
       from MissingIndexGroup
            cross apply MissingIndexXml.nodes('//qp:MissingIndex') as mig(mi)
   )
   ,ColumnGroup(StatementId, StatementText, StatementType
               ,StatementCost, StatementRows
               ,Impact, DbName, TableName
               ,IndexColumns, IncludeColumns) as
   (
     select StatementId, StatementText, StatementType
           ,StatementCost, StatementRows
           ,Impact, DbName, TableName
           ,ltrim(replace(cast(
        EqualityColumnsXml.query('data(//qp:Column/@Name)') as nvarchar(max))
               + ' '
               + cast(InEqualityColumnsXml.query('data(//qp:Column/@Name)')
                      as nvarchar(max)), '] [','],['))
           ,replace(cast(IncludeColumnsXml.query('data(//qp:Column/@Name)') 
                      as nvarchar(max)), '] [','],[')
       from MissingIndex
   )
select StatementId, StatementText, StatementType
      ,StatementCost, StatementRows
      ,Impact, DbName, TableName, IndexColumns, IncludeColumns
  from ColumnGroup
go