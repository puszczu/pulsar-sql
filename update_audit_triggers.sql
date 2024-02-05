    declare
      cc clob;
    begin
      for r in (select table_owner, table_name, trigger_name, owner
                  from all_triggers
                 where trigger_name like 'T_CT_%') loop
        cc := appl_admin.audit_pkg.GEN_AUDIT_TRIGGER_TEXT_new(X_TABLE_NAME => r.table_name,
                                                              X_OWNER      => r.table_owner);
        execute immediate 'grant select, insert, update, delete on appl_admin.global_dml_audit_fast to ' ||
                          r.table_owner;
        execute immediate cc;
        execute immediate 'alter trigger ' || r.owner || '.' ||
                          r.trigger_name || ' disable';
      end loop;
    end;
