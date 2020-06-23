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

imp ${IBS_SOURCE} FILE=redutab.dmp LOG=redutab.log 
sqlplus ${IBS_SOURCE} @exptab.viw >> exptab.log
sqlplus ${IBS_SOURCE} @createtb.sql >> createtb.log
sqlplus ${IBS_SOURCE} @rowcnt.sql >> rowcnt.log
