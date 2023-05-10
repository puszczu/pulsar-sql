declare

  cursor c is
    select x.pszatr_id,
           (select w.pszatr_id
              from pls_sl_zwiazek_atr w
             where w.psgra_id = aaa.psgra_ID
               and w.psata_id = x.psata_id) ok_id,
           x.psata_Id,
           aaa.psgra_id,
           x.pswatr_id
      from pls_sl_wartosc_atr x
     inner join pls_sl_zwiazek_atr a2
        on a2.pszatr_id = x.pszatr_id
     inner join pls_sl_asortyment aaa
        on aaa.psa_id = x.psa_id
     where aaa.psgra_id != a2.psgra_id;

  i number := 0;
begin

  for r in c loop
  
    if r.ok_id is null then
      insert into pls_sl_zwiazek_atr
        (psata_id, psgra_id)
        select r.psata_id, r.psgra_id
          from dual
         where not exists (select 1
                  from pls_sl_zwiazek_atr t
                 where t.psgra_id = r.psgra_id
                   and t.psata_id = r.psata_id);
    end if;
  
  end loop;

  for r in c loop
    update pls_sl_wartosc_atr wa
       set wa.pszatr_id = r.ok_id
     where wa.pswatr_id = r.pswatr_id;
  
    i := i + 1;
  end loop;

  dbms_output.put_line('updated pls_sl_wartosc_atr records: ' || i);

end;
