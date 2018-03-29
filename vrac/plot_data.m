filelist = dir('*.mat');
nfiles = size(filelist,1);

figure(1)

for i=11:21
    filename = filelist(i).('name');
    load(filename)
    
    plot(data.timevector_eeg_s1, data.values_eeg_s1)
    title(erase(data.filename, '_'));
    
    save(data.filename, 'data');
end