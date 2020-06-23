SET SERVEROUTPUT ON

define scan_collection=" and 1=1";

DROP TABLE redu_dep;
CREATE TABLE redu_dep AS
SELECT 1 AS lev, s.owner, CAST(s.constraint_name AS VARCHAR2(120)) constraint_name, s.constraint_type, s.table_name,
	c.column_name, c.position, s.r_owner, CAST(s.r_constraint_name AS VARCHAR2(120)) r_constraint_name, 0 as used
FROM user_constraints s, user_cons_columns c
WHERE s.owner = c.owner AND s.constraint_name = c.constraint_name AND
	s.constraint_type = 'P' AND
	(s.owner, s.table_name) in (SELECT owner, table_name FROM redu_root
	WHERE table_name NOT LIKE 'RC$%');
COMMIT;

INSERT INTO redu_dep 
SELECT 1, 'IBS', 'CLLPAR_'||ct1.table_name||'_'||ct1.column_name, 'P', ct1.table_name, 
	ct1.column_name, 1,  NULL, NULL, 0
FROM class_attributes a, classes c, class_tab_columns ct1, class_tables ct2
WHERE c.id = a.self_class_id AND c.base_class_id = 'COLLECTION'
	AND ct1.class_id = a.class_id AND ct1.qual = a.attr_id
	AND ct2.class_id = c.target_class_id AND
	('IBS', ct1.table_name) in (SELECT owner, table_name FROM redu_root
		WHERE table_name NOT LIKE 'RC$%') 
	&scan_collection;
COMMIT;	


create index idx_redu_dep1 on redu_dep(table_name, constraint_type);
create index idx_redu_dep2 on redu_dep(constraint_name);


DECLARE
	i_lev number := 1;
	n_rows number;
	nref NUMBER;
BEGIN
LOOP
-- Add new reference constraints
	INSERT INTO redu_dep
	SELECT i_lev + 1 AS lev, s.owner, s.constraint_name, s.constraint_type, s.table_name,
		c.column_name, c.position, s.r_owner, s.r_constraint_name, -1
	FROM user_constraints s, user_cons_columns c
	WHERE s.owner=c.owner AND s.constraint_name = c.constraint_name AND
		s.constraint_type = 'R' AND
		(s.owner, s.constraint_name) NOT IN (SELECT owner, constraint_name FROM redu_dep) AND
		(s.r_owner, s.r_constraint_name) IN (SELECT owner, constraint_name FROM redu_dep);
	COMMIT;

-- Collection references	
	INSERT INTO redu_dep
	select i_lev + 1, 'IBS', 'CLLFOR_'||ct2.table_name||'_'||ct1.table_name||'_'||ct1.column_name, 'R', ct2.table_name, 
		'COLLECTION_ID', 1, 'IBS', 'CLLPAR_'||ct1.table_name||'_'||ct1.column_name, -1
	from class_attributes a, classes c, class_tab_columns ct1, class_tables ct2
	where c.id = a.self_class_id and c.base_class_id = 'COLLECTION'
	and ct1.class_id = a.class_id and ct1.qual = a.attr_id
	and ct2.class_id = c.target_class_id and 
	('IBS', 'CLLFOR_'||ct2.table_name||'_'||ct1.table_name||'_'||ct1.column_name) not in (SELECT owner, constraint_name FROM redu_dep) AND
	('IBS', 'CLLPAR_'||ct1.table_name||'_'||ct1.column_name) in (SELECT owner, constraint_name FROM redu_dep)
	 &scan_collection;
	COMMIT;
	i_lev := i_lev + 1;

-- Validate using reference
	FOR c IN (SELECT chi.rowid, chi.owner AS owner, chi.table_name AS chi_table, chi.column_name AS chi_column,
		par.table_name AS par_table, par.column_name AS par_column
		FROM redu_dep chi, redu_dep par WHERE par.owner = chi.r_owner AND
		par.constraint_name = chi.r_constraint_name AND chi.used < 0) LOOP
			IF c.chi_column != 'COLLECTION_ID' THEN
				EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||c.owner||'.'||c.par_table||' par, '||
					c.owner||'.'||c.chi_table||' chi '||
					'WHERE par.'||c.par_column||' = chi.'||c.chi_column||' and rownum < 100000' INTO nref;
			ELSE
				EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||c.owner||'.'||c.chi_table||' chi where rownum < 100000' INTO nref;
			END IF;
			UPDATE redu_dep SET used = nref WHERE rowid = c.rowid;
	END LOOP;
	COMMIT;

-- Add PK for next level tables
	INSERT INTO redu_dep
	SELECT i_lev + 1 AS lev, s.owner, s.constraint_name, s.constraint_type, s.table_name,
		c.column_name, c.position, s.r_owner, s.r_constraint_name, 0
	FROM user_constraints s, user_cons_columns c
	WHERE s.owner=c.owner AND s.constraint_name = c.constraint_name AND
		s.constraint_type = 'P' AND
		(s.owner, s.table_name) in (SELECT owner, table_name from redu_dep where constraint_type = 'R') AND
		(s.owner, s.table_name) not in (select owner, table_name from redu_dep where constraint_type = 'P');
	n_rows := sql%rowcount;
	COMMIT;
	INSERT INTO redu_dep
	SELECT i_lev + 1 AS lev, 'IBS', 'CLLPAR_'||ct1.table_name||'_'||ct1.column_name, 'P', ct1.table_name,
		ct1.column_name, 1, NULL, NULL, 0
	FROM class_attributes a, classes c, class_tab_columns ct1, class_tables ct2
	WHERE c.id = a.self_class_id and c.base_class_id = 'COLLECTION'
		AND ct1.class_id = a.class_id and ct1.qual = a.attr_id
		AND ct2.class_id = c.target_class_id and
		('IBS', ct1.table_name) in (select owner, table_name from redu_dep where constraint_type = 'R') AND
		('IBS', 'CLLPAR_'||ct1.table_name||'_'||ct1.column_name) not in (select owner, constraint_name from redu_dep where constraint_type = 'P')
		 &scan_collection;
	n_rows := n_rows + sql%rowcount;
	COMMIT;
--	DBMS_OUTPUT.PUT_LINE(n_rows);
	IF n_rows > 0 THEN
		i_lev := i_lev + 1;
	ELSE
		EXIT;
	END IF;
END LOOP;

-- delete hidden constraints
delete redu_dep where r_constraint_name in (
	select constraint_name from redu_dep where constraint_type = 'P' and table_name in (
		select table_name from redu_root where hidden = 'Y'));
delete redu_dep where table_name in (
	select table_name from redu_root where hidden = 'Y');
commit;	

END;
/
EXIT
