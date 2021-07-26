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
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 24 -l "*"
  else
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "00" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "*"
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "12" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "*"
     
  fi
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "2*"
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "3*"
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 3 -l "4*"
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "mo-g" -p "stamp" -r $country -v "precip_amount" -f 24 -l 45
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "2*" -x 16mm  
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "3*" -x 16mm  
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "mo-g" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "4*" -x 16mm  

done
./plot_grabber.sh -d $now -t $hr -m "mo-g"  -p "meteogram" -r "*"
cd images

../size_reduction.sh
mkdir afr cafr eafr gha kya nga sen wafr
for country in ${country_list[@]};
do
mv *_${country}_*.png $country/ 
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
python ../../ppt_gen.py
mv SWIFT_ppt.pptx ${now}T${hr}00Z_${WG}_${country}_Global.pptx
mv ${now}T${hr}00Z_${WG}_${country}_Global.pptx /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now/
cd ..
done
echo removing images
cd ..
rm -rf images/*
