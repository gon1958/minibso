DROP TABLE redu_objects;
CREATE TABLE redu_objects as select * from user_objects;

DROP TABLE redu_tab;
CREATE TABLE redu_tab AS
SELECT table_name FROM user_tables;
COMMIT;

DROP TABLE redu_root;
CREATE TABLE redu_root(
	owner VARCHAR2(30),
	table_name VARCHAR2(30),
	where_clause VARCHAR2(1000),
	hidden varchar2(1),
	used number)
;

create unique index idx_redu_root1 on redu_root(table_name);


EXIT
