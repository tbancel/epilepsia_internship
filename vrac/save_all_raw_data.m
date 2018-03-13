% script to save all data:
clc; clear;

directory = uigetdir(pwd);
current_folder = pwd;

cd(directory);
filelist = dir('*.mat');

n = size(filelist, 1);

for i=1:n
    filename = filelist(i).('name');
    
%     if contains(filename, 'boubou')
%         load(filename);
%         data.values = EEG.values;
%         data.timevector = EEG.timevector;
%         data.interval = EEG.interval;
%         data.seizure_info = [SWDOnset.values SWDEnd.values];
%         data.filename = filename;
%         
%         save(strcat(erase(filename, '.mat'), '_raw'),'data');
%     end
    
    if contains(filename, 'Theo')
        load(filename);
        data.values = EEGS1.values;
        data.timevector = EEGS1.timevector;
        data.interval = EEGS1.interval;
        data.seizure_info = crisis_info_matrix;
        data.filename = filename;
        
        save(strcat(erase(filename, '.mat'), '_raw'),'data');
    end
end
