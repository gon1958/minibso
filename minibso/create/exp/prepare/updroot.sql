set echo on

update redu_root set hidden = upper(hidden), table_name = upper(table_name), owner = upper(owner);
commit;

create or replace function redu_calc_used(pTable varchar2, pWhere varchar2) return number is
	retval number;
begin
	execute immediate 'select count(*) from ' || pTable || ' where '||pWhere into retval;
	return retval;
exception
	when others then return 1;
end;
/
	
update redu_root set used = redu_calc_used(table_name, where_clause);
commit;	
	
drop function redu_calc_used;

EXIT

