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


 select 'select ''' || c1.TABLE_NAME ||
        ''' as table_name, round(sum(dbms_lob.getlength(d1.' ||
        c1.COLUMN_NAME || ')) / 1024 / 1024 / 1024, 2) as size_in_gb from ' ||
        c1.owner || '.' || c1.TABLE_NAME || ' d1 union all ' as sql_text
   from all_tab_cols c1
  inner join all_tables tab
     on tab.TABLE_NAME = c1.table_name
    and tab.OWNER = c1.owner
  where c1.owner in ('PULSAR', 'LMT', 'REST', 'FAKTURY', 'IBSI_FK', 'ZAM')
    and c1.DATA_TYPE = 'BLOB'
