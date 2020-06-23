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

# Отключаем технологическое ядро
echo '*** disrtl.sql start' `date` >>dismisc.log
sqlplus ${CONNECT_SYS} @disrtl.sql > disrtl.log
echo '*** disrtl.sql stop ' `date` >>dismisc.log

# Отключаем триггеры
echo '*** distrig.sql start' `date` >>dismisc.log
sqlplus ${IBS_TARGET} @distrig.sql > distrig.log
echo '*** distrig.sql stop ' `date` >>dismisc.log
