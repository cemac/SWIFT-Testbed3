#!/bin/bash -
#title          :get_data.sh
#description    :Get GFS data
#author         :CEMAC - Tamora James
#date           :20210809
#version        :0.1
#usage          :./get_data.sh
#notes          :Script to be invoked by cron to download GFS data
#bash_version   :4.2.46(2)-release
#============================================================================

SWIFT_GWS=/gws/nopw/j04/swift
TMPDIR=$SWIFT_GWS/eartdj/tmp
SWIFT_TB3=$SWIFT_GWS/SWIFT-Testbed3
SWIFT_GFS=$SWIFT_GWS/eartdj/SWIFT_GFS
SWIFT_GFS_PLOTTING=$SWIFT_TB3/Nowcasting/GFS_plotting
#TOOLS_DIR=$SWIFT_TB3/Synoptic
TOOLS_DIR=/home/users/tdjames1/SWIFT-Testbed3/Synoptic

# Update namelist to get latest initialisation time
$SWIFT_GFS_PLOTTING/scripts/automation/edit_namelist.sh $SWIFT_GFS

# Batch processing is too laggy...
#sbatch -o $TMPDIR/%j.out -e $TMPDIR/%j.err $WORKDIR/get_GFS_batch.sh

# ...so calling script to download GFS data directly
$TOOLS_DIR/get_GFS_batch.sh 3 > $TMPDIR/get_GFS_batch.out
