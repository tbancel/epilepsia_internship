clc; clear;

filelist = dir('*.mat')
n_files = size(filelist, 1);

figure(1)

for i=1:n_files
    filename = filelist(i).('name');
    load(filename);
    
    subplot(5,2,i)
    plot(data.timevector_eeg_s1, data.values_eeg_s1)
    title(erase(data.filename, '_'))
    xlim([0 max(data.timevector_eeg_s1)]);
    
%     varlist = who;
%     index_ = find(not(cellfun('isempty', strfind(varlist, '__Ch'))));
%     varcell = varlist(index_);
%     a = genvarname(varcell{1});
%     
%     eval(strcat('data1 = ', a));
%     
%     data.filename = filename;
%     data.values_eeg_s1 = data1.values';
%     data.interval_eeg_s1 = data1.interval;
%    
%     s = size(data.values_eeg_s1, 2);
%     
%     data.timevector_eeg_s1 = (1:s)*data1.interval;
%     
%     save(filename, 'data');
%     clearvars -except filelist i
end
