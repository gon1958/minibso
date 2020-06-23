SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL dispk.scr
select 'ALTER TABLE '||table_name||' DISABLE CONSTRAINT '||constraint_name||';' from user_constraints where owner = 'IBS' AND CONSTRAINT_TYPE IN ('U', 'P') AND STATUS = 'ENABLED';
SPOOL OFF
@dispk.scr
EXIT