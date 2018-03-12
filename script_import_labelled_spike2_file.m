% Takes a .smr files and convert it to right .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEGINNING OF THE SCRIPT

clc; clear; close all;
current_directory = pwd;
disp("Choose file to convert to .mat");

[FileName,PathName,FilterIndex] = uigetfile('*.*', 'Select file to convert to .mat');
filepath=strcat(PathName, FileName);
fid = fopen(filepath);

% Change folder
cd(PathName);

% to import only EEG, Vm, Puffs
% convert_spike2_file_into_mat_file(FileName, filepath);

% to import a specific channel
channel_kind = 1;
channel_number_to_extract = 1
get_channel_struct_from_spike2file(filepath, channel_number_to_extract, channel_kind)


disp(PathName)

% Get back to initial folder
cd(current_directory);

clear; close all;
