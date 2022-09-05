                     update gm_zamowienia_pozycje zp
                        set zp.psaw_Id = zp.psaw_id
                      where zp.id in
                            (                             
                             select zzz.id
                               from gm_zamowienia_pozycje zzz
                              inner join gm_zamowienia z
                                 on z.nr_zamowienia = zzz.nr_zamowienia
                              where zzz.zamkniete = 'N'
                                and exists
                              (select 1
                                       from pls_sl_asort_wyk aw
                                      inner join pls_sl_zwiazek_wtgw ww
                                         on ww.psztw_id = aw.psztw_id
                                      where aw.psaw_id = zzz.psaw_id
                                        and ww.psgw_id is not null)
                                and z.typ in ('ZZ', 'DM', 'DP')
                                and ltrim(cc_1 || cc_2 || cc_3 || cc_4 || cc_5 || cc_6 || cc_7 || cc_8 || cc_9 ||
                                          cc_10 || cc_11 || cc_12 || cc_13 ||
                                          cc_14 || cc_15 || cc_16 || cc_17 ||
                                          cc_18 || cc_19 || cc_20,
                                          'X') is null
                             )
