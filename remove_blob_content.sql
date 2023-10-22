 
 begin
   for r in (select *
               from (select z.id,
                            z.hash_value,
                            dbms_lob.getlength(z.file_content) as size1
                       from GM_BUFOR_POCZTY_ZAL z
                      where z.hash_value is not null
                        and z.file_content is not null
                        and (z.date_created is null or z.date_created < sysdate-30)
                      order by z.id)
              where rownum < 100000) loop
     null;
     if (pulsar.api_updater.get_blob_size(x_hash_value => r.hash_value) = r.size1) then
       update GM_BUFOR_POCZTY_ZAL w
          set w.file_content = null
        where w.id = r.id;
        commit;
     end if;
   end loop;
 end;


select count(1) from (select z.id,
                            z.hash_value,
                            dbms_lob.getlength(z.file_content) as size1
                       from GM_BUFOR_POCZTY_ZAL z
                      where z.hash_value is not null
                        and z.file_content is not null
                        and (z.date_created is null or z.date_created < sysdate-200)
                      order by z.id)


select count(1) from gm_bufor_Poczty_zal zz where zz.hash_value is not null and zz.file_content is null




select *
               from (select z.id,
                            z.hash_value,
                            dbms_lob.getlength(z.file_content) as size1
                       from GM_BUFOR_POCZTY_ZAL z
                      where z.hash_value is not null
                        and z.file_content is not null
                        and (z.date_created is null or z.date_created < sysdate-200)
                      order by z.id)
              where rownum < 10000
              
             
              
              
ALTER TABLE lmt.gm_bufor_poczty_zal ENABLE ROW MOVEMENT;
ALTER TABLE lmt.gm_bufor_poczty_zal SHRINK SPACE;

select to_char(z.date_created, 'YY-MM'), round(sum(dbms_lob.getlength(z.file_content)) / 1024 / 1024 / 1024, 2) as size_in_gb
  from gm_bufor_Poczty_zal z
  where z.file_content is not null
  group by to_char(z.date_created, 'YY-MM')
  order by to_char(z.date_created, 'YY-MM') desc
