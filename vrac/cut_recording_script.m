clc; clear; close all;

files = {'20170213_Theo_GAERS_Data4_78SWD.mat';
    '20170307_Theo_GAERS_Data3_50SWD.mat';
    '20170329_Theo_GAERS_Data4_29SWD.mat';
    '20170419_Theo_GAERS_Data5_76SWD.mat'};

i=4;
load(files{i});
start_time = 0;
end_time = 1000; % in second decide when you want to cut the file

dt_eeg = EEGS1.interval;
index_eeg = floor(end_time/dt_eeg);

EEGS1.values = EEGS1.values(1:index_eeg);
EEGS1.timevector = EEGS1.timevector(1:index_eeg);
EEGS1.length = index_eeg;

dt_puff = Puffs.interval;
index_puff = floor(end_time/dt_puff);

Puffs.values = Puffs.values(1:index_puff);
Puffs.timevector = Puffs.timevector(1:index_puff);
Puffs.length = index_puff;

crisis_info_matrix = [];

