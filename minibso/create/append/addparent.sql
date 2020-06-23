set serveroutput on;
create or replace procedure addParent (pLev number default 0) is
	vParentId number;
	vChildKey number;
	vNRecord number;
begin
	for child in (select r.table_name, c.column_name, r.id_obj, t.r_constraint_name 
		from user_constraints t, user_cons_columns c, redu_add r
		where t.owner = c.owner and t.table_name = c.table_name and t.constraint_name = c.constraint_name
			and c.position = 1 and t.table_name = r.table_name and t.constraint_type = 'R' and r.lev = pLev) 
	loop
		execute immediate 'select '	||child.column_name||' from '||child.table_name||' where id = '||child.id_obj into vChildKey;
		if vChildKey is null then 
			continue;
		end if;
		
		for parent in (select c.column_name, t.table_name from user_constraints t, user_cons_columns c
		where t.owner = c.owner and t.table_name = c.table_name and t.constraint_name = c.constraint_name 
			and c.position = 1 and t.constraint_name = child.r_constraint_name) 
		loop
			vParentId := NULL;
			begin 
				execute immediate 'select id from '||parent.table_name||' where '||parent.column_name||' = '||vChildKey into vParentId;
			exception
				when NO_DATA_FOUND then NULL;
			end;
				
			if vParentId is null then
				continue;
			end if;
			begin
				insertReduAdd(vParentId, pLev + 1, 'P');
			exception 
				when DUP_VAL_ON_INDEX then null;
			end;
		end loop;
	end loop;
	commit;
	select count(*) into vNRecord from redu_add where key_type = 'P' and lev = pLev + 1 ;
	if vNRecord > 0 then
		addParent (pLev + 1);
	end if;
end;
/
show error
exec addParent ();
/* drop procedure addParent ; */
exit

