--Exercícios sobre Ferramentes de DBA

1) select version();

2)
CREATE TABLESPACE TSTEMP2
  LOCATION '/opt/tmp';

create DATABASE BDTEMP2
  ENCODING 'UTF-8'
  TABLESPACE TSTEMP2;

4) SELECT table_name,pg_relation_size(table_name) as size
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY size DESC
LIMIT 5;

5) drop database BDTEMP2;
   drop TABLESPACE TSTEMP2;

6)CREATE DATABASE BDTEMP3
  CONNECTION LIMIT 5;
