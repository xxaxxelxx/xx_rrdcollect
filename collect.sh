#!/bin/bash
LB_HOST=$1
RRD_LOOP=$2
CUSTOMER=$3
FAILTIMEOUT=10
test -z $LB_HOST && exit;
test -z $RRD_LOOP && exit;
test -z $CUSTOMER && exit;

if [ "x$CUSTOMER" == "xadmin" ]; then
    while true; do
	A_MACHINES=""; SLEEP=$(( $RRD_LOOP + $FAILTIMEOUT ))
	while [ "x${A_MACHINES[0]}" == "x" ]; do
	    OIFS=$IFS; IFS=$'\n'; A_MACHINES=($(curl --connect-timeout $FAILTIMEOUT --max-time $FAILTIMEOUT -s "http://$LB_HOST/listmachines.php")); IFS=$OIFS
	    SLEEP=$(( $SLEEP - $FAILTIMEOUT ))
	    if [ $SLEEP -le $FAILTIMEOUT ]; then break; fi
	    sleep $FAILTIMEOUT
	done
	if [ "x${A_MACHINES[0]}" == "x" ]; then continue; fi
	C_LIST_SUM=0; C_BW_SUM=0
	for MACHINE in ${A_MACHINES[@]}; do
	    OIFS=$IFS; IFS='|'; A_MACHINE_DATA=($(echo "$MACHINE")); IFS=$OIFS
	    IP=${A_MACHINE_DATA[0]}
	    C_IP=$(echo $IP | sed 's|\.|\-|g')
	    C_BW=${A_MACHINE_DATA[1]}
	    C_BWLIMIT=${A_MACHINE_DATA[2]}
	    C_LOAD=${A_MACHINE_DATA[3]}
	    C_LOADLIMIT=${A_MACHINE_DATA[4]}
	    C_LIST_SUM=$((${A_MACHINE_DATA[5]} + $C_LIST_SUM))
	    C_BW_SUM=$(($C_BW + $C_BW_SUM))
	    RRDFILE="/customer/$CUSTOMER/_$C_IP.rrd"
#
test -f $RRDFILE.old
if [ $? -ne 0 ]; then
    mv $RRDFILE $RRDFILE.old
fi 
#
	    test -f $RRDFILE || (
		ITEMS_DAY=$(( $((2 * 24 * 60 * 60)) / $(( $RRD_LOOP * 1 )) ))
		ITEMS_WEEK=$(( $((8 * 24 * 60 * 60)) / $(( $RRD_LOOP * 4 )) ))
		ITEMS_MONTH=$(( $((36 * 24 * 60 * 60)) / $(( $RRD_LOOP * 12 )) ))
		ITEMS_YEAR=$(( $((366 * 24 * 60 * 60)) / $(( $RRD_LOOP * 100 )) ))
		rrdtool create $RRDFILE \
		--step $RRD_LOOP \
		DS:bw:GAUGE:$(($RRD_LOOP*2)):U:U \
		DS:bwlimit:GAUGE:$(($RRD_LOOP*2)):U:U \
		DS:cpuload:GAUGE:$(($RRD_LOOP*2)):U:U \
		DS:cpuloadlimit:GAUGE:$(($RRD_LOOP*2)):U:U \
		RRA:MAX:0.5:1:$ITEMS_DAY \
		RRA:MAX:0.5:4:$ITEMS_WEEK \
		RRA:MAX:0.5:12:$ITEMS_MONTH \
		RRA:MAX:0.5:100:$ITEMS_YEAR
	    )
	    rrdtool update $RRDFILE N:$C_BW:$C_BWLIMIT:$C_LOAD:$C_LOADLIMIT
	done
	ALL_RRDFILE="/customer/$CUSTOMER/_ALL.rrd"
	test -f $ALL_RRDFILE || (
		ITEMS_DAY=$(( $((2 * 24 * 60 * 60)) / $(( $RRD_LOOP * 1 )) ))
		ITEMS_WEEK=$(( $((8 * 24 * 60 * 60)) / $(( $RRD_LOOP * 4 )) ))
		ITEMS_MONTH=$(( $((36 * 24 * 60 * 60)) / $(( $RRD_LOOP * 12 )) ))
		ITEMS_YEAR=$(( $((366 * 24 * 60 * 60)) / $(( $RRD_LOOP * 100 )) ))
		rrdtool create $ALL_RRDFILE \
		--step $RRD_LOOP \
		DS:bw:GAUGE:$(($RRD_LOOP*2)):U:U \
		DS:listeners:GAUGE:$(($RRD_LOOP*2)):U:U \
		RRA:MAX:0.5:1:$ITEMS_DAY \
		RRA:MAX:0.5:4:$ITEMS_WEEK \
		RRA:MAX:0.5:12:$ITEMS_MONTH \
		RRA:MAX:0.5:100:$ITEMS_YEAR
	)
	rrdtool update $ALL_RRDFILE N:$C_BW_SUM:$C_LIST_SUM
	sleep $SLEEP
    done
else
    while true; do
	A_MOUNTPOINTS=""; SLEEP=$(( $RRD_LOOP + $FAILTIMEOUT ))
	while [ "x${A_MOUNTPOINTS[0]}" == "x" ]; do
	    OIFS=$IFS; IFS=$'\n'; A_MOUNTPOINTS=($(curl --connect-timeout $FAILTIMEOUT --max-time $FAILTIMEOUT -s "http://$LB_HOST/listmountpointlisteners.php?mnt=$CUSTOMER")); IFS=$OIFS
	    SLEEP=$(( $SLEEP - $FAILTIMEOUT ))
	    if [ $SLEEP -le $FAILTIMEOUT ]; then break; fi
	    sleep $FAILTIMEOUT
	done
	if [ "x${A_MOUNTPOINTS[0]}" == "x" ]; then continue; fi
	for LISTMNT in ${A_MOUNTPOINTS[@]}; do
	    OIFS=$IFS; IFS=$'@'; A_ELEM=($(echo "$LISTMNT")); IFS=$OIFS
	    LIST=${A_ELEM[0]}
	    MNT=${A_ELEM[1]}
	    STRIPPED_MNT=$(echo $MNT | sed 's|^/||')
	    C_VALUE=$LIST
	    C_MNT=$(echo $MNT | sed 's|^/||' | sed 's|\.|\_|g')
	    RRDFILE="/customer/$CUSTOMER/_$C_MNT.rrd"
	    test -f $RRDFILE || (
		ITEMS_DAY=$(( $((2 * 24 * 60 * 60)) / $(( $RRD_LOOP * 1 )) ))
		ITEMS_WEEK=$(( $((8 * 24 * 60 * 60)) / $(( $RRD_LOOP * 4 )) ))
		ITEMS_MONTH=$(( $((36 * 24 * 60 * 60)) / $(( $RRD_LOOP * 12 )) ))
		ITEMS_YEAR=$(( $((366 * 24 * 60 * 60)) / $(( $RRD_LOOP * 100 )) ))
		rrdtool create $RRDFILE \
		--step $RRD_LOOP \
		DS:${C_MNT:0:19}:GAUGE:$(($RRD_LOOP*2)):U:U \
		RRA:MAX:0.5:1:$ITEMS_DAY \
		RRA:MAX:0.5:4:$ITEMS_WEEK \
		RRA:MAX:0.5:12:$ITEMS_MONTH \
		RRA:MAX:0.5:100:$ITEMS_YEAR
	    )
	    rrdtool update $RRDFILE N:$C_VALUE
	done
	sleep $SLEEP
    done
fi
exit



