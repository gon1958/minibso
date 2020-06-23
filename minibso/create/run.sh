#!/bin/sh
# Полный прогон всех скриптов
oraprep() {
# Подготовка скриптов
echo '*** ./exp/prepare/prep.sh start' `date`     >> run.log
cd ./exp/prepare
$SHELL ./prep.sh
cd ../..
cp ./exp/prepare/redutab.dmp ./exp/generate
cp ./exp/prepare/redutab.dmp ./exp/estmsize
cp ./exp/prepare/redutab.dmp ./exp/tables
echo '*** ./exp/prepare/prep.sh stop' `date`     >> run.log

#Подготовка информации
echo '*** ./exp/generate/gen.sh start' `date`     >> run.log
cd ./exp/generate
$SHELL ./gen.sh
cd ../..
cp ./exp/generate/exptab*.scr ./exp/tables
cp ./exp/generate/expstat.scr ./exp/tables
cp ./exp/generate/exptab.viw ./exp/tables
cp ./exp/generate/exptab.viw ./exp/estmsize
echo '*** ./exp/generate/gen.sh stop' `date`     >> run.log
}

oraexp() {
# Экспорт схемы и параллельно...
echo '*** ./exp/scheme/exp.sh start' `date`     >> run.log
cd ./exp/scheme
($SHELL ./exp.sh) &
cd ../..

# Экспорт таблиц
echo '*** ./exp/tables/exp.sh start' `date`     >> run.log
cd ./exp/tables
$SHELL ./exp.sh
cd ../..

wait 
echo '*** ./exp/scheme/exp.sh stop' `date`     >> run.log
echo '*** ./exp/tables/exp.sh stop' `date`     >> run.log
}

oraimp() {
# Все этапы импорта последовательно
echo '*** ./imp/stage1/imp.sh start' `date`     >> run.log
cd ./imp/stage1
$SHELL ./imp.sh
cd ../..
echo '*** ./imp/stage1/imp.sh stop' `date`     >> run.log
}

oraunion() {
# Разные доделки и подключаем констрайнты
echo '*** ./imp/stage2/union.sh start' `date`     >> run.log
cd ./imp/stage2
$SHELL ./union.sh
cd ../..
echo '*** ./imp/stage2/union.sh stop' `date`     >> run.log

echo '*** ./imp/stage3/enbl.sh start' `date`     >> run.log
cd ./imp/stage3
$SHELL ./enbl.sh force
cd ../..
echo '*** ./imp/stage3/enbl.sh stop' `date`     >> run.log
}

if [ "$#" -eq 0 ] 
then
echo "Usage: run.sh prep|exp|imp|union|all"
exit 1
fi

if [ "$1" == "prep" ] || [ "$1" == "all" ] 
then
echo "run oraprep"
oraprep
fi

if [ "$1" == "exp" ] || [ "$1" == "all" ] 
then
echo "run oraexp"
oraexp
fi
 
if [ "$1" == "imp" ] || [ "$1" == "all" ] 
then
echo "run oraimp"
oraimp
fi

if [ "$1" == "union" ] || [ "$1" == "all" ] 
then
echo "run oraunion"
oraunion
fi

# detect Cygwin
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac


if [ "$1" == "all" ] 
then
echo "run shutdown "
cd ./imp/stage3
$SHELL ./shutdown.sh
cd ../..
if $cygwin; then
shutdown -f -s 0
else
#poweroff
ls
fi
fi

