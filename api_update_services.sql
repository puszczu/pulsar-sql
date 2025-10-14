DECLARE
    l_http_request   UTL_HTTP.req;
    l_http_response  UTL_HTTP.resp;
    l_url            VARCHAR2(2000) := 'http://localhost:5555/UpdateServices';
    l_response_text  VARCHAR2(32767);
BEGIN
    -- Allow redirect and set timeout
    UTL_HTTP.set_transfer_timeout(60);
    UTL_HTTP.set_response_error_check(TRUE);
    UTL_HTTP.set_detailed_excp_support(TRUE);

    -- Initialize request (use 'GET' or 'POST' depending on your endpoint)
    l_http_request := UTL_HTTP.begin_request(l_url, 'GET', 'HTTP/1.1');

    -- (Optional) set headers if needed
    UTL_HTTP.set_header(l_http_request, 'User-Agent', 'PLSQL-Client/1.0');
    UTL_HTTP.set_header(l_http_request, 'Content-Type', 'application/json');

    -- (Optional) write body if POST
    -- UTL_HTTP.write_text(l_http_request, '{"param":"value"}');

    -- Get the response
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

    -- Close response
    UTL_HTTP.end_response(l_http_response);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('HTTP call failed: ' || SQLERRM);
        -- Cleanup if needed
        BEGIN
            UTL_HTTP.end_response(l_http_response);
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
END;
