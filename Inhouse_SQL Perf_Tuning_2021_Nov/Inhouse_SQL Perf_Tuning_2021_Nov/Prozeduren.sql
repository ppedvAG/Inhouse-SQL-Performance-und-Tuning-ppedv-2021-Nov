create proc gptest @id int
as
begin
	select * from t1 where id < @id
	OPTION (optimize for (@id =1000000))
end
GO
exec gptest 2