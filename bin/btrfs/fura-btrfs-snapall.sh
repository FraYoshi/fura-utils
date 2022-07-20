#!/bin/bash -

export snapList=~/.config/furayoshi/btrfs/snaplist
export date=$(date +\"%Y%m%d-%H%M\")

function getSnap_name () {
    awk '{print $1}'
}

function getSnap_path () {
    awk '{print $2}'
}

function getSnap_save () {
    awk '{print $4}' $snapList
}

function getSnap_receive () {
    awk '{print $4}' $snapList
}

function snap_create () {
    echo -n $line | awk 'BEGIN {ORS=""} {print $2,$3 $1}' && \
	awk -v date="`date +\"%Y%m%d-%H%M\"`" 'BEGIN {print"-"date}'
}

# for subv in $(getSnap_); do
#     btrfs subvolume snapshot -r $subv ;
# done

## TEST ZONE

while read line; do
    snap_create && echo $EOL;
done < $snapList

# while read line; do
#     echo $line | awk '{print $1,$2}' && echo "$EOL";
# done < $snapList
