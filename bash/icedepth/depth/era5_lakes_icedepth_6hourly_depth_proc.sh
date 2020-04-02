#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# April 1st

# Operations on 6-hourly C3S_511 ice depth files:
    # mask inland water bodies
    # fieldmeans and timmeans on different months
    # signals on different months

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5/icedepth/depth_v2

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant/era5/proc/icedepth

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5/lakes/icedepth

# months
MONTHs=('JAN' 'FEB' 'MAR' 'APR' 'MAY' 'JUN' 'JUL' 'AUG' 'SEP' 'OCT' 'NOV' 'DEC')

# ==============================================================================
# PROCESSING
# ==============================================================================

cd $inDIR
pwd

# ==============================================================================
# DAILY MEANS + MASK
# ==============================================================================

#marker for stderr new beginning
echo ' '
echo 'SCRIPT START'
echo ' '


# prep start file to day res
cdo -b F64 -O -L setreftime,1979-01-01,00:00:00,1months -settaxis,1979-01-01,00:00:00,1months -monmean era5_lakes_icedepth_6hourly_1979_2019_v2.nc $scratchDIR/startfile.nc


# mask starting file
cdo ifthen $maskDIR/lakemask.nc $scratchDIR/startfile.nc $scratchDIR/icedepth_monthly_1979_2019.nc


rm $scratchDIR/startfile.nc

# ==============================================================================
# TIMMEANS & FLDMEANS
# ==============================================================================

#marker
echo ' '
echo 'TIMMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,1981-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $outDIR/timmean/era5_lakes_icedepth_timmean_${MONTHs[$i]}_1979_2019.nc

done


#marker
echo ' '
echo 'FLDMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L fldmean -selmon,$(($i+1)) -seldate,1981-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $outDIR/timmean/era5_lakes_icedepth_fldmean_${MONTHs[$i]}_1979_2019.nc

done

# ==============================================================================
# SIGNALS
# ==============================================================================

#marker
echo ' '
echo 'SIGNALS CALC'
echo ' '


for i in $(seq 0 11); do

    # signal (first 10 years)
    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,1979-01-01T00:00:00,1988-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_1979_1988_10year.nc

    # signal (last 10 years)
    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_2010_2019_10year.nc

    #signal (diff)
    cdo -b F64 -O -L sub $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_2010_2019_10year.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_1979_1988_10year.nc $outDIR/era5_lakes_icedepth_signal_${MONTHs[$i]}_1979_2019.nc

done


rm $scratchDIR/era5_lakes*.nc

rm $scratchDIR/icedepth_monthly_1979_2019.nc
