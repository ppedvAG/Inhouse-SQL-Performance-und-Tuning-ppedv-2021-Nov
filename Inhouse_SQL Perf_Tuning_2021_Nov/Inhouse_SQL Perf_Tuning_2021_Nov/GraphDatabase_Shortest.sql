use master;
GO

/*
Mary--John--Sepp--Dieter
Mary--;Hans--Dieter



*/

drop database if exists Graphdb;
GO

create database Graphdb;
GO

use graphdb
go
drop table if exists person
drop table if exists friendof

CREATE TABLE Person (
  ID INTEGER PRIMARY KEY,
  name VARCHAR(100)
) AS NODE;

select * from person

CREATE TABLE friendOf AS EDGE;
select * from friendof


INSERT INTO Person VALUES (1,'Stefan');
INSERT INTO Person VALUES (2,'Daniel');
INSERT INTO Person VALUES (3,'John');
INSERT INTO Person VALUES (4,'Mary');
INSERT INTO Person VALUES (5,'Jacob');
INSERT INTO Person VALUES (6,'Julie');
INSERT INTO Person VALUES (7,'Alice');
INSERT INTO Person VALUES (8,'Hans');
INSERT INTO Person VALUES (9,'Max');
INSERT INTO Person VALUES (10,'Susi');


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 2), 
 (SELECT $node_id FROM Person WHERE ID = 1));
 
 INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 4), 
 (SELECT $node_id FROM Person WHERE ID = 5));

 INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 5), 
 (SELECT $node_id FROM Person WHERE ID = 1));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 3), 
 (SELECT $node_id FROM Person WHERE ID = 2));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 4), 
 (SELECT $node_id FROM Person WHERE ID = 3));


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 3), 
 (SELECT $node_id FROM Person WHERE ID = 4));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 5), 
 (SELECT $node_id FROM Person WHERE ID = 4));


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 4), 
 (SELECT $node_id FROM Person WHERE ID = 7));

 
INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 8), 
 (SELECT $node_id FROM Person WHERE ID = 7));


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 10), 
 (SELECT $node_id FROM Person WHERE ID = 4));

INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 10), 
 (SELECT $node_id FROM Person WHERE ID = 8));


INSERT INTO friendof 
VALUES 
((SELECT $node_id FROM Person WHERE ID = 7), 
 (SELECT $node_id FROM Person WHERE ID = 3));

 

 select * from friendOf



--Freunde
SELECT PersonName, Friends
FROM (  
	 SELECT
       Person1.name AS PersonName, 
       STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
       LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode
     FROM
       Person AS Person1,
       friendOf FOR PATH  AS fo,
       Person	FOR PATH  AS Person2
      WHERE 
	    MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
			AND 
		Person1.name = 'Mary'
) AS Q
WHERE Q.LastNode = 'Stefan'


--Markus Ehrenmüller--- GoT
---kürzesten Wege zu allen vernetzten Freunden
SELECT
   Person1.name AS PersonName, 
   STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends
FROM
   Person AS Person1,
   friendOf FOR PATH AS fo,
   Person FOR PATH  AS Person2
WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
AND Person1.name = 'Hans'


SELECT PersonName, Friends, levels
FROM (  
   SELECT
       Person1.name AS PersonName, 
       STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
       LAST_VALUE(Person2.name) WITHIN GROUP (GRAPH PATH) AS LastNode,
       COUNT(Person2.name) WITHIN GROUP (GRAPH PATH) AS levels
   FROM
       Person AS Person1,
       friendOf FOR PATH AS fo,
       Person FOR PATH  AS Person2
   WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2)+))
   AND Person1.name = 'Hans'
   	) AS Q
WHERE Q.LastNode = 'Stefan'

--2 Hops entfernt
SELECT PersonName, Friends
FROM (
    SELECT
        Person1.name AS PersonName, 
        STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
        COUNT(Person2.name) WITHIN GROUP (GRAPH PATH) AS levels
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,5}))
    AND Person1.name = 'Jacob'
) Q
WHERE Q.levels = 2


alter table person add Distanz int -- Entfernung von best X..so als Idee

update Person set Distanz = id % 3
update Person set Distanz = 5 where Distanz = 0



SELECT PersonName, Friends, levels
FROM (
    SELECT
        Person1.name AS PersonName, 
        STRING_AGG(Person2.name, '->') WITHIN GROUP (GRAPH PATH) AS Friends,
        sum(Person2.Distanz) WITHIN GROUP (GRAPH PATH) AS levels
    FROM
        Person AS Person1,
        friendOf FOR PATH AS fo,
        Person FOR PATH  AS Person2
    WHERE MATCH(SHORTEST_PATH(Person1(-(fo)->Person2){1,3}))
    AND Person1.name = 'Jacob'
) Q
WHERE Q.levels = 1


select * from person

