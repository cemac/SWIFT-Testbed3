#!/bin/bash -
#title          :generate_charts.sh
#description    :Generate synoptic charts
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./generate_charts.sh [YYYYMMDDHH]
#notes          :Generate synoptic charts for specified initialisation
#                time(s), forecast time(s) and domain(s).
#                If an initialisation time is specified, charts for this
#                timestamp are generated, otherwise the initialisation
#                time is taken from ${SWIFT_GFS}/controls/namelist along
#                with the domain(s) and forecast time(s).
#bash_version   :4.2.46(2)-release
#============================================================================

whichconda=$(which conda |  awk -F/ '{print $(NF-2)}')
if [ -e $HOME/$whichconda ];
then
. $HOME/$whichconda/etc/profile.d/conda.sh
else
echo $HOME/$whichconda " not found"
echo "conda environment may not be picked up"
fi

# Activate synoptic plotting environment
conda activate swift_synoptic

#code_dir=/gws/nopw/j04/swift/SWIFT-Testbed3/Synoptic/SWIFT-Synoptic
code_dir=/home/users/tdjames1/SWIFT-Testbed3/Synoptic/SWIFT-Synoptic
source_dir=$SWIFT_GFS/GFS_NWP/
plot_dir=$SWIFT_GFS/plots
namelist=$SWIFT_GFS/controls/namelist

dates=${1:-$(grep init $namelist | cut -d':' -f2 | tr ',' '\n')}
fct=$(grep fore $namelist | cut -d':' -f2 | tr ',' '\n')
domain=$(grep region $namelist | cut -d':' -f2 | tr ',' '\n')

for date in $dates; do
    echo $date

    YYYYMMDD=$(echo $date | cut -b -8)
    HH=$(echo $date | cut -b 9-)

    # number of jobs to initiate
    N=6
    for dom in $domain; do
	# select chart types
	if [ $dom = 'PA' ]; then
	    chart_types="low jets"
	elif [ $dom = 'EA' ]; then
	    chart_types="low jets conv synth"
	else
	    chart_types="low jets conv synth"
	fi
	for chart_type in ${chart_types}; do
            out_dir=$plot_dir/$YYYYMMDD$HH/$dom/$chart_type/
            mkdir -p $out_dir
            for fore in 0 $fct; do
		((i=i%N)); ((i++==0)) && wait
		python $code_dir/synoptic/chart.py $dom $YYYYMMDD$HH $fore $chart_type -o $out_dir &
            done
        done
    done
    wait
    # get timestamp for T-24h initialisation time
    date_m24=$(date -u --date=${YYYYMMDD}' '${HH}':00 last day' '+%Y%m%d%H')
    # clean up T-24h files
    rm -r $source_dir/$date_m24
done

conda deactivate
