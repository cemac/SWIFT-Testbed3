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
plot_type="prob_24hr"
var="precip_accum_nbhood_max"
model="mo-g"
cutout="afr"
threshold="128"
jas='Y'
timeframe="24"
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

print_usage() {
  echo "
 plog_grabber.sh
 A CEMAC script to grab png files
 Usage:
  .\plot_grabber.sh --p
 Options:
  -d date
  -m model
  -p plot_type
  -v var
  -x threshold
  -f timeframe
  -r region
  -t hour
  -l leadtime
  -h HELP: prints this message!
 **
 Code my be modified such as altering version dates for alternative experiments
 obtained via https://esgf-node.llnl.gov/search/cmip5/
 **
 version: 0.4 (beta un-released)
 ------------------------------------------------
  "
}

while getopts 'y:z:r:e:h' flag; do
  case "${flag}" in
    j) jas="${OPTARG}" ;;
    d) date="${OPTARG}" ;;
    m) model="${OPTARG}" ;;
    p) plot_type="${OPTARG}" ;;
    v) var="${OPTARG}" ;;
    r) region="${OPTARG}" ;;
    t) hr="${OPTARG}" ;;
    l) leadtime="${OPTARG}" ;;
    h) print_usage
      exit 1 ;;
    *) print_usage
      exit 1 ;;
  esac
done
# if to be run on jasmin
if [ jas=='Y' ]; then
    url="/gws/nopw/j04/swift/public/requests/SWIFT_TB3/plotting_suite/"
elif [[ jas=='N' ]]; then
    url=${URL}
fi

if [ plot_type=='nbhood_max' ]; then
  proburl="prob_24hr_precip_accum_nbhood_max_gt_"${threshold}"_"${cutout}"_"${startdate}"_"${hr}"Z_T"${leadtime}".0.png"
  url= ${url}${models}/${startdate}_${hr}/$proburl
elif [ plot_type=='stamp' ]; then
  if [[ " $stampvarlist " =~ .*\ $var\ .* ]]; then
    if $var == "precip_amount" ]; then
      stampurl=  ${timeframe}_${var}_$cutout"_"${startdate}"_"${hr}"Z_T"${leadtime}".0.png"
    else
      stampurl=${var}_$cutout"_"${startdate}"_"${hr}"Z_T"${leadtime}".0.png"
    fi
elif [ plot_type=='paintball' ]; then
  url= ${url}${model}/${startdate}_${hr}/paintball_plot_${timeframe}_precip_amount"_gt_"${threshold}"_"${cutout}"_"${startdate}"_"${hr}"Z_T"${leadtime}".00.png"
elif [ plot_type=='prob' ]; then
  if [[ " $probvarlist " =~ .*\ $var\ .* ]]; then
    if $var == "precip_amount" ]; then
      probplot="prob_"${timeframe}_${probvar}"_gt_"${threshold}"_"${cutout}"_"${startdate}"_"${hr}"Z_T"${leadtime}".0.png"
    else
      probplot="prob_"${probvar}"_gt_"${threshold}"_"${cutout}"_"${startdate}"_"${hr}"Z_T"${leadtime}".0.png"
    fi
  else
    echo $var" not in "$probvarlist
  fi
  url= ${url}${model}/${startdate}_${hr}/${probplot}
elif [ plot_type=='meteogram' ]; then
  if [[ " $citylist " =~ .*\ $city\ .* ]]; then
    url=${url}${model}/${startdate}_${hr}/"mixed_fields_meteogram_"${city}".png"
  else
    echo $city not in $citylist
  fi
fi

if [ ! -e  images ]; then
  mkdir images
fi

cd images
echo "downloading image"
if [ jas=='Y' ]; then
    wget --user $username --password $password $url
elif [[ jas=='N' ]]; then
    cp -p $url .
fi
