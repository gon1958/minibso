rem select 'CREATE OR REPLACE CONTEXT '||namespace||' USING '||package||' '||decode(type, 'ACCESSED GLOBALLY', type )||';' 
rem from dba_context where schema = 'IBS';

CREATE OR REPLACE CONTEXT IBS_USER USING USER_CONTEXT ;
CREATE OR REPLACE CONTEXT IBS_SYSTEM USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RIGHTS USING SECURITY ;
CREATE OR REPLACE CONTEXT IBS_ORIGHTS USING EXECUTOR ;
CREATE OR REPLACE CONTEXT IBS_ERIGHTS USING EXECUTOR ;
CREATE OR REPLACE CONTEXT IBS_GLOBAL USING VALMGR ACCESSED GLOBALLY;
CREATE OR REPLACE CONTEXT IBS_OPTIONS USING OPT_MGR ACCESSED GLOBALLY;
CREATE OR REPLACE CONTEXT IBS_ACCESS USING EXECUTOR ;
CREATE OR REPLACE CONTEXT IBS_SETTS USING RTL ACCESSED GLOBALLY;
CREATE OR REPLACE CONTEXT IBS_USERS USING RTL ACCESSED GLOBALLY;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY1 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY2 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY3 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY4 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY5 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY6 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY7 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY8 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY9 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_RTL_PROXY0 USING RTL ;
CREATE OR REPLACE CONTEXT IBS_KEYS USING VALMGR ACCESSED GLOBALLY;
CREATE OR REPLACE CONTEXT IBS_MPU USING RTL ACCESSED GLOBALLY;
exit
