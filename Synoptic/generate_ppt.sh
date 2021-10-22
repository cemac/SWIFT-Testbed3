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

#tb3_dir=/gws/nopw/j04/swift/SWIFT-Testbed3
tb3_dir=~/SWIFT-Testbed3
tools_dir=$tb3_dir/Tools

# WG
WG=synoptic
init=${1:-$(grep init $SWIFT_GFS/controls/namelist | cut -d':' -f2 | tr ',' '\n')}
domain=$(grep region $SWIFT_GFS/controls/namelist | cut -d':' -f2 | tr ',' '\n')

for now in $init
do

    ppt_dir=/gws/nopw/j04/swift/public/TestBed3/Synoptic_ppts/$now
    mkdir -p $ppt_dir

    # Set up temp directory structure for creating PPTs
    mkdir -p $TMPDIR/ppt_gen

    # Link to legends directory
    [[ ! -d $TMPDIR/ppt_gen/legends ]] && ln -s $tb3_dir/Synoptic/legends $TMPDIR/ppt_gen

    for tag in $domain
    do
	[[ $tag = "PA" ]] && continue
	# Create separate powerpoints for full synoptic charts and synthesis charts
	for ppt_type in full synth
	do
	    images_dir=$TMPDIR/ppt_gen/$tag/$ppt_type
	    mkdir -p $images_dir
	    rm $images_dir/*
	    if [ $ppt_type = "full" ]
	    then
		search_dirs="$SWIFT_GFS/plots/$now/PA $SWIFT_GFS/plots/$now/$tag/low $SWIFT_GFS/plots/$now/$tag/jets $SWIFT_GFS/plots/$now/$tag/conv"
	    else
		search_dirs="$SWIFT_GFS/plots/$now/PA/low $SWIFT_GFS/plots/$now/$tag/synth"
	    fi
	    find ${search_dirs} -iname '*.png' -exec cp --target-directory ${images_dir} {} \;
	    cd $images_dir
	    . $tools_dir/size_reduction.sh
	    [[ $tag = "WA" ]] && code="wafr" || code="eafr"
	    [[ $ppt_type = "full" ]] && suffix="" || suffix="_for_nowcasting_briefing"
	    filename=$now"_"$WG"_"$tag"_synthetic_charts"$suffix
	    python $tools_dir/ppt_gen.py --R $code --OUT $filename --WG SYNOP
	    mv $filename.pptx $ppt_dir
	done
    done
done

conda deactivate
