DECLARE
   bid            NUMBER;
   eid            NUMBER;
   db_unique_name VARCHAR2(30);    
   host_name      VARCHAR2(64);
   starttime      CHAR (5);
   endtime        CHAR (5);
   v_from         VARCHAR2 (80);
   v_recipient    VARCHAR2 (80) := 'gokhan@myemailaddress.com';
   v_mail_host    VARCHAR2 (30) := 'oursmtpserver';
   v_mail_conn    UTL_SMTP.connection;
BEGIN
   starttime := '06:00';
   endtime := '10:00';

   SELECT MIN (snap_id), MAX (snap_id)
     INTO bid, eid
     FROM dba_hist_snapshot
    WHERE TO_CHAR (begin_interval_time, 'hh24:mi') >= starttime
      AND TO_CHAR (end_interval_time, 'hh24:mi') <= endtime
      AND TRUNC (begin_interval_time) = TRUNC (SYSDATE)
      AND TRUNC (end_interval_time) = TRUNC (SYSDATE);

  SELECT host_name
    INTO host_name
    FROM v$instance;

  SELECT db_unique_name
    INTO db_unique_name
    FROM v$database;

   v_from := db_unique_name ||  '@' || host_name;

   v_mail_conn := UTL_SMTP.OPEN_CONNECTION (v_mail_host, 25);
   UTL_SMTP.HELO (v_mail_conn, v_mail_host);
   UTL_SMTP.MAIL (v_mail_conn, v_from);
   UTL_SMTP.RCPT (v_mail_conn, v_recipient);
   UTL_SMTP.OPEN_DATA( v_mail_conn );
   UTL_SMTP.WRITE_DATA ( v_mail_conn, 'From:' || v_from || UTL_TCP.CRLF );
   UTL_SMTP.WRITE_DATA ( v_mail_conn, 'To:' || v_recipient || UTL_TCP.CRLF );
   UTL_SMTP.WRITE_DATA ( v_mail_conn, 'Subject: ' 
        || 'AWR Report of ' || v_from || ' ' 
        || SYSDATE || ' ' || starttime || '-' || endtime || UTL_TCP.CRLF  );
   UTL_SMTP.WRITE_DATA ( v_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.CRLF  );     
   UTL_SMTP.WRITE_DATA ( v_mail_conn, 
        'Content-Type: multipart/mixed; boundary=NEXTSLIDEPLEASE'
        || UTL_TCP.CRLF || UTL_TCP.CRLF );     

   UTL_SMTP.WRITE_DATA ( v_mail_conn, 
        '--NEXTSLIDEPLEASE' || UTL_TCP.CRLF
        || 'Content-Type: text/plain;'
        || UTL_TCP.CRLF || UTL_TCP.CRLF );
   UTL_SMTP.WRITE_DATA ( v_mail_conn, 
        'AWR Reports are attached.'
        || UTL_TCP.CRLF || UTL_TCP.CRLF );     
        
   FOR rac IN (SELECT dbid, inst_id FROM gv$database)
   LOOP

       UTL_SMTP.WRITE_DATA ( v_mail_conn, 
        '--NEXTSLIDEPLEASE' || UTL_TCP.CRLF
        || 'Content-Disposition: attachment; ' 
        || 'filename="awr_' || db_unique_name || rac.inst_id || '.html"'
        || UTL_TCP.CRLF
        || 'Content-Type: text/html; charset=utf8; ' 
        || UTL_TCP.CRLF || UTL_TCP.CRLF );    


       FOR c1_rec IN
          (SELECT output
             FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(rac.dbid,
               rac.inst_id, bid, eid, 8 )))
       LOOP
          UTL_SMTP.WRITE_DATA (v_mail_conn, c1_rec.output || UTL_TCP.CRLF );
       END LOOP;
       
       
   END LOOP;
   
   UTL_SMTP.CLOSE_DATA (v_mail_conn);  
   UTL_SMTP.QUIT (v_mail_conn);
   
   
EXCEPTION
   WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR
   THEN
      RAISE_APPLICATION_ERROR (-20000, 'Unable to send mail: ' || SQLERRM);
END;
/
