/*

--->TemporalTables - != #tabelle

historisieren von Datensätzen

Wie ware der DS am 10.8.21 um 19 Uhr 43 10 Sek


Archivieren: DS wrden aus Tabellen in andere verschoben...Partitionierung


---->Graph Tabellen

Edge Node

OneWay

A-->B-->C
B-->A
A-->B
B-->C
C-->B

A-->D

where id--edge-->

shortest path



Admin vor dem Lesen von Daten hindern.. nein.. wenn dann so, dass er es nicht versteht ,was er liest

--DataMasking .. Daten sind unkenntlich
select * from employees

Maier  656453,87  Linz  Azubi
Schmidt 345,98    Linz  CEO    a*****@**.com


Maier  1007,98  Linz  Azubi
Schmidt 6754,90    Linz  CEO    andreasr@ppedv.de




--Zeilenweise Rechte
--bisher : View...Besitzverkettung
--ab SQL 2017 ---> f('CHef')--> alle
--                f('Azubi)--> nix
		          f('ma') --> alle marketingsachen sehen

--die Tabelle braucht auch eine zus. Spalte  !!


Always Enc
zb nur wenn man das Zerti (UserZertifikat)
Maier  981273jkhfjkhd983712983u1o2kejo12u



Stretch Database --> hot und cold data--> kostet pauschal 1500 Euro im Monat



TSQL.....

































*/