#!/bin/bash -
#title          :preprocess_GFS.sh
#description    :Preprocess GFS data
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./preprocess_GFS.sh [YYYYMMDDHH]
#notes          :Convert GFS data from grib2 to NetCDF4 and combine forecast
#                data.  If an initialisation time is specified, the files for
#                this timestamp are processed, otherwise the initialisation
#                time is taken from ${SWIFT_GFS}/controls/namelist.
#bash_version   :4.2.46(2)-release
#============================================================================

# Path to synoptic plotting scripts
work_dir=/home/users/tdjames1/SWIFT-Testbed3/Synoptic
#work_dir=/gws/nopw/j04/swift/SWIFT-Testbed3/Synoptic

# Path to control file
namelist=${SWIFT_GFS}/controls/namelist

# Set initialisation time (timestamp) from command line or namelist
INIT=${1:-$(cat ${namelist} | grep "init:" | awk -F: '{print $2}' | tr ',' ' ')}

# Set forecast terms (hours) from namelist
FORE_TERMS="000 "$(cat ${namelist} | grep "fore:" | awk -F: '{print $2}' | tr ',' ' ')

# Number of jobs to initiate
N=6
for timestamp in ${INIT}
do
    for f in ${FORE_TERMS}
    do
	((i=i%N)); ((i++==0)) && wait
	# Convert from grib to netcdf
	$work_dir/convert_grib2nc.sh ${timestamp} ${f} &
    done
    wait
    # Combine the GFS forecast data
    $work_dir/combine_forecast_data.sh ${timestamp}
done
