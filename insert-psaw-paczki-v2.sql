insert into pls_sl_zwiazek_wtgw
  (psztw_id, pswt_id, psgw_id, psztw_aktywny)

  select psztw_seq.nextval, a.pswt_id, a.psgw_id, '0001'
    from (
          
          select p.pswt_id, gw1.psgw_id
            from pls_sl_zwiazek_wtgw gw1
           inner join pls_sl_rcp_naglowek w
              on w.pswt_id = gw1.pswt_id
           inner join pls_sl_rcp_pozycje p
              on w.psrcn_id = p.psrcn_id
           inner join pls_sl_rcp_typ t
              on w.psrct_id = t.psrct_id
             and t.psrct_kod = 'SCHP'
           where gw1.psgw_id is not null
             and not exists (select 1
                    from pls_sl_zwiazek_wtgw x
                   where x.pswt_id = p.pswt_id
                     and gw1.psgw_id = x.psgw_id)
          
          union
          
          select p.pswt_id, gw1.psgw_id
            from pls_sl_zwiazek_wtgw gw1
           inner join pls_sl_rcp_naglowek w
              on w.pswt_id = gw1.pswt_id
           inner join pls_sl_rcp_pozycje p
              on w.psrcn_id = p.psrcn_id
           inner join pls_sl_rcp_typ t
              on w.psrct_id = t.psrct_id
             and t.psrct_kod = 'SCHP'
           where gw1.psgw_id is null
             and not exists (select 1
                    from pls_sl_zwiazek_wtgw x
                   where x.pswt_id = p.pswt_id
                     and x.psgw_id is null)
          
          ) a
