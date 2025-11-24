create or replace package mail_sender_api is

  procedure send_mail(p_subject    in varchar2,
                      p_body_html  in varchar2,
                      p_to_address in varchar2,
                      p_to_name    in varchar2 default null,
                      --p_attachment_b64  in varchar2 default null,
                      p_attachment      in blob default null,
                      p_attachment_name in varchar2 default null);

  function blob_to_base64(p_blob blob) return clob;
end;
/
CREATE OR REPLACE PACKAGE BODY mail_sender_api IS

  FUNCTION get_clob_utf8_byte_length(p_clob IN CLOB) RETURN INTEGER IS
      v_offset      INTEGER := 1;
      v_chunk_size  INTEGER := 30000;
      v_chunk       VARCHAR2(30000);
      v_raw         RAW(32767);
      v_total_bytes INTEGER := 0;
  BEGIN
      WHILE v_offset <= DBMS_LOB.GETLENGTH(p_clob) LOOP
          v_chunk := DBMS_LOB.SUBSTR(p_clob, v_chunk_size, v_offset);
          v_raw := utl_raw.cast_to_raw(v_chunk); -- Or convert if needed
          v_total_bytes := v_total_bytes + utl_raw.length(v_raw);
          v_offset := v_offset + v_chunk_size;
      END LOOP;
      RETURN v_total_bytes;
  END;

  FUNCTION clob_to_utf8_raw(p_text IN CLOB) RETURN RAW IS
      v_raw RAW(32767);
  BEGIN
      -- DBMS_LOB.CONVERTTOBLOB only available in newer versions
      -- So use utl_raw.cast_to_raw on VARCHAR2 chunks (Oracle 11g limitation)
      v_raw := UTL_RAW.CAST_TO_RAW(TO_CHAR(p_text));
      RETURN v_raw;
  END;

PROCEDURE write_clob_utf8(http_req IN OUT UTL_HTTP.req, clob_data IN CLOB) IS
    v_offset     INTEGER := 1;
    v_chunk_size INTEGER := 16000; -- Safe for multi-byte expansion
    v_clob_len   INTEGER := DBMS_LOB.GETLENGTH(clob_data);
    v_chunk      VARCHAR2(16000);
    v_raw        RAW(32767);
BEGIN
    WHILE v_offset <= v_clob_len LOOP
        v_chunk := DBMS_LOB.SUBSTR(clob_data, v_chunk_size, v_offset);

        -- The chunk may be up to 3x larger in bytes due to UTF-8 expansion,
        -- so keep v_chunk_size conservative

        v_raw := UTL_RAW.CAST_TO_RAW(v_chunk);
        UTL_HTTP.write_raw(http_req, v_raw);

        v_offset := v_offset + v_chunk_size;
    END LOOP;
