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
# Variables
url=$URL
startdate="20210307"
enddate="20210308"
starthr="18Z"
endhr="01Z"
var="RainSnow6hr"
models='glm'
model="oper-glm"
leadtime="T6"
region="TAfr"
# Available vars
varlists=["RainSnow1hr","Precip1hr_r","RainSnow3hr","Precip3hr_r","RainSnowRates","PrecipRate_r","T_surf","WindSpdDir_10m"]
modellist=["]
regionlist=["TAfr","CAfr2","WAfrs","wafr","GuinC","EAfr1B","EAfr1Bs","Sengl","EAfr1Bs"]
# wget plots
wget ${url}${models}/${startdate}_${hr}/${var}_${model}_${enddate}_${endhr}_${leadtime}_${region}.png
wget ${url}${startdate}_${hr}/${var}_${model}_${startdate}_${starthr}_to_${enddate}_${endhr}_${leadtime}_${region}.png

url=$URL
startdate="20210307"
enddate="20210308"
starthr="1200"
endhr="01Z"
var="RainSnow6hr"
models='glm'
model="oper-glm"
leadtime="T6"
region="TAfr"
# Available vars
varlists=["RainSnow1hr","Precip1hr_r","RainSnow3hr","Precip3hr_r","RainSnowRates","PrecipRate_r","T_surf","WindSpdDir_10m"]
modellist=["mo-g", "km8p8_ra2t"]
regionlist=["TAfr","CAfr2","WAfrs","wafr","GuinC","EAfr1B","EAfr1Bs","Sengl","EAfr1Bs"]
citylist=["ABU","ACC", "DAK","KAN","KUM","LAG","LAK","MOM","NAI","TAM","TBA","TOU"]
meteogram="mixed_fields_meteogram_"${city}".png"
cutout=["afr","cafr","eafr","gha","kya","nga","sen","wafr"]
probvar=["temp_1.5m","24hr_precip_amount","wind_10m"]
thresholds=["30C","40C","50C", "16mm", "32mm", "64mm", "128mm", "256mm", "512mm","30knots","40knots","50knots"]
probplot="prob_"${probvar}"_gt_"${threshold}"_"${cutout}"_"${startdate}"_"${hr}"Z_T"${leadtime}".00.png"
# wget plots
wget --user $USER --password $password ${url}${models}/${startdate}_${hr}/${var}_${model}_${enddate}_${endhr}_${leadtime}_${region}.png
wget ${url}${startdate}_${hr}/${var}_${model}_${startdate}_${starthr}_to_${enddate}_${endhr}_${leadtime}_${region}.png


wget ${url}${startdate}T{hr}Z/${model}/
