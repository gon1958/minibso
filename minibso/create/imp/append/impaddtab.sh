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

# Удалить возможно существующую таблицу redu_add
echo '*** dropadd.sql start' `date` >>impaddtab.log
sqlplus ${IBS_TARGET} @dropadd.sql > dropadd.log
echo '*** dropadd.sql stop ' `date` >>impaddtab.log

# Импортируем 
echo '*** imp redu_add start' `date` >>impaddtab.log
imp ${IBS_TARGET} file="${DATA_PATH}REDU_ADD.dat" full=y log="${DATA_PATH}REDU_ADD.ilog" >> impreduadd.scr
echo '*** imp redu_add stop' `date` >>impaddtab.log


