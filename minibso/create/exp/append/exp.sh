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

# gen export scripts
echo '*** exprows.sql start' `date`     >> exp.log
sqlplus ${IBS_SOURCE} @exprows.sql >> exprows.log
echo '*** exprows.sql stop ' `date`     >> exp.log

# export object from source
echo '*** exprows.scr start' `date`     >> exp.log
$SHELL ./exprows.scr >> exprows.err
echo '*** exprows.scr stop ' `date`     >> exp.log

echo '*** export redu_add start' `date`     >> exp.log
exp ${IBS_SOURCE} tables='"IBS.REDU_ADD"' file="${DATA_PATH}REDU_ADD.dat" log="${DATA_PATH}REDU_ADD.elog"                                        
echo '*** export redu_add stop ' `date`     >> exp.log

