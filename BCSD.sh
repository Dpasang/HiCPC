#!/bin/sh
set -x
#pr
GCM_name=$1
OUTPUT_DIR=$2
ssp=$3

#GCM_name=MPI-ESM1-2-HR   #MRI-ESM2-0  #IITM-ESM   #CNRM-CM6-1 #CNRM-ESM2-1  #ACCESS-CM2
#OUTPUT_DIR=/data/ninglk/yhh/BCSD_master/OUTPUT/Pr/${GCM_name}
#ssp=ssp585  #245  #370


if [ ! -d ${OUTPUT_DIR} ];then
 mkdir -p ${OUTPUT_DIR}
fi
#```bash
cd data

#cdo -b F32 copy gcm.nc gcm_32bit.nc 
#########  
#cdo sellonlatbox,70,96,15,37 obs_cn051.nc shan-obs-00000.nc
#cdo sellonlatbox,92,118,15,37 obs_cn051.nc shan-obs-00001.nc
#cdo sellonlatbox,114,140,15,37 obs_cn051.nc shan-obs-00002.nc
#cdo sellonlatbox,70,96,33,55 obs_cn051.nc shan-obs-00003.nc
#cdo sellonlatbox,92,118,33,55 obs_cn051.nc shan-obs-00004.nc
#cdo sellonlatbox,114,140,33,55 obs_cn051.nc shan-obs-00005.nc

#cdo sellonlatbox,70,96,15,37 gcm_32bit.nc shan-gcm-00000.nc
#cdo sellonlatbox,92,118,15,37 gcm_32bit.nc shan-gcm-00001.nc
#cdo sellonlatbox,114,140,15,37 gcm_32bit.nc shan-gcm-00002.nc
#cdo sellonlatbox,70,96,33,55 gcm_32bit.nc shan-gcm-00003.nc
#cdo sellonlatbox,92,118,33,55 gcm_32bit.nc shan-gcm-00004.nc
#cdo sellonlatbox,114,140,33,55 gcm_32bit.nc shan-gcm-00005.nc

#for no in {0..5}  ;do
for no in {0..4} ;do
NO=$no
if [ $no -lt 10 ]; then
NO=0$no
fi
echo $NO
rm merra_bcsd-000${NO}.nc

#prism='prism_example.nc'
#prism='obs_cn051.nc'
 prism=shan-obs-000${NO}.nc
echo " prism= " ${prism}

# merra='gcm_32bit.nc'
  merra=shan-gcm-000${NO}.nc
echo " merra= " ${merra}

prism_upscaled='prism_upscaled.nc'
merra_filled='merra_filled.nc'
# obs_grid='elev_CMFD_010deg.nc'  

cdo griddes $merra > merra_grid
cdo setmissval,nan $prism temp_miss.nc  #nan
cdo fillmiss temp_miss.nc tmp.nc   #miss
cdo setmissval,-9999 tmp.nc tmp_filled.nc
cdo remapbil,merra_grid -gridboxmean,3,3 tmp_filled.nc $prism_upscaled #3*3

cdo fillmiss $merra $merra_filled
rm tmp_filled.nc

### Bias Correction
 python ../merra_prism_example.py $prism_upscaled $merra_filled ppt PRECTOTLAND merra_bc-000${NO}.nc
echo  "!!!!!!!!!!!!!!!! end BC !!!!!!!!!!!!!!!!!"
#

### Spatial Disaggregation - Scaling
#### Remap Bias Corrected Merra to the High Resolution Prism
#```bash
 cdo griddes $prism > prism_grid
#cdo griddes $obs_grid > prism_grid   #elev_CMFD_010deg.nc 0.1°
cdo remapbil,prism_grid merra_bc-000${NO}.nc merra_bc_interp-000${NO}.nc 
#


#### Interpolate upscaled Prism to Original Resolution
#```bash
cdo remapbil,prism_grid $prism_upscaled prism_reinterpolated.nc

#### Compute scaling Factors
#```bash
cdo ydayavg prism_reinterpolated.nc prism_interpolated_ydayavg.nc
cdo ydayavg $prism prism_ydayavg.nc
cdo div prism_ydayavg.nc prism_interpolated_ydayavg.nc scale_factors.nc
#


#### Execute Spatial Scaling
  cdo -b F32 copy merra_bc_interp-000${NO}.nc 1.nc
  mv 1.nc merra_bc_interp-000${NO}.nc 
  python ../spatial_scaling.py merra_bc_interp-000${NO}.nc scale_factors.nc merra_bcsd-000${NO}.nc
echo  "!!!!!!!!!!!!!!!! end SD !!!!!!!!!!!!!!!!!"


#### Masking (optional)
#```bash
#cdo seltimestep,1 -div -addc,1 $prism -addc,1 $prism mask.nc
#cdo mul mask.nc merra_bcsd.nc merra_bcsd_masked.nc
echo  "!!!!!!!!!!!!!!!! end BCSD.sh !!!!!!!!!!!!!!!!!   NO " ${NO}

done 


#########
rm merra_bcsd.nc
# cdo collgrid merra_bcsd-000*.nc merra_bcsd.nc

#cp gcm.nc gcm_32bit.nc merra_bcsd.nc  ${OUTPUT_DIR}
cp merra_bcsd-000*nc ${OUTPUT_DIR}

echo  "!!!!!!!!!!!!!!!! end BCSD all !!!!!!!!!!!!!!!!! "  
#```
