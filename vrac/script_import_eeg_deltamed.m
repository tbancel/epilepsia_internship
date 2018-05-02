% script vigilance

folder_path = 'C:\Users\thomas.bancel\Documents\data\data_mark_vigilance\';
filename_eeg = 'essai-thomas2.edf';
filename_mat = '20160729_Mark_stim_vigilance.mat';

datafile = strcat(folder_path, filename_eeg);
dat = ft_read_data(datafile);
