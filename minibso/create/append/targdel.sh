#!/bin/sh
# detect Cygwin
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac

if $cygwin; then
. ../imp/profile.win
else
. ../imp/profile.lin
fi

echo '*** targdel.sql start' `date`     >> targdel.log
sqlplus ${CONNECT_IBS} @targdel.sql >> targdel.log
echo '*** targdel.sql stop ' `date`     >> targdel.log


