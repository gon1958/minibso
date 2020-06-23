SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL rmjob.scr
select 'begin dbms_job.remove('||job||'); commit; end;'||chr(13)||chr(10)||'/'||chr(13)||chr(10)  from user_jobs;
SPOOL OFF
@rmjob.scr
EXIT