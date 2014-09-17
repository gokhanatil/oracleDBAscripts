select tfile.tablespace_name,
round(tfile.fsize/1024/1024/1024) "Actual GB",
round(tfile.msize/1024/1024/1024) "Max GB",
round(tseg.used/1024/1024/1024) "Used GB",
'% ' || round(tseg.used/tfile.fsize,2)*100 pct_used,
'% ' || round(tseg.used/tfile.msize,2)*100 pct_max
from 
(select tablespacE_name, 
sum(bytes) fsize, 
sum(greatest( bytes, maxbytes)) msize
FROM dba_data_files group by tablespace_name) tfile,
(select tablespacE_name, sum(bytes) used from dba_segments group by tablespace_name) tseg
where tfile.tablespace_name = tseg.tablespace_name
order by tseg.used/tfile.msize desc;
