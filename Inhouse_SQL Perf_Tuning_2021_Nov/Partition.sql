create partition function fzahl (int) 
as range left for values (300000, 600000)


create partition scheme schZahl 
as
partition fzahl  all to ([PRIMARY] )

select * from ku2



select * from sys.dm_db_column_store_row_group_physical_stats

select * from sys.partitions where object_id=object_id('ku2')

select * from sys.dm_db_index_physical_stats(db_id(), object_id('ku2'), null, null, 'Detailed')
GO

