create or replace trigger psgw_key2_cpt
  for insert on pls_sl_zwiazek_wgw
  compound trigger

  --type psgw_id_array_type is table of number index by pls_integer;
  psgw_id_array dbms_debug.oer_table;

  after each row is
  begin
    psgw_id_array(:new.psgw_id) := 1;
  end after each row;

  after statement is
  begin
    -- loop through unique psgw_id values and perform the action
    for i in psgw_id_array.first .. psgw_id_array.last loop
    
      update pls_sl_grupa_wykonczen w
         set w.psgw_klucz2 =
             (select listagg(w1.pszw_kol || '=' || w1.psw_id, ';') within group(order by w1.pszw_kol, w1.psw_id) as cc
                from pls_sl_zwiazek_wgw w1
               where w1.psgw_id = w.psgw_id)
       where w.psgw_id = i
         and length(w.psgw_opis) - length(replace(w.psgw_opis, '[', '')) =
             (select count(1)
                from pls_sl_zwiazek_wgw j
               where j.psgw_id = w.psgw_id);
    
    end loop;
  end after statement;

end;
