% use .dll from Katia

clear all;
close all;

current_path = pwd;
addpath(genpath('C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\Coherence5LE ICM\'));

z = Coherence5LE()
resampling_rate = 20;

% addpath(genpath('C:\Users\thomas.bancel\Documents\MATLAB\Coherence5LE ICM\'));

% eeg_folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data_deltamed\EEG2\';
% eeg_filename = '180413a-b_0004.eeg';

eeg_folder = '\\10.5.42.1\reve\TeamCharpier\Projet T Bancel\20180413- nacl 0.9%\EEG2\';
list = dir(fullfile(eeg_folder, '*.eeg'));

cd(eeg_folder)


for i=1:size(list, 1)
    eeg_filename = list(i).('name');
    disp(eeg_filename)
    drawnow;
    
    z = OpenFile(z,strcat(eeg_folder, eeg_filename));
    FileInfo = GetFileInfo(z);

    duration = FileInfo.duration; % in seconds, total duration of file
    fs = FileInfo.frequency;

    start = 0;
    blocksize = fs*20; % 1 seconds (? not sure this is exact: maybe 20 seconds 20 seconds ?)

    rs_data = []; % which will be converted into double later
    
    errorcode = 0;
    j = 1;

    [d, errorcode] = GetEeg(z, start, blocksize);
    
    % start loop here
    while (errorcode>=0)
    
        rs_d = resample(double(d), 1, resampling_rate);
        rs_data = [rs_data rs_d(:,1:15)']; %we take the first 3 mice
        
        start = start+blocksize;
        disp(strcat('Bloc number :', num2str(j)))
        drawnow;

        [d, errorcode] = GetEeg( z, start, blocksize);
        j = j+1;
    end

    rsvalue = rs_data;
    rstime = (1:size(rsvalue,2))*resampling_rate*1/fs;

    f = figure(1);
    f.Name = strcat(eeg_filename, 'Bloc number :', num2str(j), 'Mice KA5 Control');
    
    h1 = subplot(5,1,1);
    plot(rstime, rsvalue(1,:));
    title('Hp-1');
    xlim([0 3600]);
    h2 = subplot(5,1,2);
    plot(rstime, rsvalue(2,:));
    title('Hp-2');
    xlim([0 3600]);
    h3 = subplot(5,1,3);
    plot(rstime, rsvalue(3,:));
    title('R-M1');
    xlim([0 3600]);
    h4 = subplot(5,1,4);
    plot(rstime, rsvalue(4,:));
    title('L-M1');
    xlim([0 3600]);
    h5 = subplot(5,1,5);
    plot(rstime, rsvalue(5,:));
    title('S1TR');
    xlim([0 3600]);
    xlabel('Time (s)');
    linkaxes([h1 h2 h3 h4 h5], 'x');
    


    data.values = rsvalue;
    data.time = rstime;
    data.fs = fs/resampling_rate;
    data.interval = 1/fs*resampling_rate;
    data.filename = strcat(strrep(strrep(eeg_filename,'.eeg',''), '.EEG',''), '_mice1.mat');

    save(data.filename, 'data')
end

cd(current_path);
