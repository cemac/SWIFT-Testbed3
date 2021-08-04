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

# Try to initialize environment
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
conda activate
conda activate swift_tb3

# WG
WG=ensembles
tag=""
now=20210515
hr=00
print_usage() {
  echo "
 cpppts.sh
 A CEMAC script to grab png files
 Usage:
  .\plot_grabber.sh --p
 Options:
  -d date
  -t hour
  -h HELP: prints this message!
 **
 runs a serises of predifend plot grabber commands and the reduces file sizes and genreates
 ppts for each region
 **

 ------------------------------------------------
  "
}

while getopts 'd:t:h' flag; do
  case "${flag}" in
    d) now="${OPTARG}" ;;
    t) hr="${OPTARG}" ;;
    h) print_usage
      exit 1 ;;
    *) print_usage
      exit 1 ;;
  esac
done

# make folder
mkdir /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now
# String arrays to loop through
# all cutouts
declare -a country_list=("afr" "cafr" "eafr" "gha" "kya" "nga" "sen" "wafr")
# threshold
declare -a pthresholds=("32mm"  "64mm"  "128mm")
# regions
declare -a cutout_list=("afr" "cafr" "eafr" "wafr")

# For every area
for country in ${country_list[@]};
 do
  if [[ " ${cutout_list[@]}" =~ "${country}" ]]; then
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l 24

  else
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "03" -m "km8p8_ra2t" -p "stamp" -r $country -v precip_amount -f 3 -l "*"
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "15" -m "km8p8_ra2t" -p "stamp" -r $country -v precip_amount -f 3 -l "*"

  fi
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l 48
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "2*" -x 16mm
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "3*" -x 16mm
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "4*" -x 16mm
  for threshold in ${pthresholds[@]}
    do
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 24 -l 48 -x $threshold
  done
done

# Grab all meteograms
./plot_grabber.sh -d $now -t $hr -m "km8p8_ra2t"  -p "meteogram" -r "*"

echo plots grabbed

cd images

echo reducing file sizes
../size_reduction.sh

# separeate into regions
mkdir afr cafr eafr gha kya nga sen wafr

for country in ${country_list[@]};
 do
 mv *_${country}_*.png $country/
 # Move city meteograms to country folders
 if [[ "${country}" = "sen" ]]; then
    mv *DAK*.png $country/
    mv *TBA*.png $country/
    mv *TOU*.png $country/
 elif [[ "${country}" = "gha" ]]; then
    mv *ACC*.png $country/
    mv *KUM*.png $country/
    mv *TAM*.png $country/
 elif [[ "${country}" = "nga" ]]; then
    mv *ABU*.png $country/
    mv *KAN*.png $country/
    mv *LAG*.png $country/
 elif [[ "${country}" = "kya" ]]; then
    mv *LAK*.png $country/
    mv *MOM*.png $country/
    mv *NAI*.png $country/
 fi

 cd $country
 # genreate country ppt
 python ../../ppt_gen.py
 # rename and move to public folder
 mv SWIFT_ppt.pptx ${now}T${hr}00Z_${WG}_${country}_CP.pptx
 mv ${now}T${hr}00Z_${WG}_${country}_CP.pptx /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now/
 cd ..
 done
echo removing images
cd ..
rm -rf images/*
