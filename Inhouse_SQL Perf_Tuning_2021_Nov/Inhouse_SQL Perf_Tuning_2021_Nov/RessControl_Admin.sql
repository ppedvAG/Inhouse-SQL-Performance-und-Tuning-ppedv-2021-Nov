use RessControllDB;
GO
select suser_sname()

Waitfor delay '00:00:30'

declare @i as int
set @i = 1


while 1=1

begin
set @i = @i % 1000 *3 /17 
--print @i
if @i > 1000000
break
end