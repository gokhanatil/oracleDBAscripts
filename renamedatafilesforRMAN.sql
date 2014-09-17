DECLARE
    CURSOR DF_CURSOR IS 
        SELECT 'data' ft, FILE_ID, FILE_NAME, 
        BYTES / (1024 * 1024 * 1024) fsize
        FROM dba_data_files
        union all 
        SELECT 'temp' ft, FILE_ID, FILE_NAME, 
        BYTES / (1024 * 1024 * 1024) fsize
        FROM dba_temp_files
        ORDER BY ft, file_id;

   TYPE array_number IS TABLE OF NUMBER;
   TYPE array_varchar2 IS TABLE OF VARCHAR2 (200);

   diskno      NUMBER;

   diskspace   array_number := array_number (
                                   30,
                                   20,
                                   20,
                                   120); -- Sizes in GB

   diskpath   array_varchar2 := array_varchar2 (
                                   '/u01/data',
                                   '/u02/data',
                                   '/u03/data',
                                   '/u04/data');

   prefix      VARCHAR2 (200) := '/SID'; -- will be added to diskpaths
   
BEGIN
   FOR df IN DF_CURSOR
   LOOP
      FOR diskno IN 1 .. diskspace.COUNT
      LOOP
         IF (diskspace (diskno) > df.fsize)
         THEN
            DBMS_OUTPUT.put_line ( 'set newname for ' || df.ft || 'file '
               || df.FILE_ID || ' to  ''' || diskpath (diskno) || prefix
               || SUBSTR (df.FILE_NAME, INSTR (df.FILE_NAME, '/', -1)) 
               || ''';');
            diskspace (diskno) := diskspace (diskno) - df.fsize;
            EXIT;
            ELSE
            IF diskno = diskspace.COUNT then
               DBMS_OUTPUT.put_line ('# no space for '||df.FILE_ID||' '
               ||SUBSTR (df.FILE_NAME, INSTR (df.FILE_NAME, '/', -1)));
            END IF;
         END IF;
      END LOOP;
   END LOOP;
END;
/
