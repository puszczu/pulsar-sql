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

  select null,
         a.psg_id,
         a.psztw_id,
         a.pswt_id,
         a.pswt_kod,
         a.psa_id,
         a.psa_kod,
         'N',
         a.psaw_opis,
         a.psaw_opis_dek,
         max(a.psaw_aktywny),
         max(a.psaw_opis_dek_skrot),
         max(a.psaw_opis_dek_nazwa_skrot)
  
    from (
          
          select aw1.psg_id,
                  (select c.psztw_id
                     from pls_sl_zwiazek_wtgw c
                    where c.pswt_id = p.pswt_id
                      and c.psgw_id = gw1.psgw_id) as psztw_id,
                  aw.pswt_id,
                  aw.pswt_kod,
                  ap.psa_id,
                  ap.psa_kod,
                  aw1.psaw_opis,
                  aw1.psaw_opis_dek,
                  aw1.psaw_aktywny,
                  aw1.psaw_opis_dek_skrot,
                  aw1.psaw_opis_dek_nazwa_skrot
            from pls_sl_asort_wyk aw1
           inner join pls_sl_zwiazek_wtgw gw1
              on gw1.psztw_id = aw1.psztw_id
           inner join pls_sl_rcp_naglowek w
              on w.pswt_id = aw1.pswt_id
           inner join pls_sl_rcp_pozycje p
              on w.psrcn_id = p.psrcn_id
           inner join pls_sl_rcp_typ t
              on w.psrct_id = t.psrct_id
             and t.psrct_kod = 'SCHP'
           inner join pls_sl_wartech aw
              on aw.pswt_id = p.pswt_id
           inner join pls_sl_asortyment ap
              on ap.psa_id = aw.psa_id
          
           where gw1.psgw_id is not null
             and not exists (select 1
                    from pls_sl_asort_wyk aw3
                   inner join pls_sl_zwiazek_wtgw gw3
                      on gw3.psztw_id = aw3.psztw_id
                   where aw3.pswt_id = p.pswt_id
                     and gw3.psgw_id = gw1.psgw_id)
          
          union
          
          select aw1.psg_id,
                  (select c.psztw_id
                     from pls_sl_zwiazek_wtgw c
                    where c.pswt_id = wp.pswt_id
                      and c.psgw_id is null) as psztw_id,
                  wp.pswt_id,
                  wp.pswt_kod,
                  ap.psa_id,
                  ap.psa_kod,
                  aw1.psaw_opis,
                  aw1.psaw_opis_dek,
                  aw1.psaw_aktywny,
                  aw1.psaw_opis_dek_skrot,
                  aw1.psaw_opis_dek_nazwa_skrot
            from pls_sl_asort_wyk aw1
           inner join pls_sl_zwiazek_wtgw gw1
              on gw1.psztw_id = aw1.psztw_id
           inner join pls_sl_rcp_naglowek w
              on w.pswt_id = aw1.pswt_id
           inner join pls_sl_rcp_pozycje p
              on w.psrcn_id = p.psrcn_id
           inner join pls_sl_rcp_typ t
              on w.psrct_id = t.psrct_id
             and t.psrct_kod = 'SCHP'
           inner join pls_sl_wartech wp
              on wp.pswt_id = p.pswt_id
           inner join pls_sl_asortyment ap
              on ap.psa_id = wp.psa_id
          
           where gw1.psgw_id is null
             and not exists (select 1
                    from pls_sl_asort_wyk aw3
                   inner join pls_sl_zwiazek_wtgw gw3
                      on gw3.psztw_id = aw3.psztw_id
                   where aw3.pswt_id = wp.pswt_id
                     and gw3.psgw_id is null)
          
          ) a
   group by a.psg_id,
            a.psztw_id,
            a.pswt_id,
            a.pswt_kod,
            a.psa_id,
            a.psa_kod,
            a.psaw_opis,
            a.psaw_opis_dek
