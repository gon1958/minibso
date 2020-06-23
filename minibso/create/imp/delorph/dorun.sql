set head off
set feed off
SET PAGESIZE 0
set linesize 250
SET SERVEROUTPUT ON
rem WHENEVER SQLERROR EXIT 0
variable retval number
spool dorun.log  append
begin
	:retval := delorph();
end;
/	
exit :retval
