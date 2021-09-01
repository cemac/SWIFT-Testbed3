#!/bin/bash -
#title          :convert_grib2nc.sh
#description    :Convert GRIB2 GFS data to NetCDF4
#author         :CEMAC - Tamora James
#date           :20210819
#version        :0.1
#usage          :./convert_grib2nc.sh <YYYYMMDDHH> <fff>
#notes          :Convert GFS data from grib2 to NetCDF4 and adjust variables
#                and time format.  Script based on GFS plotting code
#                developed by Alexander Roberts, University of Leeds.
#bash_version   :4.2.46(2)-release
#============================================================================

if [ "$#" -ne  "2" ]
then
    echo "Usage:    convert_grib2nc.sh <YYYYMMDDHH> <fff>"
    exit
fi

INIT_TIME=$1
YYYY=$(echo ${INIT_TIME} | cut -c1-4)
MM=$(echo ${INIT_TIME} | cut -c5-6)
DD=$(echo ${INIT_TIME} | cut -c7-8)
HH=$(echo ${INIT_TIME} | cut -c9-10)
echo ${YYYY}${MM}${DD}${HH}

FFF=$2
echo ${FFF}

cd ${SWIFT_GFS}/GFS_NWP/${YYYY}${MM}${DD}${HH}

if [ ! -e gfs.t${HH}z.pgrb2.0p50.f${FFF} ]
then
    echo "Could not find file: "${SWIFT_GFS}/GFS_NWP/${YYYY}${MM}${DD}${HH}/gfs.t${HH}z.pgrb2.0p50.f${FFF}
    exit
fi

module load jaspy

# convert to netCDF
ncl_convert2nc gfs.t${HH}z.pgrb2.0p50.f${FFF} -e grb2
rm gfs.t${HH}z.pgrb2.0p50.f${FFF}

if [ ${FFF} == "000" ]
then
    # set time and rename analysis data
    cdo -settunits,hours \
	-settaxis,${YYYY}-${MM}-${DD},${HH}:00:00 \
	-setcalendar,proleptic_gregorian \
	gfs.t${HH}z.pgrb2.0p50.f000.nc analysis_gfs_4_${YYYY}${MM}${DD}_${HH}00_000.nc

    rm gfs.t${HH}z.pgrb2.0p50.f000.nc
else
    # select variables and set time for forecast data
    ftime=$(basename gfs.t${HH}z.pgrb2.0p50.f${FFF}.nc | cut -d. -f5 | sed 's/^f[0]*//g')
    echo ${ftime}
    # use chain of operations to set time and select required variables
    cdo -select,name=TMP_P0_L1_GLL0,TMP_P0_L6_GLL0,TMP_P0_L7_GLL0,TMP_P0_L100_GLL0,TMP_P0_L102_GLL0,TMP_P0_L103_GLL0,TMP_P0_L104_GLL0,TMP_P0_2L108_GLL0,TMP_P0_L109_GLL0,POT_P0_L104_GLL0,DPT_P0_L103_GLL0,APTMP_P0_L103_GLL0,SPFH_P0_L103_GLL0,SPFH_P0_2L108_GLL0,RH_P0_L4_GLL0,RH_P0_L100_GLL0,RH_P0_L103_GLL0,RH_P0_2L104_GLL0,RH_P0_L104_GLL0,RH_P0_2L108_GLL0,RH_P0_L200_GLL0,RH_P0_L204_GLL0,PWAT_P0_L200_GLL0,PRATE_P0_L1_GLL0,PRATE_P8_L1_GLL0_avg,PRATE_P8_L1_GLL0_avg3h,PRATE_P8_L1_GLL0_avg6h,SNOD_P0_L1_GLL0,WEASD_P0_L1_GLL0,CLWMR_P0_L100_GLL0,CLWMR_P0_L105_GLL0,ICMR_P0_L100_GLL0,ICMR_P0_L105_GLL0,RWMR_P0_L100_GLL0,RWMR_P0_L105_GLL0,SNMR_P0_L100_GLL0,SNMR_P0_L105_GLL0,GRLE_P0_L100_GLL0,GRLE_P0_L105_GLL0,CPRAT_P0_L1_GLL0,CPOFP_P0_L1_GLL0,CRAIN_P0_L1_GLL0,CFRZR_P0_L1_GLL0,CICEP_P0_L1_GLL0,CSNOW_P0_L1_GLL0,PEVPR_P0_L1_GLL0,UGRD_P0_L6_GLL0,UGRD_P0_L7_GLL0,UGRD_P0_L100_GLL0,UGRD_P0_L102_GLL0,UGRD_P0_L103_GLL0,UGRD_P0_L104_GLL0,UGRD_P0_2L108_GLL0,UGRD_P0_L109_GLL0,UGRD_P0_L220_GLL0,VGRD_P0_L6_GLL0,VGRD_P0_L7_GLL0,VGRD_P0_L100_GLL0,VGRD_P0_L102_GLL0,VGRD_P0_L103_GLL0,VGRD_P0_L104_GLL0,VGRD_P0_2L108_GLL0,VGRD_P0_L109_GLL0,VGRD_P0_L220_GLL0,VVEL_P0_L100_GLL0,VVEL_P0_L104_GLL0,DZDT_P0_L100_GLL0,ABSV_P0_L100_GLL0,GUST_P0_L1_GLL0,VWSH_P0_L7_GLL0,VWSH_P0_L109_GLL0,USTM_P0_2L103_GLL0,VSTM_P0_2L103_GLL0,VRATE_P0_L220_GLL0,PRES_P0_L1_GLL0,PRES_P0_L6_GLL0,PRES_P0_L7_GLL0,PRES_P0_L103_GLL0,PRES_P0_L109_GLL0,PRES_P0_L242_GLL0,PRES_P0_L243_GLL0,PRMSL_P0_L101_GLL0,ICAHT_P0_L6_GLL0,ICAHT_P0_L7_GLL0,HGT_P0_L1_GLL0,HGT_P0_L4_GLL0,HGT_P0_L6_GLL0,HGT_P0_L7_GLL0,HGT_P0_L100_GLL0,HGT_P0_L109_GLL0,HGT_P0_L204_GLL0,MSLET_P0_L101_GLL0,\5WAVH_P0_L100_GLL0,HPBL_P0_L1_GLL0,PLPL_P0_2L108_GLL0,TCDC_P0_L100_GLL0,TCDC_P0_L244_GLL0,CWAT_P0_L200_GLL0,SUNSD_P0_L1_GLL0,CAPE_P0_L1_GLL0,CAPE_P0_2L108_GLL0,CIN_P0_L1_GLL0,CIN_P0_2L108_GLL0,HLCY_P0_2L103_GLL0,LFTX_P0_L1_GLL0,\4LFTX_P0_L1_GLL0,TOZNE_P0_L200_GLL0,O3MR_P0_L100_GLL0,REFC_P0_L10_GLL0,VIS_P0_L1_GLL0,ICSEV_P0_L100_GLL0,LAND_P0_L1_GLL0,TSOIL_P0_2L106_GLL0,SOILW_P0_2L106_GLL0,WILT_P0_L1_GLL0,FLDCP_P0_L1_GLL0,HINDEX_P0_L1_GLL0 \
        -setcalendar,proleptic_gregorian \
        -shifttime,${ftime}hours \
        -settaxis,${YYYY}-${MM}-${DD},${HH}:00:00 gfs.t${HH}z.pgrb2.0p50.f${FFF}.nc new_gfs.t${HH}z.pgrb2.0p50.f${FFF}.nc
    rm gfs.t${HH}z.pgrb2.0p50.f${FFF}.nc
fi
