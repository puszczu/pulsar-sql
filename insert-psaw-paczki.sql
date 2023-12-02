begin
  for r in (
            
            select distinct *
              from (with box_schema as (select w.pswt_id as prod_pswt_id,
                                                p.pswt_id as pacz_pswt_id,
                                                w.box_kod
                                           from pls_sl_rcp_naglowek w
                                          inner join pls_sl_rcp_pozycje p
                                             on w.psrcn_id = p.psrcn_id
                                         
                                          inner join pls_sl_rcp_typ t
                                             on w.psrct_id = t.psrct_id
                                          inner join pls_sl_wartech w
                                             on w.pswt_id = p.pswt_id
                                          where t.psrct_kod = 'SCHP')
                    
                      select aw.psaw_id      as prod_psaw_id,
                             aw_pacz.psaw_id as pacz_psaw_id,
                             c.box_kod,
                             c.pacz_pswt_id,
                             aw.psztw_id,
                             gg.psgw_id,
                             aw.psaw_opis
                        from pls_sl_asort_wyk aw
                       inner join pls_sl_zwiazek_wtgw gg
                          on gg.psztw_id = aw.psztw_id
                        left join box_schema c
                          on c.prod_pswt_id = aw.pswt_id
                        left join pls_sl_asort_wyk aw_pacz
                          on aw_pacz.pswt_id = c.pacz_pswt_id
                        left join pls_sl_zwiazek_wtgw gg_pacz
                          on gg_pacz.psztw_id = aw_pacz.psztw_id
                         and nvl(gg.psgw_id, -1) = nvl(gg_pacz.psgw_id, -1)
                       where aw.pswt_id in
                             (select b.prod_pswt_id from box_schema b)
                      
                       )
                       where pacz_psaw_id is null
                       order by prod_psaw_id, pacz_pswt_id
            ) loop
  
    insert into pls_sl_zwiazek_wtgw
      (psztw_id, pswt_id, psgw_id, psztw_aktywny)
      select psztw_seq.nextval, r.pacz_pswt_id, r.psgw_id, '0001'
        from dual s
       where not exists (select 1
                from pls_sl_zwiazek_wtgw x1
               where x1.pswt_id = r.pacz_pswt_id
                 and x1.psgw_id = r.psgw_id);
  
    begin
    
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
         
         psaw_aktywny,
         psaw_opis_dek_skrot,
         psaw_opis_dek_nazwa_skrot)
        select psaw_seq.nextval,
               s.psg_id,
               (select c.psztw_id
                  from pls_sl_zwiazek_wtgw c
                 where c.pswt_id = wpacz.pswt_id
                   and nvl(c.psgw_id, -1) = nvl(r.psgw_id, -1)),
               wpacz.pswt_id,
               wpacz.pswt_kod,
               wpacz.psa_id,
               apacz.psa_kod,
               'N',
               s.psaw_opis,
               s.psaw_opis_dek,
               '0001',
               s.psaw_opis_dek_skrot,
               s.psaw_opis_dek_nazwa_skrot
          from pls_sl_asort_wyk s
         inner join pls_sl_wartech wpacz
            on wpacz.pswt_id = r.pacz_pswt_id
         inner join pls_sl_asortyment apacz
            on apacz.psa_id = wpacz.psa_id
         where s.psaw_id = r.prod_psaw_id
           and not exists
         (select 1
                  from pls_sl_asort_wyk wc
                 inner join pls_sl_zwiazek_wtgw wc2
                    on wc2.psztw_id = wc.psztw_id
                 where wc.pswt_id = wpacz.pswt_id
                   and nvl(wc2.psgw_Id, -1) = nvl(r.psgw_id, -1));
    
    exception
      when others then
        dbms_output.put_line('psaw_id=' || r.prod_psaw_id || ',' ||
                             'pacz pswt_Id = ' || r.pacz_pswt_id);
        raise;
    end;
  
  end loop;

end;
