delete from pls_produkty_paczki x
 where exists (select 1
          from pls_sl_asort_wyk aw1
         inner join pls_sl_wartech w1
            on w1.pswt_id = aw1.pswt_id
         inner join pls_sl_rcp_naglowek n1
            on n1.pswt_id = w1.pswt_id
         inner join pls_sl_rcp_typ t1
            on n1.psrct_id = t1.psrct_id
           and t1.psrct_kod = 'SCHP'
         where aw1.psaw_id = x.prod_psaw_id)
   and not exists
 (select 1
          from pls_sl_asort_wyk aw1
         inner join pls_sl_zwiazek_wtgw gw1
            on gw1.psztw_id = aw1.psztw_id
         inner join pls_sl_wartech w1
            on w1.pswt_id = aw1.pswt_id
        
         inner join pls_sl_asort_wyk aw2
            on aw2.psaw_id = x.pacz_psaw_id
        
         inner join pls_sl_zwiazek_wtgw gw2
            on gw2.psztw_id = aw2.psztw_id
        
         inner join pls_sl_rcp_naglowek n1
            on n1.pswt_id = w1.pswt_id
         inner join pls_sl_rcp_typ t1
            on n1.psrct_id = t1.psrct_id
           and t1.psrct_kod = 'SCHP'
         inner join pls_sl_rcp_pozycje p1
            on n1.psrcn_id = p1.psrcn_id
         where aw1.psaw_id = x.prod_psaw_id
           and p1.pswt_id = aw2.pswt_id
           and (gw1.psgw_id = gw2.psgw_id or
               (gw1.psgw_id is null and gw2.psgw_id is null)));

 insert into pls_produkty_paczki
     (id, prod_psaw_id, pacz_psaw_id)
     select pls_produkty_paczki_seq.nextval, saw.psaw_id, pacz.psaw_id
       from pls_sl_asort_wyk saw
      inner join pls_sl_zwiazek_wtgw s
         on saw.psztw_id = s.psztw_id
      inner join pls_sl_rcp_naglowek w
         on w.pswt_id = s.pswt_id
      inner join pls_sl_rcp_pozycje p
         on w.psrcn_id = p.psrcn_id
      inner join pls_sl_rcp_typ t
         on w.psrct_id = t.psrct_id
        and t.psrct_kod = 'SCHP'
      inner join pls_sl_asort_wyk pacz
         on pacz.pswt_id = p.pswt_id
      inner join pls_sl_zwiazek_wtgw paczw
         on paczw.psztw_id = pacz.psztw_id
        and (paczw.psgw_id = s.psgw_id or
            (paczw.psgw_id is null and s.psgw_id is null))
      cross join dual
      where not exists (select 1
               from pls_produkty_paczki x
              where x.prod_psaw_id = saw.psaw_id
                and x.pacz_psaw_id = pacz.psaw_id);
