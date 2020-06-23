#!/bin/sh
# Экспорт пустой схемы (без данных)

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

echo '*** exp scheme start' `date` >>exp.log
exp ${IBS_SOURCE} OWNER=ibs FILE="${DATA_PATH}IBSSHM.EXP" LOG="${DATA_PATH}IBSSHM.ELOG" ROWS=n COMPRESS=n STATISTICS=none
echo '*** exp scheme stop ' `date` >>exp.log


