SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL distrig.scr
select 'ALTER TRIGGER '||trigger_name||' DISABLE;' from user_triggers;
SPOOL OFF
@distrig.scr
EXIT