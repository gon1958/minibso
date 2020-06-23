declare
n number; 
begin
select max(id) into n from objects;
    begin
        execute immediate 'drop sequence seq_id';
    exception when others then
        null;
    end;
execute immediate 'create sequence SEQ_ID'
	||' minvalue 1'
	||' maxvalue 999999999999999999999999999'
	||' start with ' || to_char(nvl(n, 0) + 1)
	||' increment by 1'
	||' cache 8500';
end;
/
EXIT
