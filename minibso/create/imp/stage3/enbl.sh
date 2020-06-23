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


# Подключаем триггер logon, rtl и пр.
echo '*** enblrtl.sql start' `date` >>enbl.log
sqlplus ${CONNECT_SYS} @enblrtl.sql >> enblrtl.log
echo '*** enblrtl.sql stop' `date`  >>enbl.log

if [ "$1" == "force" ]
then
# Пересоздаем view
echo '*** crtcrit.sql start' `date` >>enbl.log
sqlplus ${IBS_TARGET} @crtcrit.sql >> crtcrit.log
echo '*** crtcrit.sql stop ' `date` >>enbl.log
fi

# Подключаем констрайнты
echo '*** enblcons.sql start' `date` >>enbl.log
sqlplus ${IBS_TARGET} @enblcons.sql >> enblcons.log
echo '*** enblcons.sql stop ' `date` >>enbl.log

# Поключаем внешние ключи (какие подключатся)
echo '*** enblref.sql start' `date` >>enbl.log
sqlplus ${IBS_TARGET} @enblref.sql > enblref.log
echo '*** enblref.sql stop ' `date` >>enbl.log

if [ "$1" == "force" ]
then
# Удаляем осиротевшие внешние ключи
echo '*** ../delorph/delorph.sh start' `date` >>enbl.log
cd ../delorph
$SHELL ./delorph.sh
cd ../stage3
echo '*** ../delorph/delorph.sh stop ' `date` >>enbl.log

# Поключаем внешние ключи (контрольный проход)
echo '*** enblref.sql start' `date` >>enbl.log
sqlplus ${IBS_TARGET} @enblref.sql > enblref.log
echo '*** enblref.sql stop ' `date` >>enbl.log
fi

# Подключаем триггеры
echo '*** enbltrig.sql start' `date` >>enbl.log
sqlplus ${IBS_TARGET} @enbltrig.sql >> enbltrig.log
echo '*** enbltrig.sql stop ' `date` >>enbl.log


echo '*** crtmview.sql start ' `date` >>enbl.log
#sqlplus ${IBS_TARGET} @crtmview.sql >> crtmview.log
echo '*** crtmview.sql stop  ' `date` >>enbl.log

