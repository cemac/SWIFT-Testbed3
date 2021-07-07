#!/bin/bash -
#title          :plot_grabber.sh
#description    :
#author         :CEMAC - Helen
#date           :20210309
#version        :1.0
#usage          :./plot_grabber.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

# url hidden from public repo
source .env
# Default Variables
startdate="20210528"
hr="00"
leadtime="00"
# Available vars
varlists=["RainSnow1hr" "Precip1hr_r" "RainSnow3hr" "Precip3hr_r" "RainSnowRates" "PrecipRate_r" "T_surf" "WindSpdDir_10m"]
stampvarlis=["precip_amount temp_1.5m wind_10m"]
modellist=["mo-g"  "km8p8_ra2t"]
regionlist=["TAfr" "CAfr2" "WAfrs" "wafr" "GuinC" "EAfr1B" "EAfr1Bs" "Sengl" "EAfr1Bs"]
citylist=["ABU" "ACC"  "DAK" "KAN" "KUM" "LAG" "LAK" "MOM" "NAI" "TAM" "TBA" "TOU"]
cutout=["afr" "cafr" "eafr" "gha" "kya" "nga" "sen" "wafr"]
probvar=["temp_1.5m" "24hr_precip_amount" "wind_10m"]
pthresholds=["16mm"  "32mm"  "64mm"  "128mm"  "256mm"  "512mm"]
tthresholds=["30C" "40C" "50C"]
wthresholds=["30knots" "40knots" "50knots"]

if [ ! -e  images ]; then
  mkdir images
fi
cd images
echo "removing old images"
