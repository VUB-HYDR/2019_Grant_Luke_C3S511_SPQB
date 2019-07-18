#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on monthly C3S_511 ice depth files (locally):
    # mask for inland water bodies
    # fieldmeans and timmeans on different months
    # signals on different months

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/Users/Luke/Documents/PHD/C3S_511/DATA/icedepth/depth

# user scratch directory
scratchDIR=/Users/Luke/Documents/PHD/C3S_511/DATA/icedepth

# set mask directory (lakecover)
maskDIR=/Users/Luke/Documents/PHD/C3S_511/DATA/lakecover

# set starting directory
inDIR=/Users/Luke/Documents/PHD/C3S_511/DATA/icedepth/depth

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


# mask starting file
cdo -b F64 ifthen $maskDIR/lakemask.nc era5_lakes_icedepth_monthly_1979_2019.nc $scratchDIR/icedepth_monthly_1979_2019.nc

# ==============================================================================
# TIMMEANS & FLDMEANS
# ==============================================================================

#marker
echo ' '
echo 'TIMMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,1979-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $outDIR/timmean/era5_lakes_icedepth_timmean_${MONTHs[$i]}_1979_2018.nc

done


#marker
echo ' '
echo 'FLDMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L fldmean -selmon,$(($i+1)) -seldate,1979-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1979_2019.nc $outDIR/fldmean/era5_lakes_icedepth_fldmean_${MONTHs[$i]}_1979_2018.nc

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
    cdo -b F64 -O -L timmean -seldate,1979-01-01T00:00:00,1983-12-31T00:00:00 -selmon,$(($i+1)) $scratchDIR/icedepth_monthly_1979_2019.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_1979_1983_5year.nc

    # signal (last 5 years)
    cdo -b F64 -O -L timmean -seldate,2014-01-01T00:00:00,2018-12-31T00:00:00 -selmon,$(($i+1)) $scratchDIR/icedepth_monthly_1979_2019.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_2014_2018_5year.nc

    #signal (diff)
    cdo -b F64 -O -L sub $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_2014_2018_5year.nc $scratchDIR/era5_lakes_icedepth_${MONTHs[$i]}_1979_1983_5year.nc $outDIR/signal/era5_lakes_icedepth_signal_${MONTHs[$i]}_1979_2019.nc

done

rm $scratchDIR/era5_lakes*.nc

rm $scratchDIR/icedepth_monthly_1979_2019.nc
