--Exercícios sobre Ferramentes de DBA

1) select version();

2)
CREATE TABLESPACE TSTEMP2
  LOCATION '/opt/tmp';

create DATABASE BDTEMP2
  ENCODING 'UTF-8'
  TABLESPACE TSTEMP2;

4) select table_name,
pg_size_pretty(pg_total_relation_size(quote_ident(table_name))) as "Tam KB",
pg_total_relation_size(quote_ident(table_name)) as "Tam Byte"
from information_schema.tables
where table_schema = 'public'
order by 3 desc
limit 5;

5) drop database BDTEMP2;
   drop TABLESPACE TSTEMP2;

6)CREATE DATABASE BDTEMP3
  CONNECTION LIMIT 5;

select datname, datconnlimit from pg_database;

