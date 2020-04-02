#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# April 1st

# Operations on C3S_511 mixed layer temperature files:
    # masking for inland water bodies
    # selection of seasonal averages: 1) temporal average (spatial plots per season) and 2) global/annual means (time series per season)
    # global/annual means on monthly series for time series
    # seasonal signals (between two 5-year means)

# =======================================================================
# INITIALIZATION
# =======================================================================

# load CDO
module load CDO

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/mixlayertemp_v2

# set scratch directory
scratchDIR=/theia/scratch/brussel/101/vsc10116/C3S_511/mixlayertemp

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/101/vsc10116/C3S_511/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5/lakes/mixlayertemp

# seasons
SEASONs=('DJF' 'MAM' 'JJA' 'SON')

# ==============================================================================
# PROCESSING
# ==============================================================================

cd $inDIR
pwd

cdo -b F64 monmean era5_lakes_mixlayertemp_6hourly_1979_2019_v2.nc $scratchDIR/era5_lakes_mixlayertemp_monthly.nc

# mask starting file
cdo -b F64 ifthen $maskDIR/lakemask.nc $scratchDIR/era5_lakes_mixlayertemp_monthly.nc $scratchDIR/startfile.nc


# seasonal files to operate on
cdo -b F64 -O -L yearmean -selmon,12,1,2 $scratchDIR/startfile.nc $scratchDIR/mixlayertemp_DJF_1979_2019.nc
cdo -b F64 -O -L yearmean -selmon,3/5 $scratchDIR/startfile.nc $scratchDIR/mixlayertemp_MAM_1979_2019.nc
cdo -b F64 -O -L yearmean -selmon,6/8 $scratchDIR/startfile.nc $scratchDIR/mixlayertemp_JJA_1979_2019.nc
cdo -b F64 -O -L yearmean -selmon,9/11 $scratchDIR/startfile.nc $scratchDIR/mixlayertemp_SON_1979_2019.nc


# global annual mean time series
cdo -b F64 -O -L fldmean -yearmonmean $scratchDIR/startfile.nc $outDIR/era5_lakes_mixlayertemp_global_annual_fldmean_1979_2019.nc


for SEASON in "${SEASONs[@]}"; do

    # global mean time series for seasons
    cdo -b F64 -O fldmean $scratchDIR/mixlayertemp_${SEASON}_1979_2019.nc $outDIR/era5_lakes_mixlayertemp_${SEASON}_global_annual_fldmean_1979_2019.nc

    # temporal mean for seasonal average maps
    cdo -b F64 -O timmean $scratchDIR/mixlayertemp_${SEASON}_1979_2019.nc $outDIR/era5_lakes_mixlayertemp_${SEASON}_timmean_1979_2019.nc

    # signal for seasonal average maps (first 5 years)
    cdo -b F64 -O -L timmean -seldate,1979-01-01T00:00:00,1988-12-31T00:00:00 $scratchDIR/mixlayertemp_${SEASON}_1979_2019.nc $scratchDIR/mixlayertemp_${SEASON}_10year_start.nc

    # signal for seasonal average maps (last 5 years)
    cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/mixlayertemp_${SEASON}_1979_2019.nc $scratchDIR/mixlayertemp_${SEASON}_10year_end.nc

    #signal for seasonal average maps (diff)
    cdo -b F64 -O -L sub $scratchDIR/mixlayertemp_${SEASON}_10year_end.nc $scratchDIR/mixlayertemp_${SEASON}_10year_start.nc $outDIR/era5_lakes_mixlayertemp_${SEASON}_signal_1979_2019.nc

    # remove temporary files per season
    rm $scratchDIR/mixlayertemp_${SEASON}_1979_2019.nc
    rm $scratchDIR/mixlayertemp_${SEASON}_10year_end.nc
    rm $scratchDIR/mixlayertemp_${SEASON}_10year_start.nc

done


rm $scratchDIR/startfile.nc
rm $scratchDIR/era5_lakes_mixlayertemp_monthly.nc

