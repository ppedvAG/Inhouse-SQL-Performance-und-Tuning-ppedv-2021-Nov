use RessControllDB;
GO


select suser_sname()

Waitfor delay '00:00:2'

declare @i as int
set @i = 1


while 1=1

begin
set @i = @i % 1000 *3 /17 
--print @i
if @i > 1000000
break
end





--set NOCOUNT ON;
--go
--declare @x decimal(10,5);
--set @x=sin(rand())*cos(rand())*tan(rand());
--go 100000000