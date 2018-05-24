% use .dll from Katia

clear all;
close all;

current_path = pwd;

z = Coherence5LE()
% addpath(genpath('C:\Users\thomas.bancel\Documents\MATLAB\Coherence5LE ICM\'));
addpath(genpath('C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\Coherence5LE ICM\'));

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
    blocksize = fs*20; % 1 seconds

    data = [];
    errorcode = 0;
    i = 1;

    [d, errorcode] = GetEeg( z, start, blocksize);
    while (errorcode>=0)

        data = [data d(:,1:5)'];
        start = start+blocksize;
        disp(strcat('Bloc number :', num2str(i)))
        drawnow;

        [d, errorcode] = GetEeg( z, start, blocksize);
        i = i+1;
    end

    ddata = double(data);
    rsampling_rate = 100
    rsvalue = resample(ddata', 1, 100)';
    rstime = (1:size(rsvalue,2))*rsampling_rate*1/fs;

    figure(1)
    h1 = subplot(5,1,1)
    plot(rstime, rsvalue(1,:))
    title('Hp-1')
    xlim([0 3600])
    h2 = subplot(5,1,2)
    plot(rstime, rsvalue(2,:))
    title('Hp-2')
    xlim([0 3600])
    h3 = subplot(5,1,3)
    plot(rstime, rsvalue(3,:))
    title('R-M1')
    xlim([0 3600])
    h4 = subplot(5,1,4)
    plot(rstime, rsvalue(4,:))
    title('L-M1')
    xlim([0 3600])
    h5 = subplot(5,1,5)
    plot(rstime, rsvalue(5,:))
    title('S1TR')
    xlim([0 3600])
    linkaxes([h1 h2 h3 h4 h5], 'x')


S    data.values = rsvalue;
    data.time = rstime;
    data.fs = fs/rsampling_rate;
    data.filename = strcat(strrep(strrep(eeg_filename,'.eeg',''), '.EEG',''), '_mice1.mat');

    save(data.filename, 'data')
end

cd(current_path);
