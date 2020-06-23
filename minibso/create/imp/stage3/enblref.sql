SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL enblref.scr
select 'ALTER TABLE '||table_name||' ENABLE CONSTRAINT '||constraint_name||';' from user_constraints where owner = 'IBS' AND CONSTRAINT_TYPE = 'R' AND STATUS = 'DISABLED';
SPOOL OFF
SPOOL enblref.err
@enblref.scr
SPOOL OFF
EXIT


