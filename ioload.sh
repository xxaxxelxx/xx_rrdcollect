#!/bin/bash
PROC=/host/proc/net/dev
test -r $PROC || exit
IOARRAY=($(cat $PROC | grep -w eth0:))
TRANSBYTES=${IOARRAY[9]}
#TRANSBYTES=${IOARRAY[1]}
NOWSEC=$(date +%s)
RESULT="$TRANSBYTES $NOWSEC"

test $# -eq 0 && echo "$RESULT" && exit
TOTALBYTESDIFF=$[ $TRANSBYTES - $1 ]

if [ $TOTALBYTESDIFF -lt 0 ]; then echo $RESULT; exit; fi
TOTALSECDIFF=$[ $NOWSEC - $2 ]

BYTESPS=$[ $TOTALBYTESDIFF / $TOTALSECDIFF ]
KBPS=$[ $BYTESPS * 8 / 1000 ]
echo "$RESULT $KBPS"

exit
