#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 10 13:02:58 2020

@author: earbwo
"""

from __future__ import division
import numpy as np
import iris
import h5py
import glob
import numpy.ma as ma
from netcdftime import utime
cdftime = utime('hours since 0001-01-01 00:00:00')
import datetime as dt

def find_nearest(array,value):
    idx = (np.abs(array-value)).argmin()
    return idx

def date_list_specify(start, end, timestep):
    #timestep in minutes
    step = timestep*60
    r = int((end+dt.timedelta(seconds=step)-start).total_seconds()/step)
    return [start+dt.timedelta(minutes=timestep*i) for i in range(r)]


def gpm_netcdf(date_list,coords):

    lon_min = coords[0]
    lon_max = coords[1]
    lat_min = coords[2]
    lat_max = coords[3]

    cube_list =  iris.cube.CubeList()

    for date in date_list:

        filename = '/nfs/a321/datasets/GPM/'+date.strftime('%Y')+'/3B-HHR.MS.MRG.3IMERG.' + date.strftime('%Y%m%d-S%H%M00') + '*.HDF5'#-E205959.1230.V04A.HDF5'#'/nfs/a240/eebjw/gpm/3B-HHR-E.MS.MRG.3IMERG.20171004-S223000-E225959.1350.V04B.HDF5'#'/nfs/a240/eebjw/gpm/3B-HHR.MS.MRG.3IMERG.20140406-S120000*'

        f = h5py.File(glob.glob(filename)[0],'r')

        a_group_key = f.keys()[0]

        # Get the data
        lon = np.array(f[a_group_key]['lon'])
        lat = np.array(f[a_group_key]['lat'])
        data = np.array(f[a_group_key]['precipitationCal'])
        data = np.squeeze(data)
    #    print 360-np.min(cube_init.coord('longitude').points),360-np.max(cube_init.coord('longitude').points)

        lon_min2 = find_nearest(lon,lon_min-.05)
        lat_min2 = find_nearest(lat,lat_min-.05)
        lon_max2 = find_nearest(lon,lon_max+.05)
        lat_max2 = find_nearest(lat,lat_max+.05)

    #    print lon_min,lon_max,lat_min,lat_max
        data = data[lon_min2:lon_max2+1,lat_min2:lat_max2+1]
        lon = lon[lon_min2:lon_max2+1]
        lat = lat[lat_min2:lat_max2+1]

        lat_coord =  iris.coords.DimCoord(lat, standard_name=u"latitude", long_name=u'Latitude', units='degrees', bounds=None, attributes=None, coord_system=None, circular=False)
        lon_coord = iris.coords.DimCoord(lon, standard_name=u"longitude", long_name=u'Longitude', units='degrees', bounds=None, attributes=None, coord_system=None, circular=False)
        data = ma.masked_equal(data,-9999.90039062)
        cube_new = iris.cube.Cube(data.T, standard_name=None,long_name="GPM", units=None, dim_coords_and_dims=[(lat_coord,0),(lon_coord,1)])
        cube_new.add_aux_coord(iris.coords.AuxCoord(cdftime.date2num(date), standard_name = 'time', long_name='time', units='hours since 0001-01-01 00:00:00'))
        cube_list.append(cube_new)

    cube_new = cube_list.merge()[0]
    cube_new = iris.util.squeeze(cube_new)

    return cube_new

def gpm_accum(accum_periods,coords):

    cubes = iris.cube.CubeList()

    for i in range(len(accum_periods)-1):
        date_list = date_list_specify(accum_periods[i],accum_periods[i+1]-dt.timedelta(minutes=30),30)
        cube = gpm_netcdf(date_list,coords)
        cube = cube.collapsed('time',iris.analysis.SUM)*.5
        cubes.append(cube)

    cube_new = cubes.merge()[0]

    return cube_new
