
DROP TABLE redu_res;

CREATE TABLE redu_res(text CLOB);
DROP TABLE redu_out;
CREATE TABLE redu_out(sql_id number, line_id NUMBER, text VARCHAR2(80));


CREATE OR REPLACE FUNCTION
genwhere(p_owner IN VARCHAR2, p_table IN VARCHAR2 DEFAULT NULL, p_constraint IN VARCHAR2 DEFAULT NULL,
	p_levcall IN OUT NUMBER, p_trace IN OUT CLOB)
	RETURN clob AS

	cur_table redu_dep.table_name%TYPE;
	cur_constraint redu_dep.constraint_name%type;
	cur_pk redu_dep.column_name%TYPE;
	and_op varchar2(5);
	filter CLOB;
	where_value clob;
	ext_trace_mark varchar2(240);
	root_where number;
BEGIN
	IF p_table IS NOT NULL THEN -- Recursive call
		begin
			select constraint_name  into cur_constraint from (
				select constraint_name 
				from redu_dep WHERE owner = p_owner AND table_name = p_table 
					AND constraint_type = 'P' order by DECODE(column_name, 'ID', 0, 1) ASC)
			where rownum = 1;
			
			cur_table := p_table;
		exception
			when no_data_found then
				return '';
		end;
	ELSE 					-- User call
		SELECT table_name INTO cur_table
		FROM redu_dep WHERE owner = p_owner AND constraint_name = p_constraint; 
		cur_constraint := p_constraint;
	END IF;
	SELECT column_name INTO cur_pk FROM redu_dep WHERE owner = p_owner AND table_name = cur_table 
		and constraint_name = cur_constraint;

	p_levcall := NVL(p_levcall, 0) + 1;
	
	/* ADD constraint from redu_root */
	BEGIN
		SELECT where_clause, used INTO filter, root_where FROM redu_root WHERE table_name = cur_table and nvl(hidden, 'N') != 'Y';
		where_value := filter;
		and_op := ' and ';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN 
			root_where := 1;
			and_op := '';
	END;
	
	/* ADD constraint from redu_dep */
	if root_where != 0 and not(nvl(instr(p_trace, 'CLLFOR_'), 0) > 0 ) then
		FOR c_dep IN (
			SELECT table_name, column_name, constraint_name, r_owner, r_constraint_name , ','||table_name||'('||constraint_name||')' as trace_mark
	--		SELECT table_name, column_name, constraint_name, r_owner, r_constraint_name , ','||table_name as trace_mark
			FROM redu_dep t1
			WHERE owner = p_owner AND table_name = cur_table AND constraint_type = 'R' AND used > 0  AND p_levcall <= 220
	--		ORDER BY table_name ASC, DECODE(column_name, 'ID', 0, 1) ASC, column_name ASC  
			ORDER BY DECODE(column_name, 'ID', 0, 'COLLECTION_ID', 2, 1) ASC, used DESC  
		) LOOP
			ext_trace_mark := /*substr(p_trace, instr(p_trace, ',', -1))||*/c_dep.trace_mark;
			if c_dep.column_name = 'ID' or NVL(INSTR(p_trace, ext_trace_mark),0) = 0  then
				p_trace := p_trace || c_dep.trace_mark;
				filter  := genwhere(c_dep.r_owner, NULL, c_dep.r_constraint_name, p_levcall, p_trace);
				IF nvl(length(filter), 0) > 0 THEN
					IF c_dep.column_name = 'ID' THEN
						where_value := where_value || and_op || '(' || c_dep.column_name || ' IN (' ||
							filter || '))';
					ELSE
						where_value := where_value || and_op || '(' || c_dep.column_name || ' IS NULL OR ' || c_dep.column_name || ' IN (' ||
							filter || '))';
					END IF;
					and_op := ' and ';
				end if;
			end if;
		END LOOP;
	end if;
	
	p_levcall := p_levcall - 1;
	
	IF p_levcall = 0 THEN
		IF NVL(LENGTH(where_value), 0) = 0 THEN
			where_value := '1=1';
		END IF;
--		where_value := 'QUERY='||p_owner||'."'||cur_table||'":"'||where_value||'"';
		where_value := 'CREATE OR REPLACE VIEW '||p_owner||'.'||'REDU_'||cur_table||
			' AS SELECT * FROM '||p_owner||'.'||cur_table||' WHERE '||where_value||';';
	else
		if nvl(length(where_value), 0) > 0 then
			where_value := 'SELECT '||cur_pk||' FROM '||p_owner||'.'||cur_table||' WHERE '||where_value;
		end if;
	END IF;
--dbms_output.put_line(and_op||p_levcall||'w='||where_value);	
	RETURN where_value;
END;
/
SHOW ERROR;
EXIT

