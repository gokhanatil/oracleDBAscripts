CREATE OR REPLACE FUNCTION readfromweb (url VARCHAR2)
   RETURN CLOB
IS
   pcs    UTL_HTTP.html_pieces;
   retv   CLOB;
BEGIN
   pcs := UTL_HTTP.request_pieces (url, 50);
   FOR i IN 1 .. pcs.COUNT
   LOOP
      retv := retv || pcs (i);
   END LOOP;
   RETURN retv;
END;

-- SELECT readfromweb ('http://..../awebpage.aspx') FROM DUAL;
