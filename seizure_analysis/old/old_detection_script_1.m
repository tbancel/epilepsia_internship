clc; close all;
clear;

load('20141203_Mark_GAERS_Neuron_1047_seizure_1.mat')

% tic
% split seizure in epochs
epoch_duration = 0.2; % 200 ms which is the sampling rate.
str = date;

s_signal = seizure.signal;
dt = seizure.interval;
fs = 1/dt;

epoch_length = floor(epoch_duration/dt);
output_epoch = compute_epoch(s_signal, epoch_length, dt);
epochs = output_epoch.epoched_signal;

tic
% filter signal between 0.1 and 40 Hz
[b, a] = butter(2, 2/fs*[0.1 40], 'bandpass');
rs_epochs = filtfilt(b, a, epochs')';
comp_time_filtering_0_40 = toc;

tic
% filter signal between 6 and 9 Hertz
[b, a] = butter(2, 2/fs*[6 9], 'bandpass');
f_epochs = filtfilt(b, a, epochs')';
comp_time_filtering_6_9 = toc;

% filter between 20 and 30
[b, a] = butter(2, 2/fs*[20 30], 'bandpass');
p_epochs = filtfilt(b, a, epochs')';

% chose epoch number to display and work on (later all of them):

% k = floor(rand*output_epoch.number_of_epochs);

p_waves_timestamps_whole_seizure = [];
p_peaks_timestamps_whole_seizure = [];
internal_f_whole_seizure = [];

comp_time_epochs = [];

for n=5:5% n=1:output_epoch.number_of_epochs %k:k
    
    tic
    time_n = seizure.time(1,1)+output_epoch.epoch_timestamps(n)+(1:output_epoch.epoch_length)*dt;

    % get internal frequency:
    % in real time we will use it to calculate when to trigger the next
    % stimulation
    
    [pxx, f_p] = pwelch(f_epochs(n,:), hamming(size(f_epochs(n,:), 2)), 0,[], 1/dt);
    % [pxx, f_p] = pwelch(rs_epochs(n,:), ones(1, size(rs_epochs(n,:),2)), 0,[], 1/dt);
    [m, i] = max(abs(pxx));
    internal_frequency = f_p(i);
    internal_f_whole_seizure = [internal_f_whole_seizure internal_frequency];

    % find manually labelled peaks and wave location inside the given epoch
    peaks_timestamps = seizure.peak_locations(seizure.peak_locations < max(time_n) & seizure.peak_locations > min(time_n));
    waves_timestamps = seizure.wave_locations(find(seizure.wave_locations < max(time_n) & seizure.wave_locations > min(time_n)));

    %%%%%%
    % start prediction and analysis
    %%%%%%

    % split epoch in different windows using the derivative of the filtered
    % signal between 6 and 9 Hz
    derivative_f_epoch = diff(f_epochs(n, :));

    [pks_1,locs_1] = findpeaks(f_epochs(n,:));
    [pks_2,locs_2] = findpeaks(-1*f_epochs(n,:));

    loc_peaks_f_epoch = sort(cat(2, locs_1, locs_2));
    time_peaks_f_epoch = time_n(loc_peaks_f_epoch);
    
    tmp = circshift(loc_peaks_f_epoch, -1, 2);
    windows = floor((tmp + loc_peaks_f_epoch)/2);
    windows = windows(1:(numel(windows)-1));

    % windows = [];
    start_window = 1;

    % we work on the std of the derivative of the rs_signal
    for i=1:(numel(loc_peaks_f_epoch)-1)
        start_time_n_index_window(i)=start_window;
        end_window = floor((loc_peaks_f_epoch(1,i)+loc_peaks_f_epoch(1,i+1))/2);
        windowed_rs_epoch{i}=rs_epochs(n,start_window:end_window);
        windowed_f_epoch{i}=f_epochs(n,start_window:end_window);

        start_window=end_window+1;

        std_rs_epoch(i)=std(windowed_rs_epoch{i}); % standard deviation of the signal filtered between 0.1 and 40Hz
        std_diff_diff_rs_epoch(i)=std(diff(diff(windowed_rs_epoch{i}))); % deviation standard de la dérivée seconde du signal filtré entre 0.1 et 40Hz.
        max_abs_diff_rs_epoch(i)=max(abs(diff(windowed_rs_epoch{i}))); % maximum de la dérivée absolue du signal filtré entre 0.1 et 40Hz.
        mean_diff2_f_epoch(i)=mean(diff(diff(windowed_f_epoch{i}))); % moyenne de la dérivée seconde du signal filtré entre 6 et 9Hz.
    end

    % on le fait pour la dernière fenêtre 
    % a optimiser
    start_time_n_index_window(numel(loc_peaks_f_epoch))=start_window;
    windowed_rs_epoch{numel(loc_peaks_f_epoch)}=rs_epochs(n, start_window:numel(time_n));
    windowed_f_epoch{numel(loc_peaks_f_epoch)}=f_epochs(n,start_window:numel(time_n));
    
    std_rs_epoch(numel(loc_peaks_f_epoch))=std(windowed_rs_epoch{numel(loc_peaks_f_epoch)});
    std_diff_diff_rs_epoch(numel(loc_peaks_f_epoch))=std(diff(diff(windowed_rs_epoch{numel(loc_peaks_f_epoch)})));
    max_abs_diff_rs_epoch(numel(loc_peaks_f_epoch))=max(abs(diff(windowed_rs_epoch{numel(loc_peaks_f_epoch)})));
    mean_diff2_f_epoch(numel(loc_peaks_f_epoch))=mean(diff(diff(windowed_f_epoch{numel(loc_peaks_f_epoch)})));

    % identify where waves and peaks are on each window
    % we look at the std of the derivative 2nd of the signal on each window:
    % 0 : wave
    % 1 : peak

    if std_rs_epoch(1) > std_rs_epoch(2)
    % if std_diff_diff_rs_epoch(1) > std_diff_diff_rs_epoch(2)
        window_type(1:2:numel(windowed_rs_epoch)) = 1;
        window_type(2:2:numel(windowed_rs_epoch)) = 0;
    else
        window_type(1:2:numel(windowed_rs_epoch)) = 0;
        window_type(2:2:numel(windowed_rs_epoch)) = 1;
    end

    % find if this an up or a down wave:
    % find first wave and look at the average 2nd derivative of f_epochs
    if mean_diff2_f_epoch(min(find(window_type == 0))) < 0
        wave_type = 'up';
        multiplier = 1;
    else
        wave_type = 'down';
        multiplier = -1;
    end
    
    % find waves and peaks
    % work on the filtered signal between 0.1 and 40Hz
    
    % wave locations
    p_waves_timestamps = [];
    wave_windows_index = find(window_type==0);
    for i=1:size(wave_windows_index,2)
        [p, wave_locs] = findpeaks(multiplier*windowed_rs_epoch{wave_windows_index(i)});
        if ~isempty(wave_locs)
            wave_locs = wave_locs(1,1);
            p_waves_timestamps = [p_waves_timestamps time_n(start_time_n_index_window(wave_windows_index(i))+wave_locs)];   
        end
    end
    p_waves_timestamps_whole_seizure = [p_waves_timestamps_whole_seizure p_waves_timestamps];

    
    p_peaks_timestamps = [];
    peak_windows_index = find(window_type==1);
    for i=1:size(peak_windows_index, 2)
        [p, peak_locs] = findpeaks(multiplier*windowed_rs_epoch{peak_windows_index(i)});
        if ~isempty(peak_locs)
            peak_locs = peak_locs(1,1);
            p_peaks_timestamps = [p_peaks_timestamps time_n(start_time_n_index_window(peak_windows_index(i))+peak_locs)];
        end
    end
    p_peaks_timestamps_whole_seizure = [p_peaks_timestamps_whole_seizure p_peaks_timestamps];
    
    
    %%%% PLOTTING
    % plot specific epoch with the peak and wave location
    figure(n)
    plot(time_n, epochs(n, :), time_n, rs_epochs(n,:), time_n, f_epochs(n,:), time_n, p_epochs(n,:)); hold on;
    xlim([min(time_n) max(time_n)])

    for i=1:numel(peaks_timestamps)
        index_i = min(find(peaks_timestamps(i) < time_n));
        plot(time_n(1,index_i), epochs(n, index_i), 'b-*'); hold on;
    end

    for i=1:numel(waves_timestamps)
        index_i = min(find(waves_timestamps(i) < time_n));
        plot(time_n(1,index_i), epochs(n, index_i), 'b-o'); hold on;
    end
   
    % plot predicted peaks and waves:
    for i=1:numel(p_peaks_timestamps)
        index_i = min(find(p_peaks_timestamps(i) < time_n));
        plot(time_n(1,index_i), epochs(n, index_i), 'g-*'); hold on;
    end

    for i=1:numel(p_waves_timestamps)
        index_i = min(find(p_waves_timestamps(i) < time_n));
        plot(time_n(1,index_i), epochs(n, index_i), 'g-o'); hold on;
    end
    
    % plot windows vertical separators
    for i=1:numel(windows)
        vline(time_n(windows(i)), 'r');
    end
    
     % saveas(figure(n), strcat('Figure_', num2str(n),'_', str,'.png'), 'png')
     % close all;

    comp_time_epochs = [comp_time_epochs toc]; 
end

f_mean = mean(internal_f_whole_seizure);
[f_min, argmin_f] = min(internal_f_whole_seizure);
[f_max, argmax_f] = max(internal_f_whole_seizure);
f_std = std(internal_f_whole_seizure);


