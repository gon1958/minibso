create table redu_add(
		id_obj	varchar2(30),
		lev			number,
		table_name varchar2(30),
		key_type	 varchar2(1)
);
create unique index pk_redu_add on redu_add(id_obj, table_name);

create or replace procedure insertReduAdd(pId varchar2, pLev number, pKeyType varchar2) is
	vTabName varchar2(30);
	vCnt integer;
begin
	select count(*) into vCnt from redu_add where id_obj = pId;
	if vCnt = 0 then 
		select class_id   into vTabName from objects      where id = pId and rownum = 1;
		select table_name into vTabName from class_tables where class_id = vTabName;

		for tab in (select t.table_name from classes c, class_tables t where t.class_id = c.id
			and (pId, t.table_name) not in (select id, table_name from redu_add)
			start with t.table_name = vTabName connect by prior c.parent_id = c.id
		) loop
			insert into redu_add(id_obj, lev, table_name, key_type) values (pId, pLev, tab.table_name, pKeyType);
		end loop;
		commit;
	end if;
end;
/
exit


