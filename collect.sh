#!/bin/bash
LB_HOST=$1
RRD_LOOP=$2
CUSTOMER=$3
test -z $LB_HOST && exit;
test -z $RRD_LOOP && exit;
test -z $CUSTOMER && exit;

while true; do
    OIFS=$IFS; IFS=$'\n'; A_MOUNTPOINTS=($(curl --connect-timeout 3 -s "http://$LB_HOST/listmountpoints.php?mnt=$CUSTOMER")); IFS=$OIFS
    for C_MNT in ${A_MOUNTPOINTS[@]}; do
	C_VALUE=$(curl --connect-timeout 3 -s "http://$LB_HOST/listeners.php?mnt=$C_MNT")
	echo "$C_MNT is $C_VALUE"
    done
    sleep $RRD_LOOP
done

exit



