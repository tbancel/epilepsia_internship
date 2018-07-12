close all;
clc;
clear;


eeg_folder = '\\10.5.42.1\reve\TeamCharpier\Projet T Bancel\20180330\EEG2\matfiles\';
filename= '180330A-A_0016.mat';

channel_numbers = (11:14);

load(strcat(eeg_folder, filename));

sub_p = [];

f=figure
for i=channel_numbers
    a = genvarname(strcat('h',num2str(i)));
    a = subplot(5,1, mod(i,5))
    plot(data.time, -data.values(i,:));
    ylabel(data.electrodes{mod(i,5)});
    sub_p = [sub_p a];
end

linkaxes(sub_p, 'x');