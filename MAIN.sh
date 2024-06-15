
GCM_name=ACCESS-CM2 #MPI-ESM1-2-HR  #ACCESS-CM2   #IITM-ESM   #CNRM-CM6-1 #CNRM-ESM2-1  #ACCESS-CM2
ssp=ssp585  #245  #585  #ssp126

work_DIR=$(pwd)
data_DIR=${work_DIR}/data

gcm_DIR=/data/ninglk/CMIP6_day/${GCM_name}                   
obs_DIR=/data/ninglk/CMFD-2016-new/prec-CMFD-01dy_010deg_1979-2014.nc

#OUTPUT_DIR=/data/ninglk/yhh/BCSD_master/OUTPUT/Pr/${GCM_name}/${ssp}  
OUTPUT_DIR=/data/ninglk/yhh/BCSD_master/OUTPUT/Pr-2100/${GCM_name}/${ssp}
if [ ! -d ${OUTPUT_DIR} ];then
  mkdir -p ${OUTPUT_DIR}
fi
if [ ! -d ${data_DIR} ];then
  mkdir -p ${data_DIR}
fi

#range=110,115,30,35
range=70,140,15,55  #China region

begyear=1979
endyear=2100 #2099
endyear_mark=2101 #2100
obs_splicing_year=2015 #If obs is obtained for the year 2014, then this value corresponds to the year 2015.

cat > script.sed << EOF
 s/2030/${endyear}/g
EOF
 sed -f script.sed data_prepare_obs.sh_BK > tmp1_obs.sh
 sed -f script.sed data_prepare_GCM.sh_BK > tmp2_gcm.sh

cat > script.sed << EOF
 s/1961/${begyear}/g
EOF
 sed -f script.sed  tmp1_obs.sh > tmp1.sh
 sed -f script.sed tmp2_gcm.sh > data_prepare_GCM.sh


cat > script.sed << EOF
 s/2031/${endyear_mark}/g
EOF
 sed -f script.sed tmp1.sh > tmp2.sh
cat > script.sed << EOF
 s/2022/${obs_splicing_year}/g
EOF
 sed -f script.sed tmp2.sh > data_prepare_obs.sh
rm script.sed tmp1.sh tmp2.sh

#data prepare
cd ${work_DIR} 
#./data_prepare_GCM.sh ${work_DIR} ${data_DIR} ${OUTPUT_DIR} ${gcm_DIR} ${range} ${GCM_name} ${ssp} ${begyear}  #${endyear} 
#./data_prepare_obs.sh ${work_DIR} ${data_DIR} ${OUTPUT_DIR} ${obs_DIR} ${range} ${GCM_name} ${begyear}  #${endyear} ${}

echo  "!!!!!!!!!!!!!!!! end prepare: data_prepare_GCM.sh & data_prepare_obs.sh  !!!!!!!!!!!!!!!!!"
echo  "!!!!!!!!!!!!!!!  Begin BCSD.sh  !!!!!!!!!!!!!!!!!"
###  BCSD.sh###
bash BCSD.sh ${GCM_name} ${OUTPUT_DIR} ${ssp}
echo  "!!!!!!!!!!!!!!!! end BCSD.sh !!!!!!!!!!!!!!!!!"




