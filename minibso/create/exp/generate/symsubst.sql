create or replace function symsubst(inStr in varchar2) return varchar2
as
	i integer;
	cCh char(1);
	iCh integer;
	outStr varchar2(2000) := '';
begin
	for i in 1..LENGTH(inStr) loop
		cCh := SUBSTR(inStr, i, 1);
		iCh := ASCII(cCh);
		if (iCh = 32) or 
			(iCh >= 97 and iCh <= 122) or 
			(iCh >= 65 and iCh <= 90) or
			(iCh >= 48 and iCh <= 57) then
			outStr := outStr || cCh;
		else
			outStr := outStr || '\' || cCh;
		end if;
	end loop;
	return outStr;
end symsubst;
/
show error
exit
