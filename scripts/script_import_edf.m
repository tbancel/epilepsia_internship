% script physionet database

% addpath(genpath('C:\Users\thomas.bancel\Documents\MATLAB\fieldtrip-20180228\'));
% 
% [FileName,PathName,FilterIndex] = uigetfile('*.edf', 'Get edf file');

clear; clc;
close all;

directory = pwd;
filelist = dir('*.edf');

for i=1:size(filelist, 1)
    filename = filelist(i).('name');
    dat = ft_read_data(filename);
    hdr = ft_read_header(filename);

    data.values = dat;
    data.filename = filename;
    data.interval = 1/hdr.Fs;
    data.edf_header = hdr;
   
    disp(filename);
    data.seizure_info =[];
    
    save(strcat('physionet_', data.filename, '.mat'), 'data')
end


% dt= data.interval;
% time = (1:size(data.values,2))*dt;
% 
% n_channel = size(data.values, 1);
% 
% figure
% for i=1:n_channel
%     subplot(n_channel, 1, i)
%     plot(time, data.values(i, :));
% end