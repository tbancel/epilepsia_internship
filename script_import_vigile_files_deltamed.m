% import .eeg file fieldtrip

folder_path_viewer = 'C:\Users\thomas.bancel\Documents\MATLAB\viewers20101111\';
folder_path_eeglab = 'C:\Users\thomas.bancel\Documents\MATLAB\eeglab14_1_1b\';
folder_path_ripplelab = 'C:\Users\thomas.bancel\Documents\MATLAB\RIPPLELAB-master';
folder_path_letswave6 = 'C:\Users\thomas.bancel\Documents\MATLAB\letswave6-master';
folder_path_brainstorm3 = 'C:\Users\thomas.bancel\Documents\MATLAB\brainstorm3';


addpath(genpath(folder_path_viewer));
addpath(genpath(folder_path_eeglab));
addpath(genpath(folder_path_ripplelab));
addpath(genpath(folder_path_letswave6));
addpath(genpath(folder_path_brainstorm3));

folder = 'C:\Users\thomas.bancel\Documents\data\data_mark_vigilance\20160722\EEG2\';
dataname = '160722a-b_0000.eeg';

datafile = strcat(folder, dataname);

% dat = ft_read_data(datafile);

% p_RippleLab
% eeglab
% br
% letswave6
brainstorm
