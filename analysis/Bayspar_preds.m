%% User needs to download BAYSPAR package

%import excel file using an update filepath within BAYSPAR package
fn = ('CascadiaMargin_index_values.csv')

%convert to table
tbl = readtable(fn)

%set prior std - can be narrow since we know what temp should be
p_std = 6

%slice out TEX86 values for AC, HR, and MC:
ac_tex86 = tbl.TEX86_corr(1:8)
hr_tex86 = tbl.TEX86_corr(9:24)
mc_tex86 = tbl.TEX86_corr(25:37)

%input latitude and longitude of each location
ac_lat_lon = [46.13,-124.39]
mc_lat_lon = [45.85,-124.89]
hr_lat_lon = [44.57,-125.148]

%run baysparto predict SST from TEX86
ac_pred = bayspar_tex(ac_tex86,ac_lat_lon(2),ac_lat_lon(1),p_std,'SST')
hr_pred = bayspar_tex(hr_tex86,hr_lat_lon(2),hr_lat_lon(1),p_std,'SST')
mc_pred = bayspar_tex(mc_tex86,mc_lat_lon(2),mc_lat_lon(1),p_std,'SST')

%retrieve 50th percentile
ac_pred_50th = ac_pred.Preds(:,2)
hr_pred_50th = hr_pred.Preds(:,2)
mc_pred_50th = mc_pred.Preds(:,2)

%inferred TEX86 values from model
inf_ac = 0.66
inf_hr = 0.56
inf_mc = 0.46

%calculate SST from average inferred SST
sst_inf_ac = bayspar_tex(inf_ac,ac_lat_lon(2),ac_lat_lon(1),p_std,'SST')
sst_inf_mc = bayspar_tex(inf_mc,mc_lat_lon(2),mc_lat_lon(1),p_std,'SST')
sst_inf_hr = bayspar_tex(inf_hr,hr_lat_lon(2),hr_lat_lon(1),p_std,'SST')

%calculate predicted TEX86
SST_CM = 13 %annual average of SST along study sites
ac_= TEX_forward(ac_lat_lon(1),ac_lat_lon(2),SST_CM,'SST')
mc_= TEX_forward(mc_lat_lon(1),mc_lat_lon(2),SST_CM,'SST')
hr_= TEX_forward(hr_lat_lon(1),hr_lat_lon(2),SST_CM,'SST')

%sort values
sorted_ac= sort(ac_)
sorted_mc= sort(mc_)
sorted_hr= sort(hr_)

%concatenate and take average to produce one vector
ac_mc_hr = cat(3, sorted_ac, sorted_mc,sorted_hr)
avg_pred = mean(ac_mc_hr, 3);
