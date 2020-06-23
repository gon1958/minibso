#!/bin/sh
shift
shift
if [ -z "$1" ]
then 
	exit -1
fi	

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

if [ ! -z "$1" ]
then 
	sqlplus ${CONNECT_IBS} @lstdrop.sql >> initlst.log
fi

sqlplus ${CONNECT_IBS} @lstinit.sql >> initlst.log

echo '*** initlst start' `date`     >> initlst.log
until [ -z "$1" ]
do
	echo 'process obj='$1
	echo 'def start_obj='$1 > objectid.start
	sqlplus ${CONNECT_IBS} @lstfill.sql >> initlst.log
	shift
done
echo '*** initlst stop ' `date`     >> initlst.log


