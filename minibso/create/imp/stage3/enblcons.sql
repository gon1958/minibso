SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL enblcons.scr
select 'ALTER TABLE '||table_name||' ENABLE NOVALIDATE CONSTRAINT '||constraint_name||';' from user_constraints where owner = 'IBS' AND CONSTRAINT_TYPE in ('C', 'U', 'P') AND STATUS = 'DISABLED';
SPOOL OFF
SPOOL enblcons.err
@enblcons.scr
SPOOL OFF
EXIT
