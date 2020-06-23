create or replace function redu_calcStat1 return number as
	n_rows number;
	retval number := 0;
	tabCount number := 10;
begin
	delete redu_stat where end_date is null;
	commit;
	for c in (select view_name from user_views where view_name like 'REDU!_%' escape '!'
	and view_name not in (select view_name from redu_stat) and rownum <= tabCount) loop
		dbms_application_info.set_action( 'View->'||c.view_name );
		insert into redu_stat(view_name, beg_date) values(c.view_name, sysdate);
		commit;
	   begin
		execute immediate 'select count(*) from '||c.view_name into n_rows;
		update redu_stat set rowcount = n_rows, end_date = sysdate where view_name = c.view_name;
		retval := retval + 1;
		commit;
           exception when others then null;
           end;
	end loop;
	return retval;
end;
/
create or replace function redu_calcStat2 return number as
	n_rows number;
	retval number := 0;
	tabCount number := 10;
begin
	delete redu_stat where end_date is null;
	commit;
	for c in (select table_name, where_clause from redu_root where table_name like 'Z#%' 
	and 'REDU_'||table_name not in (select view_name from redu_stat) and rownum <= tabCount) loop
		dbms_application_info.set_action( 'Table->'||c.table_name );
		insert into redu_stat(view_name, beg_date) values('REDU_'||c.table_name, sysdate);
		commit;
           begin
              execute immediate 'select count(*) from '||c.table_name||' where '||c.where_clause into n_rows;
              update redu_stat set rowcount = n_rows, end_date = sysdate where view_name = 'REDU_'||c.table_name;
              retval := retval + 1;
              commit;
           exception when others then null;
           end;
	end loop;
	return retval;
end;
/
create or replace function redu_calcStat3 return number as
	n_rows number;
	retval number := 0;
	tabCount number := 10;
begin
	delete redu_stat where end_date is null;
	commit;
	for c in (select table_name from user_tables where table_name like 'Z#%' 
	and 'REDU_'||table_name not in (select view_name from redu_stat) and rownum <= tabCount) loop
		dbms_application_info.set_action( 'Table->'||c.table_name );
		insert into redu_stat(view_name, beg_date) values('REDU_'||c.table_name, sysdate);
		commit;
	   begin
		execute immediate 'select count(*) from '||c.table_name into n_rows;
		update redu_stat set rowcount = n_rows, end_date = sysdate where view_name = 'REDU_'||c.table_name;
		retval := retval + 1;
		commit;
           exception when others then null;
           end;
	end loop;
	return retval;
end;
/
begin
	while redu_calcStat1() > 0 loop
		null;
	end loop;
end;	
/	
begin
	while redu_calcStat2() > 0 loop
		null;
	end loop;
end;	
/	
begin
	while redu_calcStat3() > 0 loop
		null;
	end loop;
end;	
/	
drop function redu_calcStat1;
drop function redu_calcStat2;
drop function redu_calcStat3;
EXIT
	
	
