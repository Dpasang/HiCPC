import xarray as xr
import argparse

# parse arguments 解析参数
parser = argparse.ArgumentParser()
parser.add_argument('bias_corrected', help="The bias corrected gcm or reanalysis file.")
parser.add_argument('scale_file', help="Netcdf file withe scaling factors.")
parser.add_argument('fout', help='BCSD output file')
args = parser.parse_args()
args = vars(args)

scale = xr.open_dataset(args['scale_file'])
bc = xr.open_dataset(args['bias_corrected'])


scaledayofyear = scale['time.dayofyear']

# align indices
print("Grouping")
scale = scale.groupby('time.dayofyear').mean('time')
scale['lat'] = bc.lat
scale['lon'] = bc.lon

daydata = []
for key, val in bc.groupby('time.dayofyear'):
    # print(key)
    # multiply interpolated by scaling factor
    if key == 366:
        key = 365
    daydata += [val.bias_corrected * scale.sel(dayofyear=key)]

# join all days
bcsd = xr.concat(daydata, 'time')
bcsd = bcsd.sortby('time')


bcsd.to_netcdf(args['fout'])
