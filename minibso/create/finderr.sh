#!/bin/sh
grep -i ORA- ./data/*.elog>finderr.exp
grep -i EXP- ./data/*.elog>>finderr.exp
grep -i ORA- ./exp/prepare/*.log>>finderr.exp
grep -i ORA- ./exp/generate/*.log>>finderr.exp

grep -i ORA- ./data/*.ilog>finderr.imp
grep -i IMP- ./data/*.ilog>>finderr.imp
grep -i ORA- ./imp/stage1/*.err>>finderr.imp
grep -i IMP- ./imp/stage1/*.err>>finderr.imp
grep -i ORA- ./imp/stage1/*.log>>finderr.imp
grep -i IMP- ./imp/stage1/*.log>>finderr.imp
grep -i ORA- ./imp/stage3/*.err>>finderr.imp
grep -i IMP- ./imp/stage3/*.err>>finderr.imp
grep -i ORA- ./imp/stage3/*.log>>finderr.imp
grep -i IMP- ./imp/stage3/*.log>>finderr.imp

echo "*** Export error's:" > finderr.all
awk '{a[$0]++}END{for(i in a){print a[i],i}}' finderr.exp | grep -i -v -e 'ORA-00001' >> finderr.all
echo " " >> finderr.all
echo "*** Import error's:" >> finderr.all
awk '{a[$0]++}END{for(i in a){print a[i],i}}' finderr.imp | grep -i -v -e 'ORA-00001\|IMP-00041\|IMP-00003\|IMP-00019' >> finderr.all
cat finderr.all

