#!/bin/sh
# Удаление информации от предыдущих запусков

del_data() {
rm -f ./data/*
}

del_log() {
rm -f ./exp/generate/exptab.viw
rm -f ./exp/generate/redutab.dmp
rm -f ./exp/prepare/redutab.dmp
rm -f ./exp/tables/exptab.viw
rm -f ./exp/estmsize/exptab.viw
rm -f ./exp/estmsize/redustat.dmp
rm -f ./exp/estmsize/redutab.dmp

find . -name '*.err' -exec rm -f {} \;
find . -name '*.scr' -exec rm -f {} \;
find . -name '*.log' -exec rm -f {} \;
}

if [ "$#" -eq 0 ]
then
echo "Usage: del.sh data|logs|all"
exit 1
fi

if [ "$1" == "data" ] || [ "$1" == "all" ]
then
echo "delete data"
del_data
fi

if [ "$1" == "logs" ] || [ "$1" == "all" ]
then
echo "delete logs"
del_log
fi

