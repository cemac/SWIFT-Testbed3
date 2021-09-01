#!/bin/bash -
#title          :combine_forecast_data.sh
#description    :Combine GFS forecast data
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./combine_forecast_data.sh <YYYYMMDDHH>
#notes          :Convert GFS forecast data.  Script based on GFS plotting
#                code developed by Alexander Roberts, University of Leeds.
#bash_version   :4.2.46(2)-release
#============================================================================

if [ "$#" -ne  "1" ]
then
    echo "Usage:    combine_forecast_data.sh <YYYYMMDDHH>"
    exit
fi

INIT_TIME=$1
YYYY=$(echo ${INIT_TIME} | cut -c1-4)
MM=$(echo ${INIT_TIME} | cut -c5-6)
DD=$(echo ${INIT_TIME} | cut -c7-8)
HH=$(echo ${INIT_TIME} | cut -c9-10)
echo ${YYYY}${MM}${DD}${HH}

cd ${SWIFT_GFS}/GFS_NWP/${YYYY}${MM}${DD}${HH}

module load jaspy

# concatenate forecast data
cdo cat new_gfs*.nc GFS_forecast_${YYYY}${MM}${DD}_${HH}.nc
rm new_gfs.t*.nc
