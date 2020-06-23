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


# Создание вспомогательных таблиц
echo '*** crttab.sql start' `date`     >>     prep.log
sqlplus ${IBS_SOURCE} @crttab.sql >>     crttab.log
echo '*** crttab.sql stop ' `date`     >>     prep.log

# Заполняем начальные условия 
echo '*** insroot.sql start' `date`     >>    prep.log
sqlplus ${IBS_SOURCE} @insroot.sql >>    insroot.log
echo '*** insroot.sql stop ' `date`     >>    prep.log

# Дополняем начальные условия 
echo '*** updroot.sql start' `date`     >>    prep.log
sqlplus ${IBS_SOURCE} @updroot.sql >>    updroot.log
echo '*** updroot.sql stop ' `date`     >>    prep.log

# Строим зависимости таблиц
echo '*** blddep.sql start' `date`     >>     prep.log
sqlplus ${IBS_SOURCE} @blddep.sql >>     blddep.log
echo '*** blddep.sql stop ' `date`     >>     prep.log

# Экспортируем вспомогательные таблицы
echo '*** exp redu tables start' `date` >> prep.log
exp ${IBS_SOURCE} TABLES=\(redu_tab,redu_dep,redu_root,redu_client\) FILE=redutab.dmp LOG=redutab.log 
echo '*** exp redu tables stop ' `date` >> prep.log

# Удаляем вспомогательные оьъекты базы
echo '*** remove.sql start' `date` 	   >>     prep.log
sqlplus ${IBS_SOURCE} @remove.sql >>     remove.log
echo '*** remove.sql stop ' `date` 	   >>     prep.log


