#!/bin/bash
LOOP_SEC=$1
ADMIN_PASS=$2
LOADBALANCER_ADDR=$3
BW_LIMIT=$4

test -z $LOOP_SEC && exit;
test -z $ADMIN_PASS && exit;
test -z $LOADBALANCER_ADDR && exit;
test -z $BW_LIMIT && exit;

while true; do
    A_CPU=($( ./cpuload.sh $TOTALTICKS $IDLETICKS ))
    TOTALTICKS=${A_CPU[0]}
    IDLETICKS=${A_CPU[1]}
    CPULOAD=${A_CPU[2]}

    A_IO=($( ./ioload.sh $TOTALBYTES $TIMESTAMP ))
    TOTALBYTES=${A_IO[0]}
    TIMESTAMP=${A_IO[1]}
    IOLOAD=${A_IO[2]}

    MOUNT="$( ./mountpoints.sh)"

    if [ "x$CPULOAD" != "x" -a "x$IOLOAD" != "x" ]; then
#	    curl -o /dev/null --connect-timeout 1 --digest --user "admin:$ADMIN_PASS" -s "http://$LOADBALANCER_ADDR/update.php?mnt=$MOUNTPOINT_LIST&bw=$IOLOAD&bwl=$BW_LIMIT&load=$CPULOAD" 2>&1 > /dev/null
	    curl -o /dev/null --connect-timeout 1 --digest --user "admin:$ADMIN_PASS" -s "http://$LOADBALANCER_ADDR/update.php?mnt=$MOUNT&bw=$IOLOAD&bwl=$BW_LIMIT&load=$CPULOAD" 2>&1 > /dev/null
    fi
    sleep $LOOP_SEC
done

exit
