#!/bin/bash -
#title          :check_GFS.sh
#description    :Check if GFS data are available for synoptic plotting
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./check_GFS.sh
#notes          :Check if the count of GFS grib2 files for the current
#                initialisation time matches that required for generating
#                synoptic charts.
#bash_version   :4.2.46(2)-release
#============================================================================

# Path to synoptic plotting scripts
work_dir=/home/users/tdjames1/SWIFT-Testbed3/Synoptic
#work_dir=/gws/nopw/j04/swift/SWIFT-Testbed3/Synoptic

while true; do

    # get latest timestamp
    init=$(grep init $SWIFT_GFS/controls/namelist | cut -d':' -f2 | tr ',' '\n')
    echo $init

    for timestamp in ${init}
    do
	dir=$SWIFT_GFS/GFS_NWP/$timestamp

	if [ -d $dir ]; then
	    count_nc=$(ls $dir/*.nc 2>/dev/null | wc -l)
	    echo $count_nc
	    if [ $count_nc = 0 ]
	    then
		count_grib=$(ls $dir/*pgrb2* 2>/dev/null | wc -l)
		echo $count_grib
		if [ $count_grib = 25 ]
		then
		    # initiate workflow
		    echo "Time to initiate workflow"
		    $work_dir/synoptic_workflow.sh
		    wait
		else
		    echo "Waiting for grib files..."
		fi
	    fi
	else
	    echo "No dir called "$dir
	fi
    done
    sleep 10m
done
