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
source .#!/usr/bin/env
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
modellist=["oper-africa","oper-glm","oper-glm"]
modellist2=["afr","glm","glm"]
regionlist=["TAfr","CAfr2","WAfrs","wafr","GuinC","EAfr1B","EAfr1Bs","Sengl","EAfr1Bs"]
# wget plots
wget ${url}${models}/${startdate}_${hr}/${var}_${model}_${enddate}_${endhr}_${leadtime}_${region}.png
wget ${url}${startdate}_${hr}/${var}_${model}_${startdate}_${starthr}_to_${enddate}_${endhr}_${leadtime}_${region}.png
