#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  1 16:09:50 2021

@author: earbwo
"""

from __future__ import division
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
import iris
import scipy.signal
from gpm_netcdf import gpm_netcdf



def compute_mse(M,O):

    '''
    Compute mean square error (see Roberts and Lean, 2008)

    Inputs:
        M = matrix of fractions for model
        O = matrix of fractions for model

    Outputs:
        mse = mean square error between fractions in model and observations
    '''

    x = 0
    c = 0
    for i in range(np.shape(M)[0]):
        for j in range(np.shape(M)[1]):
            if np.isnan(O[i,j]) == False:
                x = x + (O[i,j]-M[i,j])**2
                c = c + 1

    mse = x/c

    return mse


def compute_mse_ref(M,O):

    '''
    Compute reference mean square error (see Roberts and Lean, 2008)

    Inputs:
        M = matrix of fractions for model
        O = matrix of fractions for model

    Outputs:
        mse = reference mean square error between fractions in model and observations
    '''

    x = 0
    c = 0
    for i in range(np.shape(M)[0]):
        for j in range(np.shape(M)[1]):
            if np.isnan(O[i,j]) == False:
                x = x + O[i,j]**2+M[i,j]**2
                c = c + 1

    mse_ref = x/c

    return mse_ref


def compute_fss(M,O):

    '''
    Compute FSS (see Roberts and Lean, 2008)

    Inputs:
        M = matrix of fractions for model
        O = matrix of fractions for model

    Outputs:
        fss = Fractions Skill Score
    '''

    if np.shape(M)[0] > 0:
        mse = compute_mse(M,O)
        mse_ref = compute_mse_ref(M,O)
        if mse == 0:
            fss = 1
        else:
            fss = 1 - mse/mse_ref
    else:
        fss = np.nan

    return fss


def compute_fractions(cube,n,pq,abso=False):

    '''
    Compute fractions (see Roberts and Lean, 2008)

    Inputs:
        cube = cube of either obs or model
        n = neighburhood size in grid-points (must be odd number)
        pq = rainfall threshold (either absolute or percentile)
        abso = True if absolute threshold, False if percentile threshold

    Outputs:
        fss = Fractions Skill Score
    '''

    I = np.zeros(np.shape(cube.data)) # binary matrix

    if abso == False:
        q = np.nanpercentile(cube.data,pq)
    elif abso == True:
        q = pq

    I[cube.data>=q] = 1 # pixels where rainfall exceeds threshold = 1, else 0

    M = scipy.signal.fftconvolve(I,np.ones((n,n)),mode='same') # compute fractions

    return M


'''Example of how to use this code with GPM rainfall data. As you hopefully have access to this data, I will also use a different GPM time as a fake model.
Usually have to regrid model to obs so is commented below. GPM isin HDF5 format so I have a conversion script to iris cube also attached, please excuse the mess!'''


coords = [21.5,52,-20.5,17.5] #[lon_min,lon_max,lat_min,lat_max]
cube_obs = gpm_netcdf([dt.datetime(2019,4,28,00,00,00)],coords)
cube_mod = gpm_netcdf([dt.datetime(2019,4,28,3,00,00)],coords)

# regridding, might need below for model but not necessary when using GPM
#cube_obs.coord('longitude').guess_bounds()
#cube_obs.coord('latitude').guess_bounds()
#cube_obs.coord('latitude').coord_system = None
#cube_obs.coord('longitude').coord_system = None
#cube_obs.coord('longitude').guess_bounds()
#cube_obs.coord('latitude').guess_bounds()
#cube_mod = cube_mod.regrid(cube_obs,iris.analysis.AreaWeighted())

q = 97 # 97th percentile threshold
ns = np.arange(1,31,2) # neighbourhood sizes
FSS = []
for n in ns:
    O = compute_fractions(cube_obs,n,q)
    M = compute_fractions(cube_mod,n,q)
    FSS.append(compute_fss(M,O))

# classic FSS plot of neighbourhood size against FSS
ax = plt.subplot(111)
ax.plot(ns,FSS)
ax.set_xlabel('neighbourhood size (grid points)')
ax.set_ylabel('FSS')

plt.show()
