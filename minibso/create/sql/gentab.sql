spool gentab.log

DROP TABLE genobj_res;
CREATE TABLE genobj_res(id number, text CLOB);

drop table genddl_objs;
-- таблицы
create table genddl_objs as
	select /*+ result_cache dynamic_sampling(0) no_monitoring */ segment_name, 'TB' segment_type from (
		select segment_name, tablespace_name, sum(bytes)/(1024*1024) summb from user_extents 
		where segment_type = 'TABLE' group by segment_name, tablespace_name)
		where (summb > 100 or tablespace_name not in ('T_AUD', 'I_AUD', 'T_DICT', 'I_DICT', 'T_USR', 'I_USR') 
			or segment_name = 'USERS')
--		and rownum <= 10 
		;
		
-- индексы		
insert into genddl_objs
	select /*+ result_cache dynamic_sampling(0) no_monitoring */ table_name, 'TB' segment_type from user_indexes 
		where index_name in(
		select segment_name from (
			select segment_name, tablespace_name, sum(bytes)/(1024*1024) summb from user_extents 
			where segment_type = 'INDEX' group by segment_name, tablespace_name)
			where (summb > 100 or tablespace_name not in ('T_AUD', 'I_AUD', 'T_DICT', 'I_DICT', 'T_USR', 'I_USR')
				or segment_name = 'USERS')
		)
--			and rownum <= 10
			;
			
-- родители вложенных таблиц
insert into genddl_objs			
	select parent_table_name, 'TB' segment_type from user_nested_tables where table_name in (select segment_name from genddl_objs)
		;

-- типы для всех вложенных таблиц		
insert into genddl_objs
	select type_name, 'TY' segment_type from user_types where type_name in 
		(select table_type_name from user_nested_tables n, genddl_objs o where n.table_name = o.segment_name and segment_type = 'TB')
		;

-- типы для столбцов всех таблиц
insert into genddl_objs
	select data_type, 'TY' segment_type from user_tab_columns c, genddl_objs o where c.table_name = o.segment_name 
		and c.data_type_owner = 'IBS' and segment_type = 'TB'
		;

-- типы от которых зависят типы
insert into genddl_objs
select distinct referenced_name, 'TY' from user_dependencies where referenced_type = 'TYPE'
  start with name in (select segment_name from genddl_objs where segment_type = 'TY') and type = 'TYPE'
  connect by nocycle referenced_name = prior name and referenced_type = prior type;

commit;		

declare
h_table number; 
hx_table number; 
seq_id number := 0;
r CLOB;

table_ddls sys.ku$_ddls; -- DDL lists for each table
table_ddl sys.ku$_ddl; -- single DDL statement

---- output files
d number;
begin
-- TYPE -----------------------------------------------------------------------------------------------------------------
	h_table := dbms_metadata.open('TYPE'); 
	dbms_metadata.set_filter(h_table, 'SCHEMA', user); 
	dbms_metadata.set_filter(h_table, 'NAME_EXPR', 'in (select segment_name from '||user||'.genddl_objs where segment_type = ''TY'')'); 
	
	hx_table := dbms_metadata.add_transform(h_table, 'DDL');
        dbms_metadata.set_transform_param(hx_table, 'SQLTERMINATOR', TRUE);
	
	loop
		table_ddls := dbms_metadata.fetch_ddl(h_table);
		exit when table_ddls is null;
		for d in 1..table_ddls.count loop
			table_ddl := table_ddls(d);
			seq_id := seq_id + 1;
			insert into genobj_res(id, text) values (seq_id, table_ddl.ddltext);
		end loop;
	end loop;
	commit;
	dbms_metadata.close(h_table);

-- TABLE -----------------------------------------------------------------------------------------------------------------
    h_table := dbms_metadata.open('TABLE');
	dbms_metadata.set_filter(h_table, 'SCHEMA', user); 
	dbms_metadata.set_filter(h_table, 'NAME_EXPR', 'in (select segment_name from '||user||'.genddl_objs where segment_type = ''TB'')'); 
    
    -- set items we want to identify in each DDL
