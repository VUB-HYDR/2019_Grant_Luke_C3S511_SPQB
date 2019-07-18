#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  3 11:35:29 2019

@author: Luke
"""

#==============================================================================
#IMPORT
#==============================================================================

from netCDF4 import Dataset
import numpy as np
import xarray as xr
import netCDF4 as nc
import datetime as dt

#==============================================================================
#FUNCTIONS
#==============================================================================

def open_netcdf(infile,var_name):
    """
    Function to open netcdf file and returns unmasked numpy array
    """

    # load netcdf
    ncf = Dataset(infile)
    xrdata = xr.open_dataarray(infile)
    lat = xrdata.latitude.values
    nlat = len(lat)
    lon = xrdata.longitude.values
    nlon = len(lon)
    var_masked = ncf.variables[var_name][0]  #changed from colon to 0 for only one timestep
    Dataset.close(ncf)

    # remove masked array
    data = xrdata.isel(time=0).values

    return data,lon,lat,nlat,nlon

#==============================================================================
#START
#==============================================================================

var,lon,lat,nlat,nlon = open_netcdf('/Users/Luke/Documents/PHD/C3S_511/DATA/lakecover/era5_lakes_lakecover_sample.nc','cl')

#open empty dataset
dataset = nc.Dataset('/Users/Luke/Documents/PHD/C3S_511/DATA/lakecover/lakemask.nc','w', format='NETCDF4_CLASSIC')

#create dimensions to house coordinate variables
dataset.createDimension('lon',nlon)
dataset.createDimension('lat',nlat)
dataset.createDimension('time',None)
                        
#create coordinate variables
lonvar = dataset.createVariable('longitude','f8',('longitude'))
lonvar.standard_name = 'longitude'
lonvar.long_name = 'longitude'
lonvar.units = 'degrees_east'
lonvar.axis = 'X'
lonvar[:] = lon

latvar = dataset.createVariable('latitude','f8',('latitude'))
latvar.standard_name = 'latitude'
latvar.long_name = 'latitude'
latvar.units = 'degrees_north'
latvar.axis = 'Y'
latvar[:] = lat

timevar = dataset.createVariable('time','f8', ('time'))
timevar.standard_name = 'time'
timevar.long_name = 'time'
timevar.units = 'days since 1900-01-01 00:00:00'
timevar.axis = 'T'
timevar.calendar = 'proleptic_gregorian'
timevar[:] = nc.date2num(dt.datetime(1979,1,1), units=timevar.units, calendar=timevar.calendar)

#create ice-on/ice-off variable
cl = dataset.createVariable('cl', 'f8', ('time', 'lat', 'lon'), zlib=True)
#ice_con.missing_value = 0

#add data onto cl
cl[:] = np.expand_dims(var,0)
    
#finish and save info to netCDF
dataset.close()