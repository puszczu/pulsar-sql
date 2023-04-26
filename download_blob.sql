create or replace function download_blob(p_url varchar2) return blob is

  l_http_request  utl_http.req;
  l_http_response utl_http.resp;
  l_blob          blob;
  l_raw           raw(32767);
  ret_blob        blob;
begin

  dbms_lob.createtemporary(l_blob, false);

  dbms_output.put_line(p_url);

  l_http_request  := utl_http.begin_request(p_url);
  l_http_response := utl_http.get_response(l_http_request);

  -- copy the response into the blob.
  begin
    loop
      utl_http.read_raw(l_http_response, l_raw, 32766);
      dbms_lob.writeappend(l_blob, utl_raw.length(l_raw), l_raw);
    end loop;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(l_http_response);
  end;

  ret_blob := l_blob;
  dbms_lob.freetemporary(l_blob);

  if l_http_response.private_hndl is not null then
    utl_http.end_response(l_http_response);
  end if;

  if l_http_request.private_hndl is not null then
    utl_http.end_request(l_http_request);
  end if;

  return ret_blob;

exception
  when others then
  
    if l_http_response.private_hndl is not null then
      utl_http.end_response(l_http_response);
    end if;
  
    if l_http_request.private_hndl is not null then
      utl_http.end_request(l_http_request);
    end if;
  
    raise;
end;
