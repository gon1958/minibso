alter trigger audm.logon_trigger enable;
alter trigger audm.IBS_USERS enable;
alter system set job_queue_processes=100 scope=both sid='*';
declare 
s varchar2(2000);
begin
	s:= ibs.rtl.lock_hold(false);
end;
/

exec audm.aud_mgr.submit;
/

EXIT
