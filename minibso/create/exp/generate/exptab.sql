set head OFF
set feed OFF
set pagesize 0
set linesize 300
set SERVEROUTPUT ON
SPOOL exptab1.scr
DECLARE
	l number;
	t clob;
	w clob;
BEGIN
	delete redu_res;
	commit;
	DBMS_OUTPUT.ENABLE(NULL);
	for c in (SELECT DISTINCT owner, table_name from redu_dep 
		where (owner, table_name) not in 
			(select table_type_owner, table_name from user_nested_tables
			union all 
			select table_type_owner, parent_table_name from user_nested_tables
			union all
			SELECT owner, table_name FROM redu_root where used = 0)
		ORDER BY table_name ASC
	) LOOP
		w := null; t := null; l := null;
		w:=genwhere(c.owner, c.table_name, null, l, t);
		COMMIT;
		insert into redu_res(text) values(w);
		DBMS_OUTPUT.PUT_LINE('exp ${IBS_SOURCE} tables=''"'||c.owner||'.'||c.table_name||'"'' QUERY=\"WHERE id IN \(SELECT id from '||c.owner||'.REDU_'||c.table_name||'\)\"'||' file="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.dmp" log="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.elog" GRANTS=N INDEXES=N TRIGGERS=N CONSTRAINTS=N STATISTICS=none');
		COMMIT;
	END LOOP;
END;
/
SPOOL OFF

SPOOL exptab2.scr
BEGIN
	FOR c in (SELECT owner, table_name, where_clause FROM redu_root WHERE table_name NOT IN
		(SELECT table_name from redu_dep) or used = 0
	) LOOP
		DBMS_OUTPUT.PUT_LINE('exp ${IBS_SOURCE} tables=''"'||c.owner||'.'||c.table_name||'"'' QUERY=\"WHERE \('||symsubst(c.where_clause)||'\)\"'||' file="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.dmp" log="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.elog" GRANTS=N INDEXES=N TRIGGERS=N CONSTRAINTS=N STATISTICS=none');
		COMMIT;
	END LOOP;
END;
/
SPOOL OFF

spool exptab3.scr
BEGIN
	FOR c in (SELECT table_name FROM redu_tab where table_name NOT IN
		(select table_name from( 
			(SELECT DISTINCT table_name from redu_dep 
				where table_name not in 
					(select table_name from user_nested_tables
					union all 
					select parent_table_name from user_nested_tables
					union all
					SELECT table_name FROM redu_root where used = 0)
			)
			union all
			(SELECT table_name FROM redu_root WHERE table_name NOT IN
				(SELECT table_name from redu_dep) or used = 0)
			)
		)
	) LOOP
		DBMS_OUTPUT.PUT_LINE('exp ${IBS_SOURCE} tables=''"'||'IBS'||'.'||c.table_name||'"'' file="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.dmp" log="${DATA_PATH}'||TRANSLATE(c.table_name,'$#','__')||'.elog" GRANTS=N INDEXES=N TRIGGERS=N CONSTRAINTS=N STATISTICS=none');
		COMMIT;
	END LOOP;

END;
/
SPOOL OFF
DECLARE
	beg NUMBER := 1;
	s CLOB;
	fin NUMBER := 0;
	len NUMBER;
	incr NUMBER := 79;
	n_sql NUMBER := 0;
	n_lin NUMBER;
BEGIN
	DELETE redu_out;
	COMMIT;
	FOR c IN (SELECT text FROM redu_res) LOOP
		s := c.text; beg := 1; fin := 0;
		n_sql := n_sql + 1; n_lin := 0;
		WHILE beg <= LENGTH(s) LOOP
			n_lin := n_lin + 1;
			IF beg+incr < LENGTH(s) THEN
				FOR fin IN REVERSE beg..beg+incr LOOP
					IF SUBSTR(s,fin,1) IN (' ','(',')') THEN
						len := fin - beg + 1;
						EXIT;
					END IF;
				END LOOP;
			ELSE
 				len := LENGTH(s) - beg + 1;
			END IF;
			INSERT INTO redu_out(sql_id, line_id, text) VALUES (n_sql, n_lin, SUBSTR(s,beg,len));
			COMMIT;
			beg := beg+len;
			fin := 0;
		END LOOP;
	END LOOP;
END;
/
set head off
set feed off
set pagesize 0
SPOOL exptab.viw
select text FROM redu_out order by sql_id ASC, line_id ASC;
SELECT 'EXIT' FROM DUAL;
SPOOL OFF
/
EXIT
