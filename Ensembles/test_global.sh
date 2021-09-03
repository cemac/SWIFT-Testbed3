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
 plog_grabber.sh
 A CEMAC script to grab png files
 Usage:
  .\plot_grabber.sh --p
 Options:
  -d date
  -t hour
  -h HELP: prints this message!
 **
 Code my be modified such as altering version dates for alternative experiments
 obtained via https://esgf-node.llnl.gov/search/cmip5/
 **
 version: 0.4 (beta un-released)
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

# For
mkdir /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now
# Available vars
#varlists=["Precip3hr_r" "PrecipRate_r" ]
#stampvarlis=["precip_amount"]
#modellist=["mo-g"  "km8p8_ra2t"]
#regionlist=["TAfr" "CAfr2" "WAfrs" "wafr" "GuinC" "EAfr1B" "EAfr1Bs" "Sengl" "EAfr1Bs"]
#citylist=["ABU" "ACC"  "DAK" "KAN" "KUM" "LAG" "LAK" "MOM" "NAI" "TAM" "TBA" "TOU"]
declare -a country_list=("afr" "cafr" "eafr" "gha" "kya" "nga" "sen" "wafr")
#probvar=["24hr_precip_amount" ]
declare -a pthresholds=("32mm"  "64mm"  "128mm")
declare -a cutout_list=("afr" "cafr" "eafr" "wafr")

for country in ${country_list[@]};
 do
  if [[ " ${cutout_list[@]}" =~ "${country}" ]]; then
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 24 -l "48"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 24 -l "72"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "48" -x "*mm"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "72" -x "*mm"

  else
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "27"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "3*"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "4*"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "5*"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "6*"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "72"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "75"
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "27" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "3*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "4*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "5*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "6*" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "72" -x 16mm
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "75" -x 16mm
  fi

done
./plot_grabber.sh -d $now -t $hr -m "mo-g"  -p "meteogram" -r "*"
cd images

../size_reduction.sh
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
 python  ../../ppt_gen.py --WG "ENS" --OUT "${now}T${hr}00Z_${WG}_Global_" --R "${country}"
 mv ${now}T${hr}00Z_${WG}_Global_*.pptx /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now/
 cd ..
done
echo removing images
cd ..
rm -rf images/*

24hr_precip_amount_cafr_*_*00Z_T72.0.png’: No such file or directory
