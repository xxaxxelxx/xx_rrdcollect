#!/bin/bash
PROC=/host/proc/stat
test -r $PROC || exit
CPUARRAY=($(cat $PROC | grep -w cpu))
TOTALTICKS=$[ ${CPUARRAY[1]} + ${CPUARRAY[2]} + ${CPUARRAY[3]} + ${CPUARRAY[4]} + ${CPUARRAY[5]} + ${CPUARRAY[6]} + ${CPUARRAY[7]} + ${CPUARRAY[8]} ]
IDLETICKS=$[ ${CPUARRAY[4]} + ${CPUARRAY[5]} ]
RESULT="$TOTALTICKS $IDLETICKS"

test $# -eq 0 && echo $RESULT && exit

TOTALTICKSDIFF=$[ $TOTALTICKS - $1 ]
IDLETICKSDIFF=$[ $IDLETICKS - $2 ]
if [ $TOTALTICKSDIFF -lt 0 -o  $IDLETICKSDIFF -lt 0 ]; then echo $RESULT; exit; fi

echo "$RESULT $[ 100 - $[ $IDLETICKSDIFF * 100 / $TOTALTICKSDIFF ] ]"

exit
