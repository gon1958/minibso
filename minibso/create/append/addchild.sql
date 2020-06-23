set serveroutput on;
create or replace procedure addChild is
	vParentId number;
	vNRecord number;
	
	dynStmt varchar2(2000);
	type tDynStmtCur is ref cursor;
	dynStmtCur tDynStmtCur;
	reduAddRec redu_add%rowtype;
	
begin
	for parent in (select r.table_name, c.column_name, r.id_obj, t.constraint_name 
		from user_constraints t, user_cons_columns c, redu_add r
		where t.owner = c.owner and t.table_name = c.table_name and t.constraint_name = c.constraint_name
			and c.position = 1 and t.table_name = r.table_name and t.constraint_type = 'P' and r.lev = 0) 
	loop
		execute immediate 'select '	||parent.column_name||' from '||parent.table_name||' where id = '||parent.id_obj into vParentId;
		if vParentId is null then 
			continue;
		end if;

		for child in (select c.column_name, t.table_name from user_constraints t, user_cons_columns c
			where t.owner = c.owner and t.table_name = c.table_name and t.constraint_name = c.constraint_name
			and c.position = 1 and t.r_constraint_name = parent.constraint_name and t.constraint_type = 'R') 
		loop
			begin 
				dynStmt := 'select id, 1, '''||child.table_name||''', ''C'' from '||child.table_name||' where '||
					child.column_name||' = '||vParentId||' 
					and (id, '''||child.table_name||''') not in (select id_obj, table_name from redu_add)' ;
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
exec addChild;
/* drop procedure addChild; */
exit



