set head OFF
set feed OFF
set pagesize 0
set linesize 300
set SERVEROUTPUT ON
SPOOL exprows.scr
DECLARE
	maxLev number;
BEGIN
	commit;
	DBMS_OUTPUT.ENABLE(1000000);
	for c in (SELECT distinct table_name from redu_add ) 
	LOOP
		DBMS_OUTPUT.PUT_LINE('exp ${IBS_SOURCE} tables=''"IBS.'||c.table_name||'"'' QUERY=\"WHERE id IN \(SELECT id_obj from IBS.REDU_ADD where table_name = \'''||c.table_name||'\''\)\"'||' file="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.dmp" log="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.elog" GRANTS=N INDEXES=N TRIGGERS=N CONSTRAINTS=N STATISTICS=none');
	END LOOP;
END;
/
SPOOL OFF
EXIT