END;

  FUNCTION blob_to_base64(p_blob IN BLOB) RETURN CLOB IS
    v_result     CLOB := EMPTY_CLOB();
    v_offset     INTEGER := 1;
    v_chunk      RAW(32767);
    v_encoded    VARCHAR2(32767);
    v_length     INTEGER := DBMS_LOB.GETLENGTH(p_blob);
    v_chunk_size INTEGER := 32766; -- multiple of 3, max RAW size < 32767
  BEGIN
    IF p_blob IS NULL THEN
      RETURN NULL;
    END IF;
  
    WHILE v_offset <= v_length LOOP
      IF v_offset + v_chunk_size - 1 > v_length THEN
        v_chunk := DBMS_LOB.SUBSTR(p_blob,
                                   v_length - v_offset + 1,
                                   v_offset);
      ELSE
        v_chunk := DBMS_LOB.SUBSTR(p_blob, v_chunk_size, v_offset);
      END IF;
    
      v_encoded := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(v_chunk));
      v_result  := v_result || v_encoded;
      v_offset  := v_offset + v_chunk_size;
    END LOOP;
  
    -- Remove CR/LF if any (usually none from BASE64_ENCODE)
    v_result := REPLACE(REPLACE(v_result, CHR(13), ''), CHR(10), '');
  
    RETURN v_result;
  END;

  FUNCTION json_escape(p_text IN VARCHAR2) RETURN VARCHAR2 IS
    v_text VARCHAR2(32767) := p_text;
  BEGIN
    -- Order matters: escape backslash first!
    v_text := REPLACE(v_text, '\', '\\');
    v_text := REPLACE(v_text, '"', '\"');
    v_text := REPLACE(v_text, CHR(10), '\n');
    v_text := REPLACE(v_text, CHR(13), '\r');
    v_text := REPLACE(v_text, CHR(9), '\t');
    RETURN v_text;
  END;

  PROCEDURE write_clob_in_chunks(p_req IN OUT UTL_HTTP.req, p_clob IN CLOB) IS
    l_pos   NUMBER := 1;
    l_chunk VARCHAR2(32767);
  BEGIN
    WHILE l_pos <= DBMS_LOB.getlength(p_clob) LOOP
      l_chunk := DBMS_LOB.SUBSTR(p_clob, 32000, l_pos);
      UTL_HTTP.write_text(p_req, l_chunk);
      l_pos := l_pos + 32000;
    END LOOP;
  END;

  PROCEDURE send_mail_bk(p_subject         IN VARCHAR2,
                      p_body_html       IN VARCHAR2,
                      p_to_address      IN VARCHAR2,
                      p_to_name         IN VARCHAR2 DEFAULT NULL,
                      p_attachment      IN blob DEFAULT NULL,
                      p_attachment_name IN VARCHAR2 DEFAULT NULL) IS
  
    p_endpoint_url  varchar2(1000) := 'http://localhost:9050/SendMail2';
    l_http_request  UTL_HTTP.req;
    l_http_response UTL_HTTP.resp;
    l_response_text VARCHAR2(32767);
    l_payload       CLOB;
    
    l_subject_utf8 VARCHAR2(4000);
    l_body_html_utf8 VARCHAR2(4000);

  BEGIN
    --CONVERT(p_subject, 'AL32UTF8', 'WE8MSWIN1250')
    --CONVERT(p_body_html, 'AL32UTF8', 'WE8MSWIN1250')
    -- Build JSON payload
    l_subject_utf8 := convert(p_subject, 'AL32UTF8', 'EE8MSWIN1250');
    l_body_html_utf8 := convert(p_body_html, 'AL32UTF8', 'EE8MSWIN1250');
    
    l_payload := '{' || '  "Message": {' || '    "Subject": "' ||
                 REPLACE(l_subject_utf8, '"', '\"') || '",' || '    "Body": {' ||
                 '      "ContentType": "Html",' || '      "Content": "' ||
                 REPLACE(l_body_html_utf8, '"', '\"') || '"' || '    },' ||
                 '    "ToRecipients": [' || '      {' ||
                 '        "EmailAddress": {' || '          "Name": "' ||
                 REPLACE(NVL(p_to_name, p_to_address), '"', '\"') || '",' ||
                 '          "Address": "' || p_to_address || '"' ||
                 '        }' || '      }' || '    ],' ||
                 '    "CcRecipients": [],' || '    "BccRecipients": [],' ||
                 '    "ReplyTo": [],' ||
                 '    "IsDeliveryReceiptRequested": false,' ||
                 '    "IsReadReceiptRequested": false,' ||
                 '    "Attachments": [';
  
    -- Add optional attachment
    IF p_attachment IS NOT NULL AND p_attachment_name IS NOT NULL THEN
      --  l_payload := l_payload || '      {' || '        "Name": "' ||
      --               p_attachment_name || '",' || '        "ContentBytes": "' ||
      --               blob_to_base64(p_attachment) || '"' || '      }';
    
      DBMS_LOB.append(dest_lob => l_payload,
                      src_lob  => '      {' || '        "Name": "' ||
                                  p_attachment_name || '",' ||
                                  '        "ContentBytes": "');                                  
      DBMS_LOB.append(dest_lob => l_payload, src_lob => blob_to_base64(p_attachment));
      DBMS_LOB.append(dest_lob => l_payload, src_lob => '"' || '      }');
    
    END IF;
  
    --    l_payload := l_payload || '    ]' || '  },' ||
    --                 '  "SaveToSentItems": false' || '}';
    DBMS_LOB.append(dest_lob => l_payload,
                    src_lob  => '    ]' || '  },' ||
                                '  "SaveToSentItems": false' || '}');
                                
                                
  
    ---------------------------------------------------------------------
    --  SEND HTTP REQUEST
    ---------------------------------------------------------------------
  
    UTL_HTTP.set_transfer_timeout(600);
    UTL_HTTP.set_response_error_check(TRUE);
    UTL_HTTP.set_detailed_excp_support(TRUE);
  
    l_http_request := UTL_HTTP.begin_request(url          => p_endpoint_url,
                                             method       => 'POST',
                                             http_version => 'HTTP/1.1');
  
    UTL_HTTP.set_header(l_http_request, 'Content-Type', 'application/json');
    UTL_HTTP.set_header(l_http_request,
                        'Content-Length',
                        dbms_lob.getlength(l_payload));
    UTL_HTTP.set_header(l_http_request,
                        'User-Agent',
                        'Oracle-PLSQL-Client/1.0');
  
  dbms_output.put_line(to_char(l_payload));
  
    -- Write JSON payload
    --    UTL_HTTP.write_text(l_http_request, l_payload);
    write_clob_in_chunks(l_http_request, l_payload);
  
    -- Get response
    l_http_response := UTL_HTTP.get_response(l_http_request);
  
    BEGIN
      LOOP
        UTL_HTTP.read_text(l_http_response, l_response_text);
        DBMS_OUTPUT.put_line(l_response_text);
      END LOOP;
    EXCEPTION
      WHEN UTL_HTTP.end_of_body THEN
        NULL;
    END;
  
    UTL_HTTP.end_response(l_http_response);
  
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('Error calling SendMail2: ' || SQLERRM);
      BEGIN
        UTL_HTTP.end_response(l_http_response);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      RAISE;
  END;


  PROCEDURE send_mail(
    p_subject         IN VARCHAR2,
    p_body_html       IN VARCHAR2,
    p_to_address      IN VARCHAR2,
    p_to_name         IN VARCHAR2 DEFAULT NULL,
    p_attachment      IN BLOB DEFAULT NULL,
    p_attachment_name IN VARCHAR2 DEFAULT NULL)
  IS
    p_endpoint_url    VARCHAR2(1000) := 'http://localhost:9050/SendMail2';
    l_http_request    UTL_HTTP.req;
    l_http_response   UTL_HTTP.resp;
    l_response_text   VARCHAR2(32767);
    l_payload         CLOB;

    -- Use VARCHAR2 if you expect under 4000 bytes, otherwise CLOB
    l_subject_utf8      VARCHAR2(4000);
    l_body_html_utf8    VARCHAR2(4000);
    l_to_name_utf8      VARCHAR2(4000);
    l_content_length    number;
  BEGIN
    -- Convert input strings to UTF-8 from CP1250
    l_subject_utf8   := CONVERT(p_subject,   'AL32UTF8', 'EE8MSWIN1250');
    l_body_html_utf8 := CONVERT(p_body_html, 'AL32UTF8', 'EE8MSWIN1250');
    l_to_name_utf8   := CONVERT(NVL(p_to_name, p_to_address), 'AL32UTF8', 'EE8MSWIN1250');

    -- Start constructing the JSON payload
    l_payload :=
        '{' ||
        '  "Message": {' ||
        '    "Subject": "' || json_escape(l_subject_utf8) || '",' ||
        '    "Body": {' ||
        '      "ContentType": "Html",' ||
        '      "Content": "' || json_escape(l_body_html_utf8) || '"' ||
        '    },' ||
        '    "ToRecipients": [' ||
        '      {' ||
        '        "EmailAddress": {' ||
        '          "Name": "' || json_escape(l_to_name_utf8) || '",' ||
        '          "Address": "' || json_escape(p_to_address) || '"' ||
        '        }' ||
        '      }' ||
        '    ],' ||
        '    "CcRecipients": [],' ||
        '    "BccRecipients": [],' ||
        '    "ReplyTo": [],' ||
        '    "IsDeliveryReceiptRequested": false,' ||
        '    "IsReadReceiptRequested": false,' ||
        '    "Attachments": [';

    -- Handle optional attachment
    IF p_attachment IS NOT NULL AND p_attachment_name IS NOT NULL THEN
        DBMS_LOB.append(l_payload,
            '      {' ||
            '        "Name": "' || json_escape(p_attachment_name) || '",' ||
            '        "ContentBytes": "');
        DBMS_LOB.append(l_payload, blob_to_base64(p_attachment));
        DBMS_LOB.append(l_payload, '"' || '      }');
    END IF;

    DBMS_LOB.append(l_payload,
        '    ]' || '  },' ||
        '  "SaveToSentItems": false' || '}');

    -- Prepare and send HTTP request
    UTL_HTTP.set_transfer_timeout(600);
    UTL_HTTP.set_response_error_check(TRUE);
    UTL_HTTP.set_detailed_excp_support(TRUE);

    l_http_request := UTL_HTTP.begin_request(
        url          => p_endpoint_url,
        method       => 'POST',
        http_version => 'HTTP/1.1');

    l_content_length := get_clob_utf8_byte_length(l_payload);

    --UTL_HTTP.set_header(l_http_request, 'Content-Length', utl_raw.length(v_payload_raw));
    UTL_HTTP.set_header(l_http_request, 'Content-Type', 'application/json; charset=utf-8');
    UTL_HTTP.set_header(l_http_request, 'Content-Length', l_content_length);
    UTL_HTTP.set_header(l_http_request, 'User-Agent', 'Oracle-PLSQL-Client/1.0');

    --dbms_output.put_line(l_payload);

    -- Function that writes CLOB in chunks (needed for UTL_HTTP + Oracle 11g)
    --write_clob_in_chunks(l_http_request, l_payload);
    write_clob_utf8(l_http_request, l_payload);

    -- Get the response
    l_http_response := UTL_HTTP.get_response(l_http_request);

    BEGIN
        LOOP
            UTL_HTTP.read_text(l_http_response, l_response_text);
            DBMS_OUTPUT.put_line(l_response_text);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.end_of_body THEN NULL;
    END;

    UTL_HTTP.end_response(l_http_response);

  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error calling SendMail2: ' || SQLERRM);
        BEGIN
            UTL_HTTP.end_response(l_http_response);
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        RAISE;
  END;


END;
/
