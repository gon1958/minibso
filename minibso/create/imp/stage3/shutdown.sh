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


# Завершаем ORACLE
echo '*** shutdown.sql start' `date` 
sqlplus ${CONNECT_SYS} @shutdown.sql 
echo '*** shutdown.sql stop' `date`  

