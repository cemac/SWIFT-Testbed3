#!/bin/bash -
#title          :gen_cp_ppt.sh
#description    :
#author         :CEMAC - Helen
#date           :20213006
#version        :1.0
#usage          :./workflow.sh
#notes          :
#bash_version   :4.2.46(2)-release
#============================================================================

# activate python environment
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
conda activate
conda activate swift_tb3

# defaults
WG=ensembles # Working Group
tag="" # outputname tag
now=20210808 # date string YYYYMMDD
hr=00 # hr 00 or 12
email='h.l.burns@leeds.ac.uk' # Email address to report to
mail='Y'
# path to pngs out put by model
url=/gws/nopw/j04/swift/public/requests/SWIFT_TB3/WEEK5_24_31_Oct
# path to where to make output folder
outdirbase=/gws/nopw/j04/swift/public/TestBed3/Ensembles_ppts/

# Command line arguements
# ---------------------------------------------------------------------------


print_usage() {
  echo "
 cpppts.sh
 A CEMAC script to grab png files
 Usage:
  .\gen_cp_ppt -d <date> -t <hr> -u <path-string-to-image-foldder>
 Options:
  -d date
  -t hour
  -u url string path to image folder
  -o outdirbase string path to where to put output folders
  -m Y or N to mail when ppts are done
  -e email address
  -h HELP: prints this message!
 **
 runs a serises of predifend plot grabber commands and the reduces file sizes and genreates
 ppts for each region. To generate region/country convective permitting ensembles ppts.
 **
 version: 1.0
 ------------------------------------------------
  "
}

while getopts 'd:t:u:o:m:e:h' flag; do
  case "${flag}" in
    d) now="${OPTARG}" ;;
    t) hr="${OPTARG}" ;;
    u) url="${OPTARG}" ;;
    o) outdirbase="${OPTARG}" ;;
    m) mail="${OPTARG}" ;;
    e) email"${OPTARG}" ;;
    h) print_usage
      exit 1 ;;
    *) print_usage
      exit 1 ;;
  esac
done

# ----------------------------------------------------------------------------
# make output folder
outdir=${outdirbase}${now}_${hr}00
mkdir $outdir
# String arrays to loop through
# all cutouts E,W Central Africa, Ghana, Kenya, Nigeria Sengal
declare -a country_list=("afr" "cafr" "eafr" "gha" "kya" "nga" "sen" "wafr")
# threshold
declare -a pthresholds=("32mm"  "64mm"  "128mm")
# regions
declare -a cutout_list=("afr" "cafr" "eafr" "wafr")

# Grab plots predetermined plots for each country/region
#----------------------------------------------------------------------------
# For every area
for country in ${country_list[@]};
 do
    ./plot_grabber.sh -u ${url} -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l "48"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 24 -l "72"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "24"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "27"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "30"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "33"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "36"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "39"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "4*"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "5*"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "60"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "63"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "66"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "69"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*"  -m "km8p8_ra2t" -p "stamp" -r $country -v "precip_amount" -f 3 -l "72"
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "24" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "27" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "30" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "33" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "36*" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "39*" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "4*" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "5*" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "60" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "63" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "66" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "69" -x 16mm
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 3 -l "72" -x 16mm
  for threshold in ${pthresholds[@]}
    do
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 24 -l 48 -x $threshold
    ./plot_grabber.sh -u ${url} -d $now -t $hr -y "*" -z "*" -m "km8p8_ra2t" -p "nbhood_max" -r $country -v "precip_amount" -f 24 -l 72 -x $threshold
    done
done

# Grab all meteograms
./plot_grabber.sh -u ${url} -d $now -t $hr -m "km8p8_ra2t"  -p "meteogram" -r "*"
echo plots grabbed
cd images
echo reducing file sizes
../size_reduction.sh
# separeate into regions
mkdir afr cafr eafr gha kya nga sen wafr
# lookp over country list
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
    mv *GHANA_*.png $country/

 elif [[ "${country}" = "nga" ]]; then
    mv *ABU*.png $country/
    mv *KAN*.png $country/
    mv *LAG*.png $country/
    mv *POR*.png $country/
    mv *ENU*.png $country/
 elif [[ "${country}" = "kya" ]]; then
    mv *LAK*.png $country/
    mv *LOD*.png $country/
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
    mv *KIM*.png $country/
    mv *NYE*.png $country/
    mv *MER*.png $country/
    mv *NAK*.png $country/
    mv *NAR*.png $country/
    mv *MAC*.png $country/
 fi

 cd $country
 # genreate country ppt
 # rename and move to public folder
 python  ../../ppt_gen.py --WG "ENS" --OUT "${now}T${hr}00Z_${WG}_CP_" --R $country
 mv ${now}T${hr}00Z_${WG}_CP*.pptx $outdir
 cd ..
 done
# HOUSEKEEPING
echo removing images
cd ..
rm -rf images/*
if [[ "${mail}" = "Y" ]]; then
echo "${now}T${hr}00Z_${WG}_CP ppts generated" | mailx -s "Testbed3 automatic ppts" h.l.burns@leeds.ac.uk
fi
