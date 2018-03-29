clc; clear;

addpath(genpath('C:\Users\thomas.bancel\Documents\MATLAB\SON_library\'))
folder = 'C:\Users\thomas.bancel\Documents\data\data_spike2\';
cd(folder)


list = dir('*.smr')
n_files = size(list, 1);

for i=1:n_files
    filename = list(i).('name');
    
    fid = fopen(strcat(folder, filename));
    [eeg_s1, header_s1] = SONGetChannel(fid, 2, 'scale'); % EEG S1

    n_eeg = size(eeg_s1',2);
    timevector = (1:n_eeg)*header_s1.sampleinterval*10^(-6);

    [puffs, header_puffs] = SONGetChannel(fid, 4, 'scale'); % Puffs

    n_puffs = size(puffs',2);
    timevector_puffs = (1:n_puffs)*header_puffs.sampleinterval*10^(-6);

    % Creating output structure:
    name_to_save = strcat(erase(filename, ["_", ".smr"]), '_Mark_GAERS.mat');

    data.filename = name_to_save;

    data.interval_eeg_s1 = header_s1.sampleinterval*10^(-6);
    data.values_eeg_s1 = eeg_s1';
    data.timevector_eeg_s1 = timevector;

    data.interval_puffs = header_puffs.sampleinterval*10^(-6);
    data.values_puffs = puffs';
    data.timevector_puffs = timevector_puffs;

    save(name_to_save, 'data')
    
end

% figure(1)
% subplot(2,1,1)
% plot(timevector, eeg_s1)
% subplot(2,1,2)
% plot(timevector_puffs, puffs)






