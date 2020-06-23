#!/bin/sh
# Генерация скрипта импорта статических объектов

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

rm ./impstat.scr
for FIL in ${DATA_PATH}*.sta; do
DFIL="${DATA_PATH}`basename $FIL`"
LFIL="${DATA_PATH}`basename $FIL .sta`.iout"
echo "imp '"${IBS_TARGET}"' file='"${DFIL}"' full=y log='"${LFIL}"' IGNORE=Y" >> impstat.scr
done

$SHELL ./impstat.scr 