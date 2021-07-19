#!/bin/bash -
#title          :workflow.sh
#description    :
#author         :CEMAC - Helen
#date           :20213006
#version        :1.0
#usage          :./workflow.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

# activate python environment

whichconda=$(which conda |  awk -F/ '{print $(NF-2)}')
# Try to initialize environment
if [ -e $HOME/$whichconda ];
then
. $HOME/$whichconda/etc/profile.d/conda.sh
else
echo $HOME/$whichconda " not found"
echo "conda environment may not be picked up"
fi

conda activate
conda activate swift_tb3

# WG
WG=ensembles
tag=""
now=date

# For
cd $WG

./plot_grabber.sh
cd images
../size_reduction.sh
python ppt_gen.py
mv SWIFT_ppt.pptx $now"_"$WG"_"$tag".pptx"
