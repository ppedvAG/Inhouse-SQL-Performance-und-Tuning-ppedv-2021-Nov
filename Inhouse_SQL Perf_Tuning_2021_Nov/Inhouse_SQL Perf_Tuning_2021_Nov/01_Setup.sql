/*SETUP


Instanzen: ca 50 Instanzen (sind isoliert)

Vorteile wenn Securityabschottung
		weil die Software das braucht
		weil die eine Software gewisse Settings braucht: ZB Sharepoint braucht spez Serversettings
		--seit SQL 2016: Scoped Database.. Settings pro DB

Pfaden der DBs und Backup
? 
Lastverteilung... Trenne Log von Daten--> physikalisch per HDDs
Standardpfade!

Entscheidung pro DB

Messung: Perfmon: Phsikalischer Datenträger: Durschn. Wart5eschlangenLänge des Datenträgers: unter 2 
--auf Dauer nicht die 2 überschreiten


tempdb (normale DB)
Was tut die denn ?
DEV: #t ##t        Zeilenversionierung
ADMIN: IX Wartung  Zeilenversionierung

--TRACEFLAG T 1117 UNIFORM EXTENTS
--          T 1118 

Anzahl der CPUS = Anzahl der DATEIEN!
x CPU --> max 8 Dateien

MAXDOP: max Anzahl der CPUs pro Abfrage (MAX 8)
Standardwert war : 0  = ALLE

RAM
0 - 216534654365  --> BUfferpool (Daten)
0 bis 8800 bei 12 GB -- Gesamt RAM  minus OS
--10% für OS reservieren!  -- 100GB--> 1 TB RAM --> 100GB ??
--bis 4GB -- bis 8Gb -- bis 16GB
--> 4 GB sind ok

--der Max Grenzwert gilt sofort
--der MIn Wert gilt erst wenn erreicht


FILESTREAMING


\\SERVER\SQLINSTANZ\DBALIAS\TABALIAS  = virt Tabelle in SQL Server (Filetable)
--Gesamt Verwaltung dierer Freigaben ist im SQL Server 
--Security
--BACKUP RESTORE
--SQL VOLLTEXTSUCHE

--WINFS --> SQL 2012 Filetable





Security

Dienstkonten
--Volumewartungstask?

10 Vergrößerung bedeutete am Ende 20 MB Schreiben
-----------------------
10101010101111111111111
-----------------------

Warum Ausnullen?-- Daten zur Sicherheit überschrieben
--den Haken setzne ist dem guten Admin egal...


Ein guter Admin sorgt dafür dass DB nicht willlkürlich wachsen











Pfaden der DBs und Backup



Sortierung


Filestreaming

Freig Features + Instanzfeatures







*/

--Bei Virtualisierung

--MIgration von Server1 zu Server2
--              1 NUMA 4 Kernen  -->  2 NUMA 16 KERNEN
--Energiesparplan.. Ausbalanciert--> Hochleistung
--HDD