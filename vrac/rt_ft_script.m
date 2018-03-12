% script using fieldtrip

smr_filepath = 'C:\Users\thomas.bancel\Documents\charpier-internship\data\spike2files\1037 GAERS S1 2015_01_13 _M2.smr';

% DOES NOT WORK

% importing smr data into ft does not work.
% see with jime script
% ft_read_data(smr_filepath);

% .edf file
edf_filepath = 'C:\Users\thomas.bancel\Documents\data_patients_epilepsia\chb01_03.edf';
dat = ft_read_data(edf_filepath);

% .eeg .vhdr .vmrk
datafile   = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data\eeg_rt\Setup 12-15Hz\DJ18\DJ18.eeg';
headerfile = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data\eeg_rt\Setup 12-15Hz\DJ18\DJ18.vhdr';
eventfile  = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data\eeg_rt\Setup 12-15Hz\DJ18\DJ18.vmrk';

dat = ft_read_data(datafile);
