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

# Генерация скрипта импорта таблиц
rm -f ./imptab.scr
for FIL in $(find ${DATA_PATH} -type f -name '*.dmp' | sort); do
DFIL="${DATA_PATH}`basename $FIL`"
LFIL="${DATA_PATH}`basename $FIL .dmp`.ilog"
echo "imp '"${IBS_TARGET}"' file='"${DFIL}"' full=y log='"${LFIL}"' IGNORE=Y" >> imptab.scr
done

$SHELL ./imptab.scr 
