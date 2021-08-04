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
startday="*"
hr="00"
leadtime="0"
plot_type="meteogram"
var="precip_accum_nbhood_max"
model="mo-g"
cutout="afr"
threshold="128mm"
jas='Y'
timeframe="24"
# Available vars in string arrays
varlists=("RainSnow1hr" "Precip1hr_r" "RainSnow3hr" "Precip3hr_r" "RainSnowRates" "PrecipRate_r" "T_surf" "WindSpdDir_10m")
stampvarlis=("precip_amount temp_1.5m wind_10m")
modellist=("mo-g"  "km8p8_ra2t")
regionlist=("TAfr" "CAfr2" "WAfrs" "wafr" "GuinC" "EAfr1B" "EAfr1Bs" "Sengl" "EAfr1Bs")
citylist=("ABU" "ACC"  "DAK" "KAN" "KUM" "LAG" "LAK" "MOM" "NAI" "TAM" "TBA" "TOU")
cutout=("afr" "cafr" "eafr" "gha" "kya" "nga" "sen" "wafr")
probvar=("temp_1.5m" "24hr_precip_amount" "wind_10m")
pthresholds=("16mm"  "32mm"  "64mm"  "128mm"  "256mm"  "512mm")
tthresholds=("30C" "40C" "50C")
wthresholds=("30knots" "40knots" "50knots")

print_usage() {
  echo "
 plog_grabber.sh
 A CEMAC script to grab png files
 Usage:
  .\plot_grabber.sh --p
 Options:
  -d date YYYYMMDD
  -m model mo-g or km8p8_ra2t
  -p plot_type
  -v var
  varlists=(RainSnow1hr Precip1hr_r RainSnow3hr Precip3hr_r RainSnowRates
            PrecipRate_r T_surf WindSpdDir_10m)
  stampvarlis=(precip_amount temp_1.5m wind_10m)
  -x threshold
    pthresholds=(16mm  32mm  64mm  128mm  256mm  512mm)
    tthresholds=(30C 40C 50C)
    wthresholds=(30knots 40knots 50knots)
  -f timeframe
  -r region/cutout from these
    regionlist=TAfr CAfr2 WAfrs wafr GuinC EAfr1B EAfr1Bs Sengl EAfr1Bs
    citylist=ABU ACC  DAK KAN KUM LAG LAK MOM NAI TAM TBA TOU
    cutout=afr cafr eafr gha kya nga sen wafr
  -t hour e.g 00 , 12 , 15, 03
  -l leadtime e.g. 01
  -y starthour e.g. 00
  -z startday e.g 10
  -j jas 'Y' or 'N' if 'N' must source .evn file to give access to site
  -h HELP: prints this message!
 **
 note wild cards will be accepted
 check url is
 **
 version: 0.4 (beta un-released)
 ------------------------------------------------
  "
}

# Command line arguements to pass in
while getopts 'j:d:m:p:v:r:t:l:f:x:y:z:h' flag; do
  case "${flag}" in
    j) jas="${OPTARG}" ;;
    d) startdate="${OPTARG}" ;;
    m) model="${OPTARG}" ;;
    p) plot_type="${OPTARG}" ;;
    v) var="${OPTARG}" ;;
    r) cutout="${OPTARG}" ;;
    t) hr="${OPTARG}" ;;
    l) leadtime="${OPTARG}" ;;
    f) timeframe="${OPTARG}" ;;
    x) threshold="${OPTARG}" ;;
    y) startday="${OPTARG}" ;;
    z) starthour="${OPTARG}" ;;
    h) print_usage
      exit 1 ;;
    *) print_usage
      exit 1 ;;
  esac
done

# if to be run on jasmin
if [ jas=='Y' ]; then
    # PATH to plots root dir
    url="/gws/nopw/j04/swift/public/requests/SWIFT_TB3/july_dryrun/plotting_suite/"
elif [[ jas=='N' ]]; then
    # Environment sourced url
    url=${URL}
fi

echo jamsin = $jas
echo plottype $plot_type

# Build file name from input vars

# nearest neighbour hood max plots
if [[ "$plot_type" = "nbhood_max" ]]; then
  proburl="prob_${timeframe}hr_precip_accum_nbhood_max_gt_${threshold}_${cutout}_${startday}_${starthour}Z_T${leadtime}.0.png"
  url="${url}${startdate}T${hr}00Z/${model}/${proburl}"
# Stamp plots
elif [[ "$plot_type" = "stamp" ]]; then
  if [[ "$var" = "precip_amount" ]]; then
    stampurl="${timeframe}hr_${var}_${cutout}_${startday}_${starthour}00Z_T${leadtime}.0.png"
  else
    # wind or temp
    stampurl="${var}_${cutout}_${startdate}_${hr}00Z_T${leadtime}.0.png"
  fi
  url="${url}${startdate}T${hr}00Z/${model}/$stampurl"
# Paintball plot
elif [[ "${plot_type}" = "paintball" ]]; then
  url="${url}${startdate}T${hr}00Z/${model}/paintball_plot_${timeframe}_precip_amount_gt_${threshold}_${cutout}_${startdate}_${hr}Z_T${leadtime}.00.png"
# Probability plot
elif [[ "${plot_type}" = "prob" ]]; then
  if [[ " $probvarlist " =~ .*\ $var\ .* ]]; then
  	if $var == "precip_amount" ]; then
        probplot="prob_${timeframe}_${probvar}_gt_${threshold}_${cutout}_${startdate}_${hr}Z_T${leadtime}.0.png"
    else
      # wind or temp
      probplot="prob_${probvar}_gt_${threshold}_${cutout}_${startdate}_${hr}Z_T${leadtime}.0.png"
    fi
  else
    echo $var" not in "$probvarlist
  fi
    url="${url}${startdate}T${hr}00Z/${model}/${probplot}"
# meteogram plots
elif [[ "${plot_type}" = "meteogram" ]]; then
  echo $url
  echo $model
  url="${url}${startdate}T${hr}00Z/${model}/mixed_fields_meteogram_${cutout}.png"
fi

# Make images folder if doesn't exist
if [ ! -e  images ]; then
  mkdir images
fi

cd images
# Put file in images folder
if [[ "$jas" = "N" ]]; then
    wget --user $username --password $password $url
elif [[ "$jas" = "Y" ]]; then
    echo "downloaing $url"
    cp -p $url .
fi
# Task completed
