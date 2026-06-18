declare
  type t_rowid_tab is table of rowid index by pls_integer;
  l_rowids t_rowid_tab;

  c_batch_size constant pls_integer := 10000;
  l_total_deleted pls_integer := 0;

  cursor c_to_delete is
    select a.rowid as row_id
      from appl_admin.global_dml_audit3 a
     inner join appl_admin.global_dml_audit_co c
        on c.id = a.co_id
     where c.table_name = 'GM_ZAMOWIENIA';

begin
  open c_to_delete;
  loop

    fetch c_to_delete bulk collect into l_rowids limit c_batch_size;

    exit when l_rowids.count = 0;

    forall i in 1 .. l_rowids.count
      delete from appl_admin.global_dml_audit3
       where rowid = l_rowids(i);

    commit;

    l_total_deleted := l_total_deleted + l_rowids.count;
    dbms_output.put_line('Usunieto: ' || l_total_deleted);

  end loop;
  close c_to_delete;

  dbms_output.put_line('Zakonczono. Usunieto razem: ' || l_total_deleted);

exception
  when others then
    if c_to_delete%isopen then
      close c_to_delete;
    end if;
    rollback;
    raise;

end;
