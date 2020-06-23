#!/bin/sh
# Проверка комплекта необходимых команд
# detect Cygwin
cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac


C_NAME=
C_FILE=

com_exists ()
{
C_FILE=`which $C_NAME 2> /dev/null`
TEST_RES="NOT found"
if [ -e "$C_FILE" ]
then
	TEST_RES="found"
fi
echo "$C_NAME $TEST_RES"
}

echo "*** test exp profile:"
if $cygwin; then
. ./exp/profile.win
else
. ./exp/profile.lin
fi


C_NAME=sqlplus
com_exists

C_NAME=exp
com_exists

C_NAME=imp
com_exists

C_NAME=cygpath
com_exists

C_NAME=find
com_exists


echo "*** test imp profile:"
if $cygwin; then
. ./imp/profile.win
else
. ./imp/profile.lin
fi

C_NAME=sqlplus
com_exists

C_NAME=exp
com_exists

C_NAME=imp
com_exists

C_NAME=cygpath
com_exists

C_NAME=find
com_exists

