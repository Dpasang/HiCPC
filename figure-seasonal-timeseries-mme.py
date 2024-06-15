import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr
import geocat.viz as gv

#随便设置一些内容
plt.rcParams['axes.unicode_minus'] = False
plt.rcParams.update({"font.size":12})
plt.rcParams['xtick.direction'] = 'out'#x刻度线方向
plt.rcParams['ytick.direction'] = 'out'#y轴的刻度方向
plt.rcParams['xtick.major.size'] = 10
plt.rcParams['ytick.major.size'] = 10

#读取数据
# date_range()生成时间序列
# day = pd.date_range(start="20200101", end="20201231", freq="D")  # freq="D"表示频率为每一天
day = pd.date_range("20200101",periods=366)  
bcsd = xr.open_dataset("shan/fldmean_bcsd_366days-mme.nc").pr.sel(lat=0,lon=0)
#NEX = xr.open_dataset("shan/fldmean_NEX_366days.nc").pr.sel(lat=0,lon=0)
gcm = xr.open_dataset("shan/fldmean_gcm_366days-mme.nc").PRECTOTLAND.sel(lat=0,lon=0)
obs = xr.open_dataset("shan/fldmean_obs_366days-mme.nc").ppt.sel(lat=0,lon=0)

df1 = pd.DataFrame(bcsd.values, index=day, columns=['Downscaled_MME'])  #'HRCDDP'])
#df2 = pd.DataFrame(NEX.values, index=day, columns=['NEX-GDDP'])
df3 = pd.DataFrame(gcm.values, index=day,columns=['GCM_MME'])
df4 = pd.DataFrame(obs.values, index=day,columns=['OBS'])

df = pd.concat([df1,df3,df4],axis=1)
#print(df)

fig, ax = plt.subplots(figsize=(7, 5))  ###  原始： (figsize=(4, 3))
pllt = df.plot(ax=ax,title='seasonal precipitation cycles', ylabel='Precipitation (mm/day)',color=('red','steelblue','black'))  #lightcoral
# pllt.set_yticks([10, 15, 20, 25, 30])  # 设置刻度值
# 设置次要刻度
# 获取 y 轴对象
y_axis = ax.yaxis
y_axis.set_minor_locator(plt.MultipleLocator(base=1))  # 设置次要刻度的间隔为1
# 关闭图例的边框
legend = ax.legend()
legend.set_frame_on(False)

#导出图片
fig = pllt.get_figure()
fig.savefig("SPM_fldmean_pr_366days.pdf",  transparent=True, dpi=600, pad_inches = 0.1, bbox_inches='tight')
fig.savefig("SPM_fldmean_pr_366days.png",  transparent=True, dpi=600, pad_inches = 0.1, bbox_inches='tight')

