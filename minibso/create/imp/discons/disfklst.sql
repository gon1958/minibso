SET HEAD OFF
SET FEED OFF 
SET PAGESIZE 0
SET LINESIZE 250
SPOOL disfklst.scr
select 'ALTER TABLE '||table_name||' DISABLE CONSTRAINT '||constraint_name||';' from user_constraints uc 
where owner = 'IBS' AND CONSTRAINT_TYPE IN ('R') AND STATUS = 'ENABLED' 
and exists (select 1 from redu_add ra, user_constraints ucp where ra.table_name = ucp.table_name
and ucp.constraint_type = 'P' and ucp.constraint_name = uc.r_constraint_name);
SPOOL OFF
@disfklst.scr
EXIT