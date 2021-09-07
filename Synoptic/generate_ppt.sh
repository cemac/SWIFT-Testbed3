#!/bin/bash -
#title          :generate_ppt.sh
#description    :Generate powerpoints for synoptic charts
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./generate_ppt.sh [YYYYMMDDHH]
#notes          :Generate powerpoints for synoptic charts.
#bash_version   :4.2.46(2)-release
#============================================================================

whichconda=$(which conda |  awk -F/ '{print $(NF-2)}')
# Try to initialize environment
if [ -e $HOME/$whichconda ];
then
. $HOME/$whichconda/etc/profile.d/conda.sh
else
echo $HOME/$whichconda " not found"
echo "conda environment may not be picked up"
fi

# Activate SWIFT TB3 environment
conda activate swift_tb3

tools_dir=/gws/nopw/j04/swift/SWIFT-Testbed3/Tools

# WG
WG=synoptic
init=${1:-$(grep init $SWIFT_GFS/controls/namelist | cut -d':' -f2 | tr ',' '\n')}

for now in $init
do

    ppt_dir=/gws/nopw/j04/swift/public/TestBed3/Synoptic_ppts/$now
    mkdir -p $ppt_dir

    cd $TMPDIR
    mkdir -p images

    for tag in WA EA
    do
	rm images/*
	find $SWIFT_GFS/plots/$now/PA $SWIFT_GFS/plots/$now/$tag -iname '*.png' -exec cp --target-directory images {} \;
	cd images
	. $tools_dir/size_reduction.sh
	cd ..
	python $tools_dir/ppt_gen.py
	mv SWIFT_ppt.pptx $ppt_dir/$now"_"$WG"_"$tag".pptx"
    done
done

conda deactivate
