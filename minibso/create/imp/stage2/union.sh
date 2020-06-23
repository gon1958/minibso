#!/bin/sh
# detect Cygwin
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac

if $cygwin; then
. ../profile.win
else
. ../profile.lin
fi

# Создание котекста
echo '*** cntxset.sql start ' `date` >>union.log
sqlplus ${IBS_TARGET} @cntxset.sql >> cntxset.log
echo '*** cntxset.sql stop  ' `date` >>union.log

# Внешние модули
echo '*** fio.sql start ' `date`>>union.log
sqlplus ${CONNECT_SYS} @fio.sql >> fio.log
echo '*** fio.sql stop  ' `date`>>union.log

# Прочие капризные объекты
echo '*** rtl2.sql start ' `date` >>union.log
#sqlplus ${IBS_TARGET} @rtl1_2.plb >> rtl2.log
echo '*** rtl2.sql stop  ' `date` >>union.log

echo '*** misc.sql start ' `date` >>union.log
sqlplus ${IBS_TARGET} @misc.sql >> misc.log
echo '*** misc.sql stop  ' `date` >>union.log

# Компиляция объектов схемы
echo '*** recomp.sql start' `date`>>union.log
#sqlplus ${CONNECT_SYS} @recomp.sql >> recomp.log
echo '*** recomp.sql stop ' `date`>>union.log



