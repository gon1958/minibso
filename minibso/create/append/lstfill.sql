def start_obj = ''
@objectid.start
var root_object varchar2(20);
execute :root_object := '&start_obj';

declare
begin
	insertReduAdd(:root_object, 0, 'P');
end;
/	
exit


