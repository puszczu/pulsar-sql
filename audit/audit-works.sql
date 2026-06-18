select count(1), max(c.jn_datetime) from appl_admin.global_dml_audit3f c where c.table_name = 'GM_ZAMOWIENIA'
union all
select count(1), min(c.jn_datetime) from appl_admin.global_dml_audit_fast c where c.table_name = 'GM_ZAMOWIENIA'


  
select user,
       sys_context('USERENV', 'OS_USER') as os_user,
       sys_context('USERENV', 'HOST') as machine,
       sys_context('USERENV', 'MODULE') as module
  from dual

  

select cc.table_name, count(1)
  from appl_admin.global_dml_audit3 c
 inner join appl_admin.global_dml_audit_co cc
    on cc.id = c.co_id
 group by cc.table_name

  

  select t2.trigger_name as,
       t1.status       as ct_status,
       t2.status       as cf_status,
       t1.*
  from all_triggers t1
  left join all_triggers t2
    on t2.owner = t1.owner
   and t2.table_owner = t1.table_owner
   and t2.table_name = t1.table_name
   and t2.TRIGGER_NAME != t1.TRIGGER_NAME
   and substr(t1.trigger_name, 5) = substr(t2.trigger_name, 5)
   and substr(t1.trigger_name, 1, 1) = substr(t2.trigger_name, 1, 1)
 where t1.trigger_name like 'T_CT%'

  

select c.* from appl_admin.global_dml_audit3f c where c.table_name = 'GM_ZAMOWIENIA' 
and (
((c.old_value_n is null and c.old_value_d is null and c.old_value_vc is null) and c.old_value is not null)
or ((c.new_value_n is null and c.new_value_d is null and c.new_value_vc is null) and c.new_value is not null)
)

      SELECT *
        FROM dba_objects
       WHERE status = 'INVALID'
         AND owner in ('FAKTURY', 'PULSAR', 'LMT', 'IBSI_FK');

select segment_name,
       segment_type,
       round(bytes / 1024 / 1024 / 1024, 2) as size_gb
  from dba_segments
 where owner = 'APPL_ADMIN'
   and segment_name in (
         'GLOBAL_DML_AUDIT3',
         'GLOBAL_DML_AUDIT_FAST',
         'GLOBAL_DML_AUDIT_CO',
         'GLOBAL_DML_AUDIT_KTO',
         'TRACKED_COLUMN_HISTORY',
         'JN_DATETIME_IND',
         'RECORD_ID_IND',
         'TCH_LOOKUP_IDX',
         'GDA_C_PK',
         'GDA_K_PK',
         'GDA_C_UNI',
         'GDA_K_UNI',
         'GDA_C_COL_IDX',
         'GDA_C_TAB_IDX',
         'GDA_K_USE_IDX'
       )
 order by bytes desc;

