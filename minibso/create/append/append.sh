#!/bin/sh
#set -x

usage(){
	echo "Usage: ./append.sh p[c][a] prep|exp|imp|all [<obj_id> [<obj_id>]] ..."
}

if [ `expr match "$1" "[pP][cCAa]*" ` -eq 0 ]
then 
	usage
	exit -1
fi	

if [ `expr index "#prep#exp#imp#all#" "$2"` -eq 0 ]
then 
	usage
	exit -1
fi	

# DO NOT WORK when in DATA directory exists dump files
for FIL in ../data/*.dmp; do
if [ -e $FIL ] 
then 
	if [ "$2" == "exp" ] || [ "$2" == "all" ]
	then
		echo "In DATA directory exists dump files."
		exit -2
	fi	
fi	
done

# detect Cygwin
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac

if $cygwin; then
. ../exp/profile.win
else
. ../exp/profile.lin
fi

if [ "$2" == "prep" ] || [ "$2" == "all" ] 
then
# find init object
echo '*** initlst.sh start' `date`     >> append.log
$SHELL ./initlst.sh $*
echo '*** initlst.sh stop' `date`     >> append.log

if [ `expr match "$1" ".*[Aa].*" ` -gt 0 ] 
then
echo '*** find coll start' `date`     	>> append.log
sqlplus ${CONNECT_IBS} @addcoll.sql 	>> append.log
echo '*** find coll stop ' `date`     	>> append.log
fi

if [ `expr match "$1" ".*[Cc].*" ` -gt 0 ] 
then
echo '*** find child start' `date`     	>> append.log
sqlplus ${CONNECT_IBS} @addchild.sql 	>> append.log
echo '*** find child stop ' `date`     	>> append.log
fi

echo '*** find parent start' `date`     >> append.log
sqlplus ${CONNECT_IBS} @addparent.sql 	>> append.log
echo '*** find parent stop ' `date`     >> append.log

fi

if [ "$2" == "exp" ] || [ "$2" == "all" ] 
then
# export rows 
echo '*** exp.sh start' `date`     >> append.log
cd ../exp/append
$SHELL ./exp.sh
cd ../../append
echo '*** exp.sh stop' `date`     >> append.log
fi

if [ "$2" == "imp" ] || [ "$2" == "all" ] 
then
# import redu_add into target
echo '*** impaddtab.sh start '  `date`     >> append.log
cd ../imp/append
$SHELL ./impaddtab.sh
cd ../../append
echo '*** impaddtab.sh stop'   `date`     >> append.log

# disable constraints
echo '*** ../discons start' `date` 				>> append.log
cd ../imp/discons
$SHELL ./dismisc.sh
$SHELL ./disfk.sh lst
cd ../../append
echo '*** ../discons stop ' `date` 				>> append.log

# delete object from taget
echo '*** targdel.sh start' `date`     >> append.log
$SHELL ./targdel.sh
echo '*** targdel.sh stop' `date`     >> append.log

# import dumps into target
echo '*** imptab.sh start' `date`     >> append.log
cd ../imp/imptab
$SHELL ./imptab.sh
cd ../../append
echo '*** imptab.sh stop' `date`     >> append.log

# enable constarints
echo '*** enbl.sh start' `date`     >> append.log
cd ../imp/stage3
$SHELL ./enbl.sh
cd ../../append
echo '*** enbl.sh stop' `date`     >> append.log
fi

exit 0


