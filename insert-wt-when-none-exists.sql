insert into pls_sl_wartech
  (psa_id,
   pswt_kod,
   pswt_nazwa,
   pswt_aktywny,
   pswt_typ,
   firma_id,
   firma_id_wytworczy)
  select a.psa_id,
         a.psa_kod,
         a.psa_nazwa1,
         '0001',
         '0001',
         a.firma_id,
         a.firma_id
    from pls_sl_asortyment a
   where not exists
   (select 1 from pls_sl_wartech w1 where w1.psa_id = a.psa_id)
