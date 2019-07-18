#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on C3S_511 ice depth files to calculate percentiles:
    # daily aggregation
    # mask for inland water bodies
    # timmin and max; then percentiles

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

# percentiles
PERCENTs=('1' '5' '10' '50' '90' '95' '99')

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
cdo -b F64 -O -L setreftime,1979-01-01,00:00:00,1days -settaxis,1979-01-01,00:00:00,1days -daymean era5_lakes_icedepth_6hourly_1979_2019.nc $scratchDIR/startfile.nc


# mask starting file
cdo ifthen $maskDIR/lakemask.nc $scratchDIR/startfile.nc $scratchDIR/icedepth_daily_1979_2019.nc


rm $scratchDIR/startfile.nc

# ==============================================================================
# PERCENTILE BOUNDS
# ==============================================================================

#marker
echo ' '
echo 'BOUNDS CALC'
echo ' '


cdo timmin $scratchDIR/icedepth_daily_1979_2019.nc $scratchDIR/minfile.nc


cdo timmax $scratchDIR/icedepth_daily_1979_2019.nc $scratchDIR/maxfile.nc

# ==============================================================================
# PERCENTILES
# ==============================================================================

#marker
echo ' '
echo 'PERCENTILES CALC'
echo ' '


cdo timpctl,90 ifile minfile maxfile ofile


for PERC in "${PERCENTs[@]}"; do

    cdo -b F64 -O -L timpctl,$((${PERC}+0)) $scratchDIR/icedepth_daily_1979_2019.nc $scratchDIR/minfile.nc $scratchDIR/maxfile.nc $outDIR/era5_lakes_icedepth_percentile_${PERC}.nc

done


rm $scratchDIR/icedepth_daily_1979_2019.nc
rm $scratchDIR/minfile.nc
rm $scratchDIR/maxfile.nc
