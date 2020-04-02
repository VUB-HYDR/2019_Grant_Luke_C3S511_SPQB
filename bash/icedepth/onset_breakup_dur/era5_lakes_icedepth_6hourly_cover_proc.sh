#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# April 1st

# Operations on C3S_511 ice depth files:
    # daily aggregation & file merging
    # calculation of ice start/end/duration and timmeans
    # fldmeans of ice start/end/duration
    # signal between two 5-year means

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5/icedepth/cover_v2

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant/era5/proc/icecover

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5/lakes/icedepth

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
cdo -b F64 -O -L setreftime,1979-01-01,00:00:00,1day -settaxis,1979-01-01,00:00:00,1day -gtc,0.001 -daymin era5_lakes_icedepth_6hourly_1979_2019_v2.nc $scratchDIR/startfile.nc


# mask starting file
cdo ifthen $maskDIR/lakemask.nc $scratchDIR/startfile.nc $scratchDIR/icecover_daily_1979_2019.nc


rm $scratchDIR/startfile.nc

# ==============================================================================
# ICE START
# ==============================================================================

#marker for stderr ice start
echo ' '
echo 'ICE START CALC'
echo ' '


# select October to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,10/12 -seldate,1979-01-01T00:00:00,2019-01-01T00:00:00 $scratchDIR/icecover_daily_1979_2019.nc $scratchDIR/icecover_daily_1979_2019_part1.nc


# select January to September for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/9 -seldate,1980-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icecover_daily_1979_2019.nc $scratchDIR/icecover_daily_1979_2019_part2.nc


# merge selections
cdo -b F64 mergetime $scratchDIR/icecover_daily_1979_2019_part1.nc $scratchDIR/icecover_daily_1979_2019_part2.nc $scratchDIR/dummy_final.nc


rm $scratchDIR/icecover_daily_1979_2019_part*.nc


for i in $(seq 1979 2018); do

    # ice start
    cdo -b F64 -O -L timmin -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $scratchDIR/dummy_final.nc $scratchDIR/dummy_start_$i.nc

done


rm $scratchDIR/dummy_final.nc


cdo -b F64 -O mergetime $scratchDIR/dummy_start_*.nc $scratchDIR/icecover_start_1979_2019_dummy.nc


rm $scratchDIR/dummy_start_*.nc


cdo -b F64 -O -L setreftime,1979-01-01,00:00:00,1years -settaxis,1979-01-01,00:00:00,1years -setattribute,icestart@long_name='First day of lake ice cover' -setname,'icestart' -setunit,"day of hydrological year" $scratchDIR/icecover_start_1979_2019_dummy.nc $outDIR/era5_lakes_icecover_start_1979_2019.nc


# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,1979-01-01T00:00:00,1988-12-31T00:00:00 $outDIR/era5_lakes_icecover_start_1979_2019.nc $scratchDIR/era5_lakes_icecover_start_1979_1988_10year.nc


# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $outDIR/era5_lakes_icecover_start_1979_2019.nc $scratchDIR/era5_lakes_icecover_start_2010_2019_10year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5_lakes_icecover_start_2010_2019_10year.nc $scratchDIR/era5_lakes_icecover_start_1979_1988_10year.nc $outDIR/era5_lakes_icecover_start_signal_1979_2019.nc


rm $scratchDIR/era5_lakes_icecover_start_1979_1988_10year.nc
rm $scratchDIR/era5_lakes_icecover_start_2010_2019_10year.nc
rm $scratchDIR/icecover_start_1979_2019_dummy.nc

# ==============================================================================
# ICE END
# ==============================================================================

#marker for stderr ice end
echo ' '
echo 'ICE END CALC'
echo ' '


# select September to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,9/12 -seldate,1979-01-01T00:00:00,2019-01-01T00:00:00 $scratchDIR/icecover_daily_1979_2019.nc $scratchDIR/icecover_daily_1979_2019_part1.nc


# select January to August for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/8 -seldate,1980-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icecover_daily_1979_2019.nc $scratchDIR/icecover_daily_1979_2019_part2.nc


# merge selections
cdo -b F64 mergetime $scratchDIR/icecover_daily_1979_2019_part1.nc $scratchDIR/icecover_daily_1979_2019_part2.nc $scratchDIR/dummy_final.nc


rm $scratchDIR/icecover_daily_1979_2019_part*.nc


for i in $(seq 1979 2018); do

    # ice start
    cdo -b F64 -O -L timmax -seldate,$i-09-01T00:00:00,$(($i+1))-08-31T00:00:00 $scratchDIR/dummy_final.nc $scratchDIR/dummy_end_$i.nc

done


rm $scratchDIR/dummy_final.nc


cdo -b F64 -O mergetime $scratchDIR/dummy_end_*.nc $scratchDIR/icecover_end_1979_2019_dummy.nc


rm $scratchDIR/dummy_end_*.nc


