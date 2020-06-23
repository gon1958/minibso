set serveroutput on;
create or replace procedure addColl is
	vParentId number;
	vNRecord number;
	
	dynStmt varchar2(2000);
	type tDynStmtCur is ref cursor;
	dynStmtCur tDynStmtCur;
	reduAddRec redu_add%rowtype;
	
begin
	for iterLev in (select id_obj, table_name from redu_add where lev = 0
	) loop
		for collect in(select a.column_name, ta.table_name
			from classes c, class_tables ct, class_tab_columns a, classes ca, class_tables ta
			where ct.class_id = c.id and a.class_id = c.id and ca.id = a.self_class_id and ca.target_class_id = ta.class_id
				and ca.base_class_id = 'COLLECTION'
				and ct.table_name like iterLev.table_name
		)loop
			execute immediate 'select '||collect.column_name||' from '||iterLev.table_name||' where id = '||iterLev.id_obj into vParentId;
			if vParentId is null then 
				continue;
			end if;
			begin 
				dynStmt := 'select id, 1, '''||collect.table_name||''', ''C'' from '||collect.table_name||' where '||
					'collection_id = '||vParentId||
					' and (id, '''||collect.table_name||''') not in (select id_obj, table_name from redu_add)' ;
				open dynStmtCur for dynStmt;
				loop
					fetch dynStmtCur into reduAddRec;
					exit when dynStmtCur%notfound;
					insertReduAdd(reduAddRec.id_obj, reduAddRec.lev, reduAddRec.key_type);
				end loop;
				close dynStmtCur;
			end;
		end loop;
	end loop;
	commit;
end;
/
show error
exec addColl;
/* drop procedure addColl; */
exit



