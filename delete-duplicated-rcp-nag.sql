begin

  for r in (select *
              from (select n.pswt_id,
                           min(psrcn_id) as min_id,
                           max(psrcn_id) as max_id
                      from pls_sl_rcp_naglowek n
                     where n.pswt_id is not null
                     group by n.psrct_id, n.pswt_id)
             where min_id != max_id) loop
    update pls_sl_rcp_pozycje pp
       set pp.psrcn_id = r.min_id
     where r.psrcn_id = r.max_id;
  end loop;

  delete from pls_sl_rcp_naglowek n
   where n.pswt_id is not null
     and not exists
   (select 1 from pls_sl_rcp_pozycje p where p.psrcn_id = n.psrcn_id);

end;
