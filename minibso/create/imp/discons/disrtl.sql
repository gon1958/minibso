alter trigger audm.logon_trigger disable;
alter trigger audm.IBS_USERS disable;
declare 
s varchar2(2000);
begin
	s:= ibs.rtl.lock_hold(true);
end;
/
exit	
