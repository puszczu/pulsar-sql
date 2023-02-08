SELECT owner, table_name, TRUNC(sum(bytes) / 1024 / 1024 / 1024) GB
  FROM (SELECT segment_name table_name, owner, bytes
          FROM dba_segments
         WHERE segment_type in ('TABLE', 'TABLE PARTITION')
        UNION ALL
        SELECT i.table_name, i.owner, s.bytes
          FROM dba_indexes i, dba_segments s
         WHERE s.segment_name = i.index_name
           AND s.owner = i.owner
           AND s.segment_type in ('INDEX', 'INDEX PARTITION')
        UNION ALL
        SELECT l.table_name, l.owner, s.bytes
          FROM dba_lobs l, dba_segments s
         WHERE s.segment_name = l.segment_name
           AND s.owner = l.owner
           AND s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
        UNION ALL
        SELECT l.table_name, l.owner, s.bytes
          FROM dba_lobs l, dba_segments s
         WHERE s.segment_name = l.index_name
           AND s.owner = l.owner
           AND s.segment_type = 'LOBINDEX')
---WHERE owner in UPPER('&owner')
 GROUP BY table_name, owner
HAVING SUM(bytes) / 1024 / 1024 > 10 /* Ignore really small tables */
 ORDER BY SUM(bytes) desc
