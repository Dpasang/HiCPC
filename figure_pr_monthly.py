import os
import sys
# import netCDF4 as nc
import warnings

import cartopy.crs as ccrs
import cartopy.feature as cfeature
import cmaps
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import proplot as pplt
import salem
import xarray as xr
from cartopy.io.shapereader import Reader
from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
from geocat.viz import util as gvutil
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import matplotlib.colors as mcolors
warnings.filterwarnings("ignore")

shp_nine = '/data/ninglk/yhh/BCSD_master/pic_DIR/shpfile/ninelines.shp'
shp_chn = '/data/ninglk/yhh/BCSD_master/pic_DIR/shpfile/China.shp'
proj = ccrs.PlateCarree()  # 创建坐标系
chnreader = Reader(shp_chn)
china = cfeature.ShapelyFeature(chnreader.geometries(), proj, edgecolor='k', facecolor='none')
nlreader = Reader(shp_nine)
ninel = cfeature.ShapelyFeature(nlreader.geometries(), proj, edgecolor='k', facecolor='none')
chnshp=gpd.read_file(shp_chn)

data_dir = "shan"
bcsd = xr.open_dataset(os.path.join(data_dir,'monthly-bcsd_2005-2014.nc')).pr.mean(dim='time')
gcm = xr.open_dataset(os.path.join(data_dir,'monthly-gcm_2005-2014.nc')).PRECTOTLAND.mean(dim='time')  #.salem.roi(shape=chnshp)
#NEX = xr.open_dataset(os.path.join(data_dir,'monthly-NEX_2005-2014.nc')).pr.mean(dim='time')  #.salem.roi(shape=chnshp)
obs = xr.open_dataset(os.path.join(data_dir,'monthly-obs_2005-2014.nc')).ppt.mean(dim='time')

# 定义一个标准中国区 ALBERS 投影
Alberts_China = ccrs.AlbersEqualArea(
    central_longitude=105, standard_parallels=(25.0, 47.0))
#newmap = cmaps.MPL_YlGn
newmap = cmaps.cmocean_algae

# pplt.rc.fontname = 'DejaVu Sans'
#rrticks = np.arange(0, 8, 1.0)
rrticks = np.arange(0, 300, 30.0)
f, axs = pplt.subplots(proj=Alberts_China, nrows=1, ncols=3, share=True)

data = [obs, gcm, bcsd]
for i in range(0,3):
    m = axs[i].contourf(data[i].salem.roi(shape=chnshp),
                        extend="both",
                        cmap=newmap,
                        levels=rrticks,
                        norm="segmented",)
    # 创建插入图的坐标轴
    ax_inset = inset_axes(axs[i], width="33%", height="33%", loc="lower left", 
                          bbox_to_anchor=(0.18, 0.03, 0.8, 0.8), 
                          bbox_transform=axs[i].transAxes)
    ax_inset.hist(data[i].values.flatten(), bins=10, density=True, alpha=0.7, lw=0.5, color='lightgray')
    ax_inset.set_ylabel('pdf')
    # 隐藏插入图的右边和上边框线
    ax_inset.spines['right'].set_visible(False)
    ax_inset.spines['top'].set_visible(False)
    # 移除图中图的网格线
    ax_inset.grid(False)
    # 设置图中图的背景色为透明
    ax_inset.set_facecolor('none')
    # 设置图中图轴标签朝内
    ax_inset.tick_params(axis='both', which='both', direction='in')

    axs[i].add_feature(china, linewidth=0.5)
    axs[i].add_feature(ninel, linewidth=0.5)

axs.format(
    # abc = '(a)',
    # abcloc="ul",
    # abcsize=16,
    # labels=True,
    # ticklabelsize='10',
    lonlines=10,
    latlines=10,
    latlim=(0, 55),
    lonlim=(80, 130),
    grid=False,
    xticklabels=False,
    yticklabels=False)

axs.axis('off')

cbar = f.colorbar(m, loc='r', width=0.12, drawedges=False, tickdir='in', label='precipitation (mm/month)')

f.save('111-Fig3-Spatial_distribution_Pr-monthly-2005-2014.jpg', transparent=True, dpi=600, pad_inches = 0.05, bbox_inches='tight')

