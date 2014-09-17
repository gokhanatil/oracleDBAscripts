SET HEA OFF
SET FEED OFF
SET LINES 500
SET PAGES 500
SET TRIM ON

SELECT handle
from V$BACKUP_PIECE
where rman_Status_stamp IN (
select  stamp from V$RMAN_STATUS where parent_stamp =
 (SELECT session_stamp
from V$RMAN_BACKUP_JOB_DETAILS
where start_time =
(select max(start_time) from 
V$RMAN_BACKUP_JOB_DETAILS where input_type = 'DB FULL')));
