begin

  for r in (    
    select count(1),
       psgw_klucz,
       min(x.psgw_id) as min_psgw_id,
       max(x.psgw_id) as max_psgw_id
  from pls_sl_grupa_wykonczen x
 group by psgw_klucz
having count(1) > 1

) loop

   update pls_sl_asort_wyk a set a.psztw_id = (select x.psztw_id from pls_sl_zwiazek_wtgw x where x.pswt_id = a.pswt_id and x.psgw_id = r.min_psgw_id) where a.psztw_id 
   
   in (select y.psztw_id from pls_sl_zwiazek_wtgw y where y.pswt_id = a.pswt_id and y.psgw_id = r.max_psgw_id);

   delete from pls_sl_zwiazek_wtgw d where d.psgw_id = r.max_psgw_id;   
   delete from pls_sL_grupa_wykonczen ww where ww.psgw_id = r.max_psgw_id;
end loop;

end;
