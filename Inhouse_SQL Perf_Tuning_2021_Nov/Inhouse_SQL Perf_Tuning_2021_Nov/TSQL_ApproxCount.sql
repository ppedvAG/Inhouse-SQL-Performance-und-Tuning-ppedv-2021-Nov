

--Nicht immer muss eine exakte Schätzung sein,...
--kostet weniger...;-)

use StackOverflow2010;
go

select top 1000000 *, NULL as NULLSP into approx from Posts


update approx set NULLSP = case 
							when Id % 3=0 then NULL
							ELSE id
						end

select * FROM approx

set statistics time on

select COUNT(distinct nullsp) from approx
GO
select approx_Count_Distinct (nullsp) from approx