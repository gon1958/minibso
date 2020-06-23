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

# Запрещаем задания
echo '*** setjob.sql start' `date` >>imp.log
sqlplus ${CONNECT_SYS} @setjob.sql > setjob.log
echo '*** setjob.sql stop ' `date` >>imp.log

# Импортируем схему
echo '*** imp scheme start' `date` >>imp.log
imp ${IBS_TARGET} FILE="${DATA_PATH}IBSSHM.EXP" LOG="${DATA_PATH}IBSSHM.ILOG" FROMUSER=\(IBS\) TOUSER=\(IBS\) GRANTS=N COMPILE=N BUFFER=2000000 IGNORE=Y 
echo '*** imp scheme stop ' `date` >>imp.log

# Убираем все mview
echo '*** rmmview.sql start' `date` >>imp.log
sqlplus ${IBS_TARGET} @rmmview.sql > rmmview.log
echo '*** rmmview.sql stop ' `date` >>imp.log

# Убираем все job
echo '*** rmjob.sql start' `date` >>imp.log
sqlplus ${IBS_TARGET} @rmjob.sql > rmjob.log
echo '*** rmjob.sql stop ' `date` >>imp.log

# Меняем пароль владельца
echo '*** pwdset.sql start' `date` >>imp.log
sqlplus ${CONNECT_SYS} @pwdset.sql > pwdset.log
echo '*** pwdset.sql stop ' `date` >>imp.log

# Отключаем констрайнты кроме PK
echo '*** ../discons start' `date` >>imp.log
cd ../discons
$SHELL ./dismisc.sh
$SHELL ./disfk.sh
cd ../stage1
echo '*** ../discons stop ' `date` >>imp.log

# Импорт таблиц
echo '*** ../imptab/imptab.sh start' `date`>>imp.log
cd ../imptab
$SHELL ./imptab.sh 
cd ../stage1
echo '*** ../imptab/imptab.sh stop ' `date`>>imp.log

# Импорт статических объектов
echo '*** ../impstat/impstat.sh start' `date`>>imp.log
cd ../impstat
$SHELL ./impstat.sh
cd ../stage1
echo '*** ../impstat/impstat.sh stop ' `date`>>imp.log

# Отключаем констрайнты PK и UQ
echo '*** ../discons start' `date` >>imp.log
cd ../discons
$SHELL ./disprim.sh
cd ../stage1
echo '*** ../discons stop ' `date` >>imp.log

# Собираем статистику
echo '*** gatstat.sql start' `date` >>imp.log
#sqlplus ${CONNECT_SYS} @gatstat.sql >> gatstat.log
echo '*** gatstat.sql stop ' `date` >>imp.log

# Удаляем вспомогательные объекты 
echo '*** remove.sql start' `date` >>imp.log
sqlplus ${IBS_TARGET} @remove.sql >> remove.log
echo '*** remove.sql stop ' `date` >>imp.log



