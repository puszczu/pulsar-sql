
sesje
--ktora sesja blokuje ktora sesje
with sesje as
(
  select sid, serial#, schemaname, machine, process, osuser,program,  blocking_session, sql_id, prev_sql_id 
  from v$session
  where type='USER'
)
select ses1.*,sql1.sql_text,sql2.sql_text from sesje ses1 join v$sql sql1 on(ses1.sql_id = sql1.sql_id)
join v$sql sql2 on(ses1.prev_sql_id = sql2.sql_id);

with sesje as
(
  select sid, serial#, schemaname, machine, process, osuser,program,  blocking_session, sql_id, prev_sql_id 
  from v$session
  where type='USER'
),
blokady as
(
select b1.sid b1_sid, b1.serial# b1_serial#, b1.schemaname b1_schemaname, b1.sql_id,
      b2.sid b2_sid, b2.serial# b2_serial#, b2.schemaname b2_schemaname, b2.prev_sql_id
from sesje b1 /*blokowane*/  join sesje b2 /*blokujace*/ on (b1.blocking_session = b2.sid)
) 
select bl1.*, sql1.sql_text zapytanie_blokowane , sql2.sql_text zapytanie_blokujace
from blokady bl1 join v$sql sql1 on bl1.sql_id = sql1.sql_id
join v$sql sql2 on bl1.prev_sql_id = sql2.sql_id;
