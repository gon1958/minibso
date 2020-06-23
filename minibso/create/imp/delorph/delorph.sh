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

# Подготовка к удалению осиротевших ключей
echo '*** dobld.sql start' `date` >>delorph.log
sqlplus ${IBS_TARGET} @dobld.sql > dobld.log
echo '*** dobld.sql stop ' `date` >>delorph.log


# Удаляем осиротевшие внешние ключи
echo '**********************' >> dorun.log
echo '*** dorun.sql start' `date` >> delorph.log
while true
do
  sqlplus ${IBS_TARGET} @dorun.sql >> dorun.err
  if [ $? -eq 0 ] 
  then
	break
  fi
done
echo '*** dorun.sql stop ' `date` >> delorph.log

