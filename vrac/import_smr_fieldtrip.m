% In this script, I am trying to load .smr files in the fieldtrip structure using a .dll file found online.
% However it does not work. I will use the SON library.

clc; clear;
close all;
% import .smr files using fieldtrip

addpath('C:\Users\thomas.bancel\Documents\MATLAB\nsMCDLibrary_3.7b\Matlab\Matlab-Import-Filter\Matlab_Interface\');
addpath('C:\Users\thomas.bancel\Documents\MATLAB\fieldtrip-20180228\');
ft_defaults

smr_filepath = 'C:\Users\thomas.bancel\Documents\Crises annotées Mark\557 GAERS S1 2015_10_19\557 GAERS S1 2015_10_19 _M.smr';
smrx_filepath = 'C:\Users\thomas.bancel\Documents\Crises annotées Mark\557 GAERS S1 2015_10_19\smrx557 GAERS S1 2015_10_19.smrx';

smr_header = 'C:\Users\thomas.bancel\Documents\Crises annotées Mark\557 GAERS S1 2015_10_19\557 GAERS S1 2015_10_19 _M.S2R';
smrx_header = 'C:\Users\thomas.bancel\Documents\Crises annotées Mark\557 GAERS S1 2015_10_19\557 GAERS S1 2015_10_19 _M.s2rx';


% dll_name = 'C:\Users\thomas.bancel\Documents\MATLAB\nsMCDLibrary_3.7b\Matlab\Matlab-Import-Filter\Matlab_Interface\nsMCDLibrary64.dll';
dll_name = 'C:\Users\thomas.bancel\Documents\MATLAB\nsMCDLibrary_3.7b\Matlab\Matlab-Import-Filter\Matlab_Interface\nscedsmrx.dll';


[result] = ns_SetLibrary(dll_name) % give 0 
% ft_read_data(smr_filepath) 

[nsresult, hfile] = ns_OpenFile(smrx_filepath)
[nsresult,info]= ns_GetFileInfo(hfile)

% Find out about the Entity types
% Then read specific entity info and data

% Trigger
[nsresult,entity] = ns_GetEntityInfo(hfile,1)
[nsresult,event] = ns_GetEventInfo(hfile,1)
[nsresult,timestamp,data,datasize] = ns_GetEventData(hfile,1,1)

% Digital data
[nsresult,entity] = ns_GetEntityInfo(hfile,9)
[nsresult,analog] = ns_GetAnalogInfo(hfile,9)