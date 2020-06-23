SET PAGESIZE 0
SET FEEDBACK OFF
SPOOL remove.scr

SELECT 'DROP VIEW IBS.' || VIEW_NAME || ';' FROM USER_VIEWS
	WHERE view_name like 'REDU\_%' ESCAPE '\';

SPOOL OFF

SET TERMOUT OFF
@remove.scr
drop table redu_objects;
DROP TABLE redu_tab;
DROP TABLE redu_dep;
DROP TABLE redu_root;
DROP TABLE redu_client;
DROP TABLE redu_stat;

EXIT
