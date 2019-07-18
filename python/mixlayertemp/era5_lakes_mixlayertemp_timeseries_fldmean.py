#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 24 21:05:53 2018

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script develops ERA5 timeseries projections for global mean lake temperature 
#per season 
    
#==============================================================================
#IMPORT
#==============================================================================

import xarray as xr
import os
import numpy as np
import matplotlib.pyplot as plt

#==============================================================================
#FUNCTIONS
#==============================================================================

#==============================================================================
#SETTINGS
#==============================================================================

title_font = 12

tick_font = 10

#==============================================================================
#INITIALIZE
#==============================================================================

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/mixlayertemp/newmonths/fldmean'
os.chdir(directory)
o_directory = '/Users/Luke/Documents/PHD/C3S_511/FIGURES/mixlayertemp'

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)
 
time = np.arange(1979,2019,1)

#open time series
MAM = xr.open_dataset(files[2],decode_times=False).lmlt.squeeze(dim=['lat','lon']).values[:-1]
DJF = xr.open_dataset(files[0],decode_times=False).lmlt.squeeze(dim=['lat','lon']).values[:-1]
JJA = xr.open_dataset(files[1],decode_times=False).lmlt.squeeze(dim=['lat','lon']).values
SON = xr.open_dataset(files[3],decode_times=False).lmlt.squeeze(dim=['lat','lon']).values
YEAR = xr.open_dataset(files[4],decode_times=False).lmlt.squeeze(dim=['lat','lon']).values[:-1]

#==============================================================================
#PLOTTING
#==============================================================================

#initiate plots
f, ax = plt.subplots(1,1,figsize=(12,8 ),sharex=True)

#load data
h = ax.plot(time,DJF,lw=2,color='steelblue',label='De-Ja-Fe')
h = ax.plot(time,MAM,lw=2,color='mediumseagreen',label='Ma-Ap-Ma')
h = ax.plot(time,JJA,lw=2,color='indianred',label='Ju-Ju-Au')
h = ax.plot(time,SON,lw=2,color='sienna',label='Se-Oc-No')
h = ax.plot(time,YEAR,lw=2,color='k',label='Annual')

#figure adjustments
ax.set_xlim(1979,2019)
ax.tick_params(labelsize=tick_font,axis="x",direction="in", left="off",labelleft="on")
ax.tick_params(labelsize=tick_font,axis="y",direction="in")
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.yaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5)
ax.xaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5)
ax.set_axisbelow(True)

#legend
handles, labels = ax.get_legend_handles_labels()
f.legend(handles, labels, bbox_to_anchor=(0.7, 0.55, 0.1, .15), loc=3,
           mode="expand", borderaxespad=0.,\
           frameon=True, handlelength=0.75, handletextpad=0.5,\
           fontsize=title_font, facecolor='white', edgecolor='k')

#labels
f.text(0.5, 0.065, 'Years', ha='center', fontsize=title_font)
f.text(0.065, 0.5, 'Mixed layer lake temperature (K)', va='center', rotation='vertical', fontsize=title_font)

plt.show(h)

#save figure
f.savefig(o_directory+'/'+'era5_lakes_mixlayertemp_4seasons_fldmean.png',bbox_inches='tight',dpi=900)
