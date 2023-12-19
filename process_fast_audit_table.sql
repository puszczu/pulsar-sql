  procedure process_fast_audit_table is
  begin
    for r in (select f.rowid,
                     f.id,
                     f.table_name,
                     f.column_name,
                     f.old_value_vc,
                     f.new_value_vc,
                     f.old_value_n,
                     f.new_value_n,
                     f.old_value_d,
                     f.new_value_d,
                     f.jn_operation,
                     f.record_id,
                     f.data_type
                from global_dml_audit_fast f
               order by f.id) loop
      if r.data_type = 'VARCHAR2' then
        check_val_c(x_table     => r.table_name,
                    x_column    => r.column_name,
                    x_old       => r.old_value_vc,
                    x_new       => r.new_value_vc,
                    x_operation => r.jn_operation,
                    x_pk        => r.record_id);
        delete from global_dml_audit_fast f where f.rowid = r.rowid;
      elsif r.data_type = 'DATE' then
        check_val_d(x_table     => r.table_name,
                    x_column    => r.column_name,
                    x_old       => r.old_value_d,
                    x_new       => r.new_value_d,
                    x_operation => r.jn_operation,
                    x_pk        => r.record_id);
        delete from global_dml_audit_fast f where f.rowid = r.rowid;
      elsif r.data_type = 'NUMBER' then
        check_val_n(x_table     => r.table_name,
                    x_column    => r.column_name,
                    x_old       => r.old_value_n,
                    x_new       => r.new_value_n,
                    x_operation => r.jn_operation,
                    x_pk        => r.record_id);
        delete from global_dml_audit_fast f where f.rowid = r.rowid;
      end if;
    
    end loop;
  end;
