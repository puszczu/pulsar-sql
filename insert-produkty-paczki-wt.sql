    insert into pls_produkty_paczki
      (prod_psaw_id, pacz_psaw_id)
      select aw.psaw_id, b1.psaw_id
        from pls_sl_asort_wyk aw
       inner join pls_sl_asortyment a1
          on a1.psa_id = aw.psa_id
       inner join pls_sl_grupa_asort g1
          on g1.psgra_id = a1.psgra_id
       inner join pls_sl_rcp_typ t1
          on t1.psrct_id = g1.box_psrct_id
         and t1.psrct_kod = 'WT'
       inner join pls_zam_bom_nag n1
          on n1.sys_zew = 'AW'
         and n1.id_zew = aw.psaw_id
       inner join pls_zam_bom b1
          on b1.pzbn_id = n1.pzbn_id
         and b1.pzb_id_fk is null
       where b1.psaw_id is not null
         and not exists (select 1
                from pls_produkty_paczki x
               where x.prod_psaw_id = aw.psaw_id
                 and x.pacz_psaw_id = b1.psaw_id)
