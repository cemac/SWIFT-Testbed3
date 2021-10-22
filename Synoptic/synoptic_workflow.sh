#!/bin/bash -
#title          :synoptic_workflow.sh
#description    :Synoptic chart generation workflow
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./synoptic_workflow.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

# Path to synoptic plotting scripts
work_dir=/home/users/tdjames1/SWIFT-Testbed3/Synoptic
#work_dir=/gws/nopw/j04/swift/SWIFT-Testbed3/Synoptic

# convert grib to netcdf and combine forecast data
$work_dir/preprocess_GFS.sh > $TMPDIR/preprocess_GFS.out 2>&1

# generate charts
$work_dir/generate_charts.sh > $TMPDIR/generate_charts.out 2>&1

# produce PPTs
$work_dir/generate_ppt.sh > $TMPDIR/generate_ppt.out 2>&1
