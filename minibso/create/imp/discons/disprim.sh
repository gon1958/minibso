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

# Отключаем первичные и уникальные ключи
echo '*** dispk.sql start' `date` >>disprim.log
sqlplus ${IBS_TARGET} @dispk.sql >dispk.log
echo '*** dispk.sql stop ' `date` >>disprim.log
