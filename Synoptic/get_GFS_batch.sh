#!/bin/bash -
#title          :get_GFS_batch.sh
#description    :Get GFS data from NOAA via HTTP
#author         :CEMAC - Tamora James
#date           :20210818
#version        :0.1
#usage          :./get_GFS_batch.sh <MAX_TRIES>
#notes          :Reads initialisation time(s) and forecast terms from
#                ${SWIFT_GFS}/controls/namelist and retrieves specified
#                files from NOAA via HTTP.
#                Includes sbatch directives to allow script to be called
#                on batch computing nodes from the cron.jasmin.ac.uk server.
#bash_version   :4.2.46(2)-release
#============================================================================

#SBATCH --partition=short-serial
#SBATCH --time=03:30

# Set maximum number of tries from command line or use default value
MAX_TRIES=${1:-3}

# Base URL for retrieval of GFS data via HTTP
BASE_URL="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"

# Path to control file
namelist=${SWIFT_GFS}/controls/namelist

# Initialisation time (timestamp), forecast terms (hours) and model
# resolution (degrees)
INIT=$(cat ${namelist} | grep "init:" | awk -F: '{print $2}' | tr ',' ' ')
FORE_TERMS="000 "$(cat ${namelist} | grep "fore:" | awk -F: '{print $2}' | tr ',' ' ')
RESOL=0p50

for timestamp in ${INIT}
do
    YYYYMMDD=$(echo ${timestamp} | cut -c1-8)
    HH=$(echo ${timestamp} | cut -c9-10)

    # set up directory structure for downloaded files
    mkdir -p ${SWIFT_GFS}/GFS_NWP/${YYYYMMDD}${HH}
    cd ${SWIFT_GFS}/GFS_NWP/${YYYYMMDD}${HH}

    # URL for this initialisation time
    INIT_URL=${BASE_URL}/gfs.${YYYYMMDD}/${HH}/atmos

    i=0
    while [ $i -lt $MAX_TRIES ]
    do
	# build list of files that have not been retrieved yet
	FILES=""
	for f in ${FORE_TERMS}
	do
	    if ! [[ -f gfs.t${HH}z.pgrb2.${RESOL}.f${f} ]]
	    then
		FILES+=" ${INIT_URL}/gfs.t${HH}z.pgrb2.${RESOL}.f${f}"
	    fi
	done

	if [[ -n ${FILES} ]]
	then
	    # retrieve files
	    wget ${FILES}

	    rtn=$?
	    if [ $rtn -ne 0 ]
	    then
		echo "wget had non-zero exit status $rtn, retrying"
	    else
		# done
		break
	    fi
	else
	    # nothing to do
	    break
	fi

	sleep 5m
	(( i++ ))
    done
done
