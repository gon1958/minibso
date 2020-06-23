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

# импортируем вспомогательные таблицы
echo '*** imp redu tables start' `date` >> exp.log
imp ${IBS_SOURCE} FILE=redutab.dmp LOG=redutab.log 
echo '*** imp redu tables stop ' `date` >> exp.log

# Генерация представлений подможества данных
echo '*** exptab.viw start' `date` >>  exp.log
sqlplus ${IBS_SOURCE} @exptab.viw >>  exptab.log
echo '*** exptab.viw stop ' `date` >>  exp.log

# Выгрузка данных в три потока
echo '*** exptab1.scr start' `date` >>exp.log
$SHELL ./exptab1.scr  #&
echo '*** exptab1.scr stop ' `date` >>exp.log

echo '*** exptab2.scr start' `date` >>exp.log
$SHELL ./exptab2.scr  #&
echo '*** exptab2.scr stop ' `date` >>exp.log

echo '*** exptab3.scr start' `date` >>exp.log
$SHELL ./exptab3.scr 
echo '*** exptab3.scr stop ' `date` >>exp.log
wait

# Выгрузка статических экземпляров
echo '*** expstat.scr start' `date` >>exp.log
$SHELL ./expstat.scr 
echo '*** expstat.scr stop ' `date` >>exp.log

# Удаляем вспомогательные объекты базы
echo '*** remove.sql start' `date` >>exp.log
sqlplus ${IBS_SOURCE} @remove.sql >> remove.log
echo '*** remove.sql stop ' `date` >>exp.log


