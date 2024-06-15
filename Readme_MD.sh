#This directory is for BCSD-daily workspace
#Observation is not used after 2014

#work_DIR=bcsd-python
work_dir=bcsd-python


#Data preparation
cd ${work_DIR}
cd 
 ./prepare.sh    
#./prepare.sh &> xxxxxx.log  #（后台处理）)
         #(说明，在prepare.sh中修改降尺度设置，包括：区域、时长、数据、路径）

#BCSD
conda activate geoclim
cd ${work_DIR} 
bash BCSD.sh   #  bash BCSD.sh &> xxxxxx-bcsd.log  #（后台处理）)


#后处理
#新开窗口
cd ${work_DIR}/data
source ~/.bashrc
./POSTPRO_1.sh
    #其中包括：1.时间序列图的数据处理
    # ./postpro_timeseries.sh
    #2.水平分布图的数据处理
    # ./postpro_spatial.sh


cd timeseries  #时间序列图
 plot_timeseries.gs  #Grads画图
cd spatial #水平分布图
plot-spatial.gs  #Grads画图





