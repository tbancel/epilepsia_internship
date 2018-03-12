clc; clear; close all;

folder = 'C:\Users\thomas.bancel\Documents\data\data_mybraintechnologies_thomas\';
cd(folder);

files = {'TB02LD_respi_charge.json', 'TB02VS_respi_normale.json'};

str = fileread(files{1});
dat = jsondecode(str);



