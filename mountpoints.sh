#!/bin/bash

MOUNTSTATFILE="/dev/shm/mountstat.xml"

$(which curl) --user "admin:$IC_ADMIN_PASS" -s http://$IC_HOST:$IC_PORT/admin/listmounts > $MOUNTSTATFILE
#$(which curl) --user "admin:lalalala1" -s http://192.168.90.29:80/admin/listmounts > $MOUNTSTATFILE

test -r $MOUNTSTATFILE
if [ $? -eq 0 ]; then
    A_MOUNTS=($(xmllint --xpath "//icestats/source/@mount" $MOUNTSTATFILE ))
    for CMOUNT in "${A_MOUNTS[@]}"; do 
		CSTRING="//icestats/source[@$CMOUNT]"
	xmllint --xpath "//icestats/source[@$CMOUNT]" $MOUNTSTATFILE | grep -i connected | grep -v _master > /dev/null
	if [ $? -eq 0 ]; then
	    CLISTENERS=$(xmllint --xpath "//icestats/source[@$CMOUNT]/listeners" $MOUNTSTATFILE | sed 's|<[^>]*.||g')
	    eval $CMOUNT; XMOUNT="$mount"
	    test -z $RETURN
	    if [ $? -eq 0 ]; then
		RETURN="$CLISTENERS@$XMOUNT"
	    else
		RETURN="$RETURN|$CLISTENERS@$XMOUNT"
	    fi
	fi
    done
fi
test -r $MOUNTSTATFILE && rm -f $MOUNTSTATFILE
echo $RETURN
exit