/*
    dbms_metadata.set_parse_item(h_table,'SCHEMA');
    dbms_metadata.set_parse_item(h_table,'NAME');
    dbms_metadata.set_parse_item(h_table,'VERB');
    dbms_metadata.set_parse_item(h_table,'OBJECT_TYPE');
*/
    hx_table := dbms_metadata.add_transform(h_table,'MODIFY');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_LONG_DATA', 'T_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'I_LONG_DATA', 'I_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_RECORD', 'T_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'I_RECORD', 'I_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_MN', 'T_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'I_MN', 'I_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_LOB', 'T_USR');

    hx_table := dbms_metadata.add_transform(h_table, 'DDL');
    dbms_metadata.set_transform_param(hx_table, 'SQLTERMINATOR', TRUE);
    dbms_metadata.set_transform_param(hx_table, 'SEGMENT_ATTRIBUTES', FALSE);
--    dbms_metadata.set_transform_param(hx_table, 'CONSTRAINTS_AS_ALTER', TRUE);
	dbms_metadata.set_transform_param(hx_table, 'STORAGE', false);
	dbms_metadata.set_transform_param(hx_table, 'PCTSPACE', 0);
	dbms_metadata.set_transform_param(hx_table, 'REF_CONSTRAINTS', false);
	
loop
    table_ddls := dbms_metadata.fetch_ddl(h_table);
	exit when table_ddls is null;
    for d in 1..table_ddls.count loop
        table_ddl := table_ddls(d);
		seq_id := seq_id + 1;
		insert into genobj_res(id, text) values (seq_id, table_ddl.ddltext);
    end loop;
end loop;

	dbms_metadata.close(h_table);
	commit;

-- INDEX -----------------------------------------------------------------------------------------------------------------
    h_table := dbms_metadata.open('INDEX');
	dbms_metadata.set_filter(h_table, 'SCHEMA', user); 
	dbms_metadata.set_filter(h_table, 'NAME_EXPR', 'in (select index_name from user_indexes where table_name in '||
		'(select segment_name from '||user||'.genddl_objs where segment_type = ''TB''))'); 
    
    hx_table := dbms_metadata.add_transform(h_table,'MODIFY');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_LONG_DATA', 'T_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'I_LONG_DATA', 'I_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_RECORD', 'T_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'I_RECORD', 'I_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_MN', 'T_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'I_MN', 'I_USR');
	dbms_metadata.set_remap_param(hx_table, 'REMAP_TABLESPACE', 'T_LOB', 'T_USR');

    hx_table := dbms_metadata.add_transform(h_table,'DDL');
    dbms_metadata.set_transform_param(hx_table, 'SQLTERMINATOR',TRUE);
    dbms_metadata.set_transform_param(hx_table, 'SEGMENT_ATTRIBUTES', FALSE);
	dbms_metadata.set_transform_param(hx_table, 'STORAGE', false);
	dbms_metadata.set_transform_param(hx_table, 'PCTSPACE', 0);
	
loop
    table_ddls := dbms_metadata.fetch_ddl(h_table);
	exit when table_ddls is null;
    for d in 1..table_ddls.count loop
        table_ddl := table_ddls(d);
		seq_id := seq_id + 1;
		insert into genobj_res(id, text) values (seq_id, table_ddl.ddltext);
    end loop;
end loop;
commit;

end;
/

set head off
set feed off
set pagesize 0
set long 50000
set lines 300
set define off
set trimspool on
set trimout on

col text format a250 WORD
spool tabgen.txt
select 'spool tabgen.log' from dual;
select text from genobj_res order by id asc;
spool off

spool tabdrop.txt
select distinct 'drop table '||segment_name||';' from genddl_objs where segment_type = 'TB';
spool off

--DROP TABLE genobj_res;
--drop table genddl_objs;

EXIT
