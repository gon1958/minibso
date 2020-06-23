SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL enbltrig.scr
select 'ALTER TRIGGER '||trigger_name||' ENABLE;' from user_triggers;
SPOOL OFF
SPOOL enbltrig.err
@enbltrig.scr
SPOOL OFF
EXIT