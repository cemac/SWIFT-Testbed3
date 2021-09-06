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
now=20210808
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
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l "48"
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l "72"
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "48" -x "*mm"
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "72" -x "*mm"

  else
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l "48"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l "72"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "24"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "27"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "30"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "33"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "36"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "39"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "4*"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "5*"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "60"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "63"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "66"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "69"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "72"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "24" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "27" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "30" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "33" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "36*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "39*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "4*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "5*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "60" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "63" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "66" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "69" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "72" -x 16mm
  fi
  for threshold in ${pthresholds[@]}
    do
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 24 -l 48 -x $threshold
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 24 -l 72 -x $threshold
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
    mv *POR*.png $country/
    mv *ENU*.png $country/
 elif [[ "${country}" = "kya" ]]; then
    mv *LAK*.png $country/
    mv *MOM*.png $country/
    mv *NAI*.png $country/
    mv *LAM*.png $country/
    mv *VOI*.png $country/
    mv *GAR*.png $country/
    mv *MAN*.png $country/
    mv *MAR*.png $country/
    mv *KAK*.png $country/
    mv *KIT*.png $country/
    mv *KER*.png $country/
    mv *KIS*.png $country/
    mv *NAI*.png $country/
    mv *NYE*.png $country/
    mv *MER*.png $country/
    mv *NAK*.png $country/
    mv *NAR*.png $country/
    mv *MAC*.png $country/
    mv *KTU*.png $country/
 fi

 cd $country
 # genreate country ppt
 python ../../ppt_gen.py
 # rename and move to public folder
 python  ../../ppt_gen.py --WG "ENS" --OUT "${now}T${hr}00Z_${WG}_CP_" --R "${country}"
 mv ${now}T${hr}00Z_${WG}_CP*.pptx /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now/
 cd ..
 done
echo removing images
cd ..
rm -rf images/*
