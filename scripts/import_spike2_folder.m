% TO READ BEFORE LAUNCHING THE SCRIPT
%
% This script takes all '.smr' files in a specific folder and convert it to
% .mat files with the same name.

clc; clear; close all;
disp("Choose folder with .smr files to convert to .mat files");

directory = uigetdir;
cd(directory);

files = dir('*.smr')

for i=1:length(files)
    file = files(i);
    filename = file.name;
    filepath = strcat(directory, filename);
    convert_spike2_file_into_mat_file(filename, filepath)
end




