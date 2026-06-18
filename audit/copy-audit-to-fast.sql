declare
  i number := 0;
begin
  for r in (select a.id,
                   a.jn_operation,
                   a.jn_datetime,
                   a.jn_user,
                   a.jn_osuser,
                   a.jn_machine,
                   a.jn_program,
                   a.jn_module,
                   a.table_name,
                   a.column_name,
                   a.record_id,
                   a.old_value_vc,
                   a.new_value_vc,
                   a.old_value_n,
                   a.new_value_n,
                   a.old_value_d,
                   a.new_value_d,
                   a.data_type
              from appl_admin.global_dml_audit3f a
             where a.table_name = 'GM_ZAMOWIENIA') loop
    insert into appl_admin.global_dml_audit_fast
      (id,
       jn_operation,
       jn_datetime,
       jn_user,
       jn_osuser,
       jn_machine,
       jn_program,
       jn_module,
       table_name,
       column_name,
       record_id,
       old_value_vc,
       new_value_vc,
       old_value_n,
       new_value_n,
       old_value_d,
       new_value_d,
       data_type)
    values
      (r.id,
       r.jn_operation,
       r.jn_datetime,
       r.jn_user,
       r.jn_osuser,
       r.jn_machine,
       r.jn_program,
       r.jn_module,
       r.table_name,
       r.column_name,
       r.record_id,
       r.old_value_vc,
       r.new_value_vc,
       r.old_value_n,
       r.new_value_n,
       r.old_value_d,
       r.new_value_d,
       r.data_type);
  
    i := i + 1;
  
    if mod(i, 1000) = 0 then
      commit;
    end if;
  
  end loop;
  commit;
end;
