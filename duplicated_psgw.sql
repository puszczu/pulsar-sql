with data1 as
 (select w1.psgw_id,
         listagg(w1.pszw_kol || '=' || w1.psw_id, ';') within group(order by to_number(substr(w1.pszw_kol, instr(w1.pszw_kol, '_') + 1)), w1.psw_id) as cc
    from pls_sl_zwiazek_wgw w1
   group by w1.psgw_id)
select cc, count(*) from data1 d group by d.cc having count (*) > 1
