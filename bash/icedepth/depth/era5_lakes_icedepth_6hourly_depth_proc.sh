#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on 6-hourly C3S_511 ice depth files:
    # mask inland water bodies
    # fieldmeans and timmeans on different months
    # signals on different months

# =======================================================================
# INITIALIZATION
# =======================================================================

# load CDO
module load CDO

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/icedepth/depth

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/101/vsc10116/C3S_511/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5/lakes/icedepth

# months
MONTHs=('OCT' 'NOV' 'DEC' 'JAN' 'FEB' 'MAR' 'APR' 'MAY' 'JUN' 'JUL' 'AUG' 'SEP')

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
cdo -b F64 -O -L setreftime,1979-01-01,00:00:00,1months -settaxis,1979-01-01,00:00:00,1months -monmean era5_lakes_icedepth_6hourly_1979_2019.nc $scratchDIR/startfile.nc


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

    cdo -b F64 -O -L timmean -selmon,$i -seldate,1979-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $outDIR/era5_lakes_icedepth_timmean_${MONTHs[$i]}_1979_2018.nc

done


#marker
echo ' '
echo 'FLDMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L fldmean -selmon,$i -seldate,1979-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $outDIR/era5_lakes_icedepth_fldmean_${MONTHs[$i]}_1979_2018.nc

done

# ==============================================================================
# SIGNALS
# ==============================================================================

#marker
echo ' '
echo 'SIGNALS CALC'
echo ' '


for i in $(seq 0 11); do

    # signal (first 5 years)
    cdo -b F64 -O -L timmean -seldate,1979-01-01T00:00:00,1983-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_1979_1983_5year.nc

    # signal (last 5 years)
    cdo -b F64 -O -L timmean -seldate,2014-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_2014_2018_5year.nc

    #signal (diff)
    cdo -b F64 -O -L sub $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_2014_2018_5year.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_1979_1983_5year.nc $outDIR/era5_lakes_icedepth_signal_${MONTHs[$i]}_1979_2019.nc

done


rm $scratchDIR/era5_lakes*.nc

rm $scratchDIR/icedepth_monthly_1979_2019.nc
