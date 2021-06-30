#!/bin/bash -
#title          :size_reduction.sh
#description    :
#author         :CEMAC - Helen
#date           :20213006
#version        :1.0
#usage          :./size_reduction.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

# activat python environment

./plot_grabber.sh
cd images
./size_reduction.sh
python ppt_gen.py
now=date
mv SWIFT_ppt 
