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

# ����������� ��������������� �������
echo '*** imp redu tables start' `date` >> gen.log
imp ${IBS_SOURCE} FILE=redutab.dmp LOG=redutab.log 
echo '*** imp redu tables stop ' `date` >> gen.log

echo '*** genwhere.sql start' `date`     >> gen.log
sqlplus ${IBS_SOURCE} @genwhere.sql >> genwhere.log
echo '*** genwhere.sql stop ' `date`     >> gen.log

echo '*** symsubst.sql start' `date`     >> gen.log
sqlplus ${IBS_SOURCE} @symsubst.sql >> symsubst.log
echo '*** symsubst.sql stop ' `date`     >> gen.log

# ��������� �������� �������� ������
echo '*** exptab.sql start' `date` >>   gen.log
sqlplus ${IBS_SOURCE} @exptab.sql >>   exptab.log
echo '*** exptab.sql stop ' `date` >>   gen.log

# ��������� �������� ��� �������� ����������� �����������
echo '*** expstat.sql start' `date` >>  gen.log
sqlplus ${IBS_SOURCE} @expstat.sql >>  expstat.log
echo '*** expstat.sql stop ' `date` >>  gen.log

# ������� ��������������� ������� ����
echo '*** remove.sql start' `date` 	   >>   gen.log
sqlplus ${IBS_SOURCE} @remove.sql >>   remove.log
echo '*** remove.sql stop ' `date` 	   >>   gen.log