cdo -b F64 -O -L setreftime,1979-01-01,00:00:00,1years -settaxis,1979-01-01,00:00:00,1years -setattribute,iceend@long_name='Last day of lake ice cover' -setname,'iceend' -setunit,"day of hydrological year" $scratchDIR/icecover_end_1979_2019_dummy.nc $outDIR/era5_lakes_icecover_end_1979_2019.nc


# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,1979-01-01T00:00:00,1988-12-31T00:00:00 $outDIR/era5_lakes_icecover_end_1979_2019.nc $scratchDIR/era5_lakes_icecover_end_1979_1988_10year.nc


# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $outDIR/era5_lakes_icecover_end_1979_2019.nc $scratchDIR/era5_lakes_icecover_end_2010_2019_10year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5_lakes_icecover_end_2010_2019_10year.nc $scratchDIR/era5_lakes_icecover_end_1979_1988_10year.nc $outDIR/era5_lakes_icecover_end_signal_1979_2019.nc


rm $scratchDIR/era5_lakes_icecover_end_1979_1988_10year.nc
rm $scratchDIR/era5_lakes_icecover_end_2010_2019_10year.nc
rm $scratchDIR/icecover_end_1979_2019_dummy.nc

# ==============================================================================
# DURATION
# ==============================================================================


#marker for stderr ice dur
echo ' '
echo 'ICE DURATION CALC'
echo ' '


for i in $(seq 1979 2018); do

    # ice duration
    cdo -b F64 -L timsum -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $scratchDIR/icecover_daily_1979_2019.nc $scratchDIR/dummy_duration_$i.nc

done


cdo -b F64 mergetime $scratchDIR/dummy_duration_*.nc $scratchDIR/icecover_duration_1979_2019_dummy.nc


rm $scratchDIR/dummy_duration_*.nc


cdo -b F64 -O -L setctomiss,0 -setreftime,1979-01-01,00:00:00,1years -settaxis,1979-01-01,00:00:00,1years -setattribute,iceduration@long_name='Days of lake ice cover' -setname,'iceduration' -setunit,"days" $scratchDIR/icecover_duration_1979_2019_dummy.nc $outDIR/era5_lakes_icecover_duration_1979_2019.nc


# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,1979-01-01T00:00:00,1988-12-31T00:00:00 $outDIR/era5_lakes_icecover_duration_1979_2019.nc $scratchDIR/era5_lakes_icecover_dur_1979_1988_10year.nc


# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $outDIR/era5_lakes_icecover_duration_1979_2019.nc $scratchDIR/era5_lakes_icecover_dur_2010_2019_10year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5_lakes_icecover_dur_2010_2019_10year.nc $scratchDIR/era5_lakes_icecover_dur_1979_1988_10year.nc $outDIR/era5_lakes_icecover_dur_signal_1979_2019.nc


rm $scratchDIR/era5_lakes_icecover_dur_1979_1988_10year.nc
rm $scratchDIR/era5_lakes_icecover_dur_2010_2019_10year.nc
rm $scratchDIR/icecover_duration_1979_2019_dummy.nc

# ==============================================================================
# GLOBAL MEANS
# ==============================================================================

#ice start fldmeans
cdo -b F64 fldmean $outDIR/era5_lakes_icecover_start_1979_2019.nc $outDIR/era5_lakes_icecover_start_global_fldmean_1979_2019.nc


#ice end fldmeans
cdo -b F64 fldmean $outDIR/era5_lakes_icecover_end_1979_2019.nc $outDIR/era5_lakes_icecover_end_global_fldmean_1979_2019.nc


#ice duration fldmeans
cdo -b F64 fldmean $outDIR/era5_lakes_icecover_duration_1979_2019.nc $outDIR/era5_lakes_icecover_duration_global_fldmean_1979_2019.nc


#daily ice cover fieldsum
cdo -b F64 -L fldsum -setctomiss,0 $scratchDIR/icecover_daily_1979_2019.nc $outDIR/era5_lakes_icecover_duration_global_fldmean_1979_2019.nc

# ==============================================================================
# TEMPORAL MEANS
# ==============================================================================

#ice start fldmeans
cdo -b F64 timmean $outDIR/era5_lakes_icecover_start_1979_2019.nc $outDIR/era5_lakes_icecover_start_global_timmean_1979_2019.nc


#ice end fldmeans
cdo -b F64 timmean $outDIR/era5_lakes_icecover_end_1979_2019.nc $outDIR/era5_lakes_icecover_end_global_timmean_1979_2019.nc


#ice duration fldmeans
cdo -b F64 timmean $outDIR/era5_lakes_icecover_duration_1979_2019.nc $outDIR/era5_lakes_icecover_duration_global_timmean_1979_2019.nc

# ==============================================================================
# CLEANUP
# ==============================================================================

rm $scratchDIR/icecover_daily_1979_2019.nc
