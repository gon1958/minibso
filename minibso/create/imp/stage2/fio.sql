create or replace library ibs.libfio as '/home/oracle/tools/fio/libfio64.so';
/
ALTER TRIGGER "IBS"."LOG_Z#SYSTEM_PARAMS" DISABLE;
update ibs.z#system_params set c_value = '/home/oracle/tools/inout' where c_code = 'PATH_LOCAL';
commit;
ALTER TRIGGER "IBS"."LOG_Z#SYSTEM_PARAMS" ENABLE;

update ibs.profiles set value='/home/oracle/tools/fio/fio_minibso.log' where resource_name='FIO_LOG_FILE';
update ibs.profiles set value='/home/oracle/tools/temp' where resource_name='FIO_TEMP_DIR';
update ibs.profiles set value='/home/oracle/tools/inout' where resource_name='FIO_HOME_DIR';
update ibs.profiles set value='' where resource_name='FIO_ROOT_DIR';
update ibs.profiles set value='<CHECK_ROOT>' where resource_name='FIO_BASE_DIR';
update ibs.profiles set value='' where resource_name='FIO_EXE_DIR';


/

create or replace view sys.ALL_SYNONYMS_920X (
 OWNER, SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, DB_LINK) as
select u.name, o.name, s.owner, s.name, s.node
from sys.user$ u, sys.syn$ s, sys.obj$ o
where o.obj# = s.obj#
  and o.type# = 5
  and o.owner# = u.user#
  and (
       o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */)  /* user's private, any public */
       or /* user has any privs on base object */
        exists
        (select null from sys.objauth$ ba, sys.obj$ bo, sys.user$ bu
         where bu.name = s.owner
           and bo.name = s.name
           and bu.user# = bo.owner#
           and ba.obj# = bo.obj#
           and (   ba.grantee# in (select kzsrorol from x$kzsro)
                or ba.grantor# = USERENV('SCHEMAID')
                )
        )
        or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
       ) 
;       

grant select on sys.ALL_SYNONYMS_920X to public;


commit;

EXIT
