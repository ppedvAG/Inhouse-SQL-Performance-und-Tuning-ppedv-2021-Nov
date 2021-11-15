
Use Northwind;
GO

DROP TABLE IF EXISTS dbo.tblcutted;
GO


create table tblCutted
	(id				int identity,
		vorname		varchar(30),
		nachname	varchar(10)
	);
GO

-- oder so aktivieren...bzw deaktiveren DBCC TRACEOFF (460) 
ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 120
GO

insert into tblcutted values ('Hans','Moser')
insert into tblCutted values ('Peter', 'Ibrahimnonixwissitsch')

ALTER DATABASE [Northwind] SET COMPATIBILITY_LEVEL = 150
GO

insert into tblcutted values ('Hans','Moser')
insert into tblCutted values ('Peter', 'Ibrahimnonixwissitsch')



update tblCutted set Nachname = 'Underweissvonix' where id = 1
