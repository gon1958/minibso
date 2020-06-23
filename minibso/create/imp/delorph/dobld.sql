drop table redu_constraints;
create table redu_constraints as
	SELECT 1 as lev, 1 as pk, 1 as fk,  constraint_name FROM user_constraints WHERE 1 = 2;
insert into redu_constraints(lev, pk, fk, constraint_name) 
	SELECT 0, 0, 1, constraint_name FROM user_constraints WHERE status = 'DISABLED' AND CONSTRAINT_TYPE = 'R' and 
		constraint_name in (select constraint_name from user_cons_columns having count(*) = 1 
		group by constraint_name);
commit;

CREATE OR REPLACE function delorph return number AS
	chi_tab VARCHAR(30);
	chi_class varchar(30);
	chi_col VARCHAR(30);
	par_tab VARCHAR(30);
	par_col VARCHAR(30);	
	cons_name VARCHAR(30);
	n_rows_tab NUMBER;
	n_rows_all NUMBER;
	n_attempt NUMBER;
	s varchar(2000);
	max_rows number := 100000;
	maynull varchar2(1);
BEGIN	
--	s := rtl.open;	
	n_rows_all := 0;
	select min(lev) into n_attempt from redu_constraints where fk > 0;
	begin	
		SELECT constraint_name  into cons_name FROM redu_constraints 
			where fk > 0 and lev = n_attempt and rownum = 1 order by lev asc;
	exception
		when NO_DATA_FOUND then return 0;
	end;
	SELECT chc.column_name, ch.table_name, cpa.column_name, pa.table_name 
		INTO chi_col, chi_tab, par_col, par_tab
		FROM  user_constraints ch, user_constraints pa, 
			user_cons_columns chc, user_cons_columns cpa
		WHERE ch.constraint_name = cons_name AND
		ch.r_constraint_name = pa.constraint_name AND ch.owner = pa.owner AND
		ch.constraint_name = chc.constraint_name AND ch.owner = chc.owner AND
		pa.constraint_name = cpa.constraint_name AND pa.owner = cpa.owner;
	if chi_col != 'ID' then
		select nullable into maynull from user_tab_columns 
			where table_name = chi_tab and column_name = chi_col;
	else
		maynull := 'N'; 
	end if;
	
	if maynull != 'N' then
		BEGIN
			EXECUTE IMMEDIATE 'UPDATE '||chi_tab||' SET '||chi_col||' = NULL WHERE NOT EXISTS '
				||'(SELECT 1 FROM '||par_tab||' WHERE '||par_tab||'.'||par_col||' = '
				||chi_tab||'.'||chi_col||')and '||chi_tab||'.'||chi_col||' is not null';
			n_rows_tab := SQL%ROWCOUNT;
			update redu_constraints set pk = 0, fk = 0 where constraint_name = cons_name;
			commit;
			if n_rows_tab > 0 then
				DBMS_OUTPUT.PUT_LINE('do> Set NULL orphan in table    : '||chi_tab||'('||cons_name||') = '||to_char(n_rows_tab));
			end if;
		EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			IF SQLCODE = -2292 THEN 
				cons_name := SUBSTR(SQLERRM, INSTR(SQLERRM, '.') + 1, INSTR(SQLERRM, ')') - INSTR(SQLERRM, '.') - 1);
				SELECT table_name INTO chi_tab
				FROM  user_constraints 
				WHERE constraint_name = cons_name;
				DBMS_OUTPUT.PUT_LINE('do> Disable constraint for table : '||chi_tab||'('||cons_name||') -> '||par_tab);
				EXECUTE IMMEDIATE 'ALTER TABLE '||chi_tab||' DISABLE CONSTRAINT '||cons_name;
			ELSE
				maynull := 'N'; -- unknown error. May be DUPLICATE UNIQUE KEY. Probe 'ON DELETE CASCADE'
			END IF;
		END;		
	end if;
	commit;
	
	if maynull = 'N' then
		begin
			n_rows_all := 0;
			loop
				EXECUTE IMMEDIATE 'DELETE '||chi_tab||' WHERE NOT EXISTS '
					||'(SELECT 1 FROM '||par_tab||' WHERE '||par_tab||'.'||par_col||' = '
					||chi_tab||'.'||chi_col||')and '||chi_tab||'.'||chi_col||' is not null and rownum <= '||max_rows;
				n_rows_tab := SQL%ROWCOUNT;
				n_rows_all := n_rows_all + n_rows_tab;
				commit;
				exit when n_rows_tab < max_rows;
			end loop;
			update redu_constraints set pk = n_rows_tab, fk = 0 where constraint_name = cons_name;
			if n_rows_all > 0 then
				DBMS_OUTPUT.PUT_LINE('do> Delete orphan in table    : '||chi_tab||'('||cons_name||') = '||to_char(n_rows_all));
			end if;
		EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			IF SQLCODE = -2292 THEN 
				cons_name := SUBSTR(SQLERRM, INSTR(SQLERRM, '.') + 1, INSTR(SQLERRM, ')') - INSTR(SQLERRM, '.') - 1);
				SELECT table_name INTO chi_tab
					FROM  user_constraints 
					WHERE constraint_name = cons_name;
				DBMS_OUTPUT.PUT_LINE('do> Disable constraint for table : '||chi_tab||'('||cons_name||') -> '||par_tab);
				EXECUTE IMMEDIATE 'ALTER TABLE '||chi_tab||' DISABLE CONSTRAINT '||cons_name;
			ELSE
				DBMS_OUTPUT.PUT_LINE('do> Unprocessed error : '||SQLCODE||' '||SQLERRM);
			END IF;
		END;		
	end if;
	commit;
--	rtl.close;

	/* new disabled constraints */
	insert into redu_constraints(lev, pk, fk, constraint_name) 
		SELECT n_attempt + 1, 0, 1, constraint_name FROM user_constraints WHERE status = 'DISABLED' 
		AND CONSTRAINT_TYPE = 'R' and constraint_name in 
		(select constraint_name from user_cons_columns having count(*) = 1 
		group by constraint_name) 
		and constraint_name not in (select constraint_name from redu_constraints);
	n_rows_tab := SQL%ROWCOUNT;
	n_rows_all := n_rows_all + n_rows_tab;
--	update redu_constraints set pk = 0;
	commit;
	
	/* fk for deleted records */
	update redu_constraints set fk = 1, lev = n_attempt + 1 where constraint_name in 
		(select constraint_name from user_constraints where r_constraint_name in 
			(select constraint_name from user_constraints where constraint_type = 'P' and table_name in
				(select table_name from user_constraints where constraint_name in 
					(select constraint_name from redu_constraints where pk  > 0))));
	n_rows_tab := SQL%ROWCOUNT;
	n_rows_all := n_rows_all + n_rows_tab;
	update redu_constraints set pk = 0;
	commit;
	
	/* need more work? */
	select count(*) into n_rows_tab from redu_constraints where fk > 0;
	n_rows_all := n_rows_all + n_rows_tab;
	
	if n_rows_all != 0 then 
		n_rows_all := 1;
	end if;
	return n_rows_all;
END delorph;
/
show error
exit
