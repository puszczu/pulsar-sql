begin
  for r in (select *
              from pls_sl_asortyment a1
             inner join pls_sl_wartech w1
                on w1.psa_id = a1.psa_id
             where not exists (select 1
                      from pls_sl_rcp_naglowek n1
                     inner join pls_sl_rcp_pozycje p1
                        on p1.psrcn_id = n1.psrcn_id
                     where n1.pswt_id = w1.pswt_id)
               and not exists (select 1
                      from pls_sl_asort_wyk aw
                     where aw.pswt_id = w1.pswt_id)) loop
  
    begin
    
      insert into pls_sl_zwiazek_wtgw
        (psztw_id, pswt_id, psgw_id, psztw_aktywny)
        select psztw_seq.nextval, w1.pswt_id, null, '0001'
          from pls_sl_wartech w1
         where w1.pswt_id = r.pswt_Id
           and not exists (select 1
                  from pls_sl_zwiazek_wtgw x
                 where x.pswt_id = w1.pswt_id
                   and x.psgw_id is null);
    
      insert into pls_sl_asort_wyk
        (psaw_id,
         psg_id,
         psztw_id,
         pswt_id,
         pswt_kod,
         psa_id,
         psa_kod,
         psaw_pdst,
         psaw_opis,
         psaw_opis_dek,
         psaw_aktywny)
        select psaw_seq.nextval,
               9,
               (select c.psztw_id
                  from pls_sl_zwiazek_wtgw c
                 where c.pswt_id = w1.pswt_id
                   and c.psgw_id is null),
               w1.pswt_id,
               w1.pswt_kod,
               a1.psa_id,
               a1.psa_kod,
               'T',
               null,
               null,
               '0001'
          from pls_sl_wartech w1
         inner join pls_sl_asortyment a1
            on a1.psa_id = w1.psa_id
         where w1.pswt_id = r.pswt_id
           and not exists (select 1
                  from pls_sl_asort_wyk aw1
                 inner join pls_sl_zwiazek_wtgw z1
                    on z1.psztw_id = aw1.psztw_id
                   and z1.psgw_id is null
                   and z1.pswt_id = w1.pswt_id);
    
    end;
  end loop;
end;
