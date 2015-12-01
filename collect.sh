#!/bin/bash
LB_HOST=$1
RRD_LOOP=$2
CUSTOMER=$3
test -z $LB_HOST && exit;
test -z $RRD_LOOP && exit;
test -z $CUSTOMER && exit;

while true; do
    curl -o /dev/null --connect-timeout 3 -s "http://$LOADBALANCER_ADDR/listeners.php?mnt=$CUSTOMER" 2>&1 > /dev/null
    sleep $RRD_LOOP
done

exit
