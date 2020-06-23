set serveroutput on
set linesize 300
set feed off
set pagesize 0
spool expstat.scr
declare 
	tables varchar2(2000);
	tabcnt number;
begin
	for s in (select table_name from ibs.class_tables where class_id in 
		(select id from ibs.classes start with id in (SELECT class_id from ibs.obj_static) 
		connect by prior parent_id = id )) loop
		dbms_output.put_line('exp $IBS_SOURCE tables=\(\"ibs\.'||symsubst(s.table_name)||'\"\) QUERY=\"WHERE id IN \(SELECT id FROM IBS\.OBJ\_STATIC\)\" file="${DATA_PATH}'||TRANSLATE(s.table_name,'$#','__')||'.sta" log="${DATA_PATH}'||TRANSLATE(s.table_name,'$#','__')||'.eout" grants=n indexes=n triggers=n constraints=n STATISTICS=none');
	end loop;
end;
/
spool off
exit
