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
hr=12
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
     echo 1
     echo stamp
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l 24
  
  else
     echo 2
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "03" -m "km8p8_ra2t" -p "stamp" -r $country -v precip_amount -f 3 -l "*"
     ./plot_grabber.sh -d $now -t $hr -y "*" -z "15" -m "km8p8_ra2t" -p "stamp" -r $country -v precip_amount -f 3 -l "*"

  fi
  echo 3
  echo stamp
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l 48
  echo 4
  echo nbhood_max
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "2*" -x 16mm  
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "3*" -x 16mm  
  ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "4*" -x 16mm  
  for threshold in ${pthresholds[@]}
    do
    echo 5
    echo nbhood_max
    ./plot_grabber.sh -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 24 -l 48 -x $threshold  
  done  
done

echo 6
echo meteogram
./plot_grabber.sh -d $now -t $hr -m "km8p8_ra2t"  -p "meteogram" -r "*"

echo Generatig ppts

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
 elif [[ "${country}" = "gna" ]]; then
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
 mv SWIFT_ppt.pptx ${now}_${WG}_${country}_CP.pptx
 mv ${now}_${WG}_${country}_CP.pptx /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now/
 cd ..
 done

echo removing images
cd ..
rm -rf images/*

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
elif [[ "${country}" = "gna" ]]; then
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
mv SWIFT_ppt.pptx ${now}_${WG}_${country}_Global.pptx
mv ${now}_${WG}_${country}_Global.pptx /gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/$now/
cd ..
done
