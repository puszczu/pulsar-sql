create or replace view appl_admin.global_dml_audit3f as
select cc.data_type, c.table_name, c.column_name,
case when cc.DATA_TYPE = 'NUMBER' then to_number(a.old_value) else null end as old_value_n,
       case when cc.DATA_TYPE = 'DATE' then to_date(a.old_value, 'yyyy-mm-dd hh24:mi:ss') else null end as old_value_d,
       case when cc.DATA_TYPE = 'VARCHAR2' then a.old_value else null end as old_value_vc,
       case when cc.DATA_TYPE = 'NUMBER' then to_number(a.new_value) else null end as new_value_n,
       case when cc.DATA_TYPE = 'DATE' then to_date(a.new_value, 'yyyy-mm-dd hh24:mi:ss') else null end as new_value_d,
       case when cc.DATA_TYPE = 'VARCHAR2' then a.new_value else null end as new_value_vc,
       k.jn_user,
       k.jn_osuser,
       k.jn_machine,
       k.jn_program,
       k.jn_module,
       a.jn_operation,
       a.jn_datetime,
       a.record_id,

       a.old_value,
       a.new_value,
       a.id
  from appl_admin.global_dml_audit3 a
 inner join appl_admin.global_dml_audit_kto k
    on k.id = a.kto_id
 inner join appl_admin.global_dml_audit_co c
    on c.id = a.co_id
  left join all_tab_cols cc
    on cc.COLUMN_NAME = c.column_name
   and cc.TABLE_NAME = c.table_name;
