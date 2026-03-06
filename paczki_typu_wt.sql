         select aw1.date_created,
                aw1.psa_kod,
                aw1.psaw_id as psaw_id_nag,
                p1.psaw_id
           from pls_sl_asort_wyk aw1
          inner join pls_sl_asortyment a1
             on a1.psa_id = aw1.psa_id
          inner join pls_sl_wartech w1
             on w1.pswt_id = aw1.pswt_id
            and w1.box_kod is null
          inner join pls_sl_grupa_asort ga
             on ga.psgra_id = a1.psgra_id
          inner join pls_sl_rcp_typ t
             on t.psrct_id = ga.box_psrct_id
            and t.psrct_kod = 'WT'
           left join pls_zam_bom_nag bn
             on bn.id_zew = aw1.psaw_id
            and bn.sys_zew = 'AW'
           left join pls_zam_bom p1
             on p1.pzbn_id = bn.pzbn_id
            and p1.pzb_level = 1
            and p1.pzb_id_fk is null
            and p1.psaw_id is not null
          where aw1.psaw_aktywny = '0001'
            and a1.psa_aktywny = '0001'
            and exists (select 1
                   from pls_sl_rcp_naglowek nn1
                  inner join pls_sl_rcp_pozycje pp1
                     on pp1.psrcn_id = nn1.psrcn_id
                  where nn1.pswt_id = aw1.pswt_id
                    and nn1.psrct_id = t.psrct_id)
