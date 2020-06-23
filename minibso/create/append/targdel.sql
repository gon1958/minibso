set serveroutput on
begin
	for c in (select id_obj, table_name from redu_add) 
	loop
		begin 
			execute immediate 'delete '||c.table_name||' where id = '||c.id_obj;
		exception 
		when others then 
			dbms_output.put_line('Error delete table_name='||c.table_name||' id_obj='||c.id_obj||' SQLCODE='||SQLCODE||' SQLERRM='||SQLERRM);
		end;
	end loop;
	commit;
end;
/
exit
