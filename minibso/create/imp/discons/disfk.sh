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

# Отключаем ссылочную целостность
echo '*** disfkall.sql start' `date` >>disfor.log
if [ "$1" == "lst" ]
then
sqlplus ${IBS_TARGET} @disfklst.sql >disfklst.log
else
sqlplus ${IBS_TARGET} @disfkall.sql >disfkall.log
fi
echo '*** disfkall.sql stop ' `date` >>disfor.log
