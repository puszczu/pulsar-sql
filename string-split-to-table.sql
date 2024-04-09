with mails as
     (select trim(regexp_substr(vc_mail, '[^,;]+', 1, level)) as mail
        from dual
      connect by regexp_substr(vc_mail, '[^,;]+', 1, level) is not null)
