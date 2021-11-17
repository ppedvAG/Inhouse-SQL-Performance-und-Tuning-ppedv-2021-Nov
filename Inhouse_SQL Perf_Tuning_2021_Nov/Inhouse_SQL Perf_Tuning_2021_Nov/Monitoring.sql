--MONITORING
select * from sys.dm_os_wait_stats --running--suspended--Runnable


--Query--->(FIFO)-->Worker-->Resourcen-->


--0----------------|60ms--------->90ms| RUNNING


--Wait_time: 90ms
--signal: 90-60ms= 30ms

--Signal mehr als 25% der Wartezeit (90)   CPU Engpass

select * from sys.dm_os_wait_Stats order by 3 desc

--was sagt mir der Wert: 7738582 --9738582

--die Werte sind seit Neustart kummulierend

--also sagt der Wert zunächst nichts aus

--Idee:.  SUMME aller Wartezeiten, dann Antweil des einz Wartetyps
--7%  69%   --> Signal 25%
--alle Wartetypen müssen nicht angeschaut werden


--TOP Abfragen

--DB Dateigrößen
--DBX Datei 100--200   50--400

--Perfmondaten



select * from sys.dm_os_performance_counters

