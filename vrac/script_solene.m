clc; clear; close all;

addpath('C:\Users\thomas.bancel\Documents\MATLAB\fieldtrip-20180228\');
ft_defaults

datafile   = 'C:\Users\thomas.bancel\Documents\data\data_solene_eeg\NUTRIDIET_2018-04-16_S01_1.eeg';
headerfile = 'C:\Users\thomas.bancel\Documents\data\data_solene_eeg\NUTRIDIET_2018-04-16_S01_1.vhdr';
eventfile  = 'C:\Users\thomas.bancel\Documents\data\data_solene_eeg\NUTRIDIET_2018-04-16_S01_1.vmrk';

% % To read all data 
full_header = ft_read_header(headerfile);
full_data = ft_read_data(datafile);

recording_duration = size(full_data, 2)/full_header.Fs*1/3600; %in hours
