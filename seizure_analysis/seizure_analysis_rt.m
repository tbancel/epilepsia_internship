%%% 
% This script finds the spike and wave location in a manually labelled
% seizures in REAL TIME/
% 
% It replicates how it would work in real time, by epoching the seizure
% (the duration of the epoch is adjustable).

% The idea of the script is to filter the epoch between 2 frequency
% intervals ([0.1 40] and [6 9]) and to:
% 1. find the orientation of the signal (spike up or spike down)
% 2. find the wave locations (using the 6-9Hz filtered signal)
% 3. find the spike locations (using the 0.1-40Hz filtered signal)

% Acceptable performances are:
% For GAERS: detected spikes must be 20ms in 

clc; close all;
clear;

%%%%
% PARAMETERS TO SET
epoch_duration = 0.2; % 200 ms which is the sampling rate.
str = date;
%%%%%%

% Loop through labelled seizures:

current_dir = pwd;
folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_labelled_seizures\';
cd(folder);
filelist = dir('*.mat');

for k=1:size(filelist, 1)
    
    filepath = filelist(k).('name');
    load(filepath);

    s_signal = seizure.signal;
    s_time = seizure.time;
    dt = seizure.interval;
    fs = 1/dt;
    
    % Get internal frequency of seizure
    [pxx, f_p] = pwelch(s_signal, hamming(numel(s_time)), 0,[], 1/dt);
    [m, i] = max(abs(pxx));
    internal_frequency = f_p(i);

    %%%%%%%%%
    % BEGINNING OF THE SCRIPT

    % split seizure in epochs to simulate real-time analysis
    epoch_length = floor(epoch_duration/dt);
    output_epoch = compute_epoch(s_signal, s_time, epoch_length, dt);
    epochs = output_epoch.epoched_signal;

    tic
    % filter signal between 0.1 and 40 Hz
    [b, a] = butter(2, 2/fs*[0.1 40], 'bandpass');
    rs_epochs = filtfilt(b, a, epochs')';
    comp_time_filtering_0_40 = toc; % get computation time

    tic
    % filter signal between 6 and 9 Hz
    [b, a] = butter(2, 2/fs*[6 9], 'bandpass');
    f_epochs = filtfilt(b, a, epochs')';
    comp_time_filtering_6_9 = toc; % get computation time

    % filter between 20 and 30 Hz
    [b, a] = butter(2, 2/fs*[20 30], 'bandpass');
    p_epochs = filtfilt(b, a, epochs')';

    % chose epoch number to display and work on (later all of them):
    % k = floor(rand*output_epoch.number_of_epochs);

    % real spikes and waves timestamps (if signal has been manually labelled)
    spikes_timestamps = [];
    waves_timestamps = [];

    % detected spikes and waves timestamps
    d_waves_timestamps_whole_seizure = [];
    d_spikes_timestamps_whole_seizure = [];

    % predicted spikes and waves timestamps
    p_waves_timestamps_whole_seizure = [];
    p_spikes_timestamps_whole_seizure = [];

    % internal frequency detected for each epoch (inside of the seizure)
    internal_f_whole_seizure = [];

    % orientation of the curve for each epoch:
    up_down_epochs = []; 

    % computation time for each epoch (inside the seizure)
    comp_time_epochs = [];

    for n=1:output_epoch.number_of_epochs
        
        tic
        time_n = output_epoch.epoched_time(n,:);
        
        [pxx, f_p] = pwelch(f_epochs(n,:), hamming(size(f_epochs(n,:), 2)), 0,[], 1/dt);
        [m, i] = max(abs(pxx));
        internal_frequency = f_p(i);
        internal_f_whole_seizure = [internal_f_whole_seizure internal_frequency];

        % find manually labelled spike and wave location inside the given epoch
        if isfield(seizure, 'spike_locations')
            spikes_timestamps = seizure.spike_locations(seizure.spike_locations < max(time_n) & seizure.spike_locations > min(time_n));
            waves_timestamps = seizure.wave_locations(find(seizure.wave_locations < max(time_n) & seizure.wave_locations > min(time_n))); 
        end

        %%%%%%
        % start prediction and analysis
        % General description of the algorithm:
        % TO BE DONE
        %%%%%%

        %%% COMPUTE FEATURES INSIDE THE EPOCH...
        % split epoch in different windows using the derivative of the filtered
        % signal between 6 and 9 Hz.
        derivative_f_epoch = diff(f_epochs(n, :));

        [pks_1,locs_1] = findpeaks(f_epochs(n,:));
        [pks_2,locs_2] = findpeaks(-1*f_epochs(n,:));

        loc_peaks_f_epoch = sort(cat(2, locs_1, locs_2));
        time_peaks_f_epoch = time_n(loc_peaks_f_epoch);
        
        tmp = circshift(loc_peaks_f_epoch, -1, 2);
        windows = floor((tmp + loc_peaks_f_epoch)/2);
        windows = windows(1:(numel(windows)-1));

        if windows(1,1)~=1
            windows = [1 windows];
        end
        if windows(1,numel(windows))~=numel(time_n)
            windows = [windows numel(time_n)];
        end
        
        window_type = zeros(1, numel(windows)-1);
        
        windowed_epoch = {};
        windowed_rs_epoch = {};
        windowed_f_epoch = {};
        
        % For each sub-window (of the epoch), we compute basic features of the
        % signal (std, mean 2nd derivative, max abs 1st derivative)
        for i=1:(numel(windows)-1)
            start_window = windows(i);
            end_window = windows(i+1)-1;
            
            windowed_epoch{i} = epochs(n, start_window:end_window);
            windowed_rs_epoch{i} = rs_epochs(n,start_window:end_window);
            windowed_f_epoch{i} = f_epochs(n,start_window:end_window);

            std_epoch(i) = std(windowed_epoch{i}); % standard deviation of the non filtered signal
            std_diff_rs_epoch(i) = std(diff(windowed_rs_epoch{i})); % std de la dérivée du signal filtré entre 0.1 et 40Hz
            std_rs_epoch(i)=std(windowed_rs_epoch{i}); % standard deviation of the signal filtered between 0.1 and 40Hz
            std_diff_diff_rs_epoch(i)=std(diff(diff(windowed_rs_epoch{i}))); % deviation standard de la dérivée seconde du signal filtré entre 0.1 et 40Hz.
            max_abs_diff_rs_epoch(i)=max(abs(diff(windowed_rs_epoch{i}))); % maximum de la dérivée absolue du signal filtré entre 0.1 et 40Hz.
            mean_diff2_f_epoch(i)=mean(diff(diff(windowed_f_epoch{i}))); % moyenne de la dérivée seconde du signal filtré entre 6 et 9Hz.
        end

        % identify where waves and spikes are on each window
        % we look at the std of the derivative 2nd of the signal on each window:
        % 0 : wave
        % 1 : spike

        % Script which detects and predict seizures.
        % it takes variables in the workspace and return 
        % - d_spikes_timestamps_whole_seizure
        % - p_spikes_timestamps_whole_seizure
        
        script_find_sw_position_method_1
        script_find_sw_position_method_2


        
        
        % Plot epoch
        % script_plot_epoch_m1

        comp_time_epochs = [comp_time_epochs toc];
    end

    % save_all_figure_png
    % get all signal concatenated
    
    %%%%
    % PLOTTING AT THE END:
    % plot seizure with detected spike and wave position
    % f = visualize_swd_seizure(seizure, d_spikes_timestamps_whole_seizure, d_waves_timestamps_whole_seizure);
    % f = visualize_swd_seizure(seizure, [], d_waves_timestamps_whole_seizure);
    f = visualize_swd_seizure(seizure, d_spikes_timestamps_whole_seizure, []);
    f.Name = strcat(seizure.filename, 'seizure number: ', num2str(seizure.seizure_number));

    % add the separation of epochs
    c_s_time = output_epoch.chunked_time_vector;
    c_rs_signal = reshape(rs_epochs', 1, numel(rs_epochs));
    c_f_signal = reshape(f_epochs', 1,  numel(f_epochs));

    plot(c_s_time, c_rs_signal, c_s_time, c_f_signal); hold on;

    for i=1:output_epoch.number_of_epochs
        vline(output_epoch.epoch_timestamps(i, 1), 'r'); hold on;
    end

    % %%%%
    % % plot predicted locations of spikes.
    % s_loc = p_spikes_timestamps_whole_seizure;
    %  for i=1:size(s_loc, 2)
    %     p_index(1, i) = max(find(s_time < s_loc(1,i)));
    %     plot(s_time(p_index(1,i)), s_signal(p_index(1,i)), 'k*'); hold on
    % end

    % % plot wave location
    % w_loc = p_waves_timestamps_whole_seizure;
    % for i=1:size(w_loc, 2)
    %     w_index(1, i) = max(find(s_time < w_loc(1,i)));
    %     plot(s_time(w_index(1,i)), s_signal(w_index(1,i)), 'k-o'); hold on
    % end


    % compute performance

    perf_d_spikes = sw_detection_perf(seizure.spike_locations, d_spikes_timestamps_whole_seizure);
    perf_d_waves = sw_detection_perf(seizure.wave_locations, d_waves_timestamps_whole_seizure);

    perf_p_spikes = sw_detection_perf(seizure.spike_locations, p_spikes_timestamps_whole_seizure);
    perf_p_waves = sw_detection_perf(seizure.wave_locations, p_waves_timestamps_whole_seizure);
    
    % put performance in a table
    names{k,1} = seizure.filename;
    seizure_number(k,1) = seizure.seizure_number;
    seizure_duration_s(k,1) = seizure.interval*numel(seizure.time);
    seizure_internal_f_Hz(k,1) = internal_frequency;
    seizure_avg_period_ms(k,1) = 1/internal_frequency*1000;
    
    detected_wave_precision_ms(k,1) = perf_d_waves.avg_precision*1000;
    predicted_wave_precision_ms(k,1) = perf_p_waves.avg_precision*1000;
    predicted_wave_relative_precision_percent(k,1) = perf_p_waves.relative_precision;
    detected_spike_precision_ms(k,1) = perf_d_spikes.avg_precision*1000;
    predicted_spike_precision_ms(k,1) = perf_p_spikes.avg_precision*1000;

end

cd(current_dir);

t = table(names, seizure_number, seizure_duration_s, seizure_internal_f_Hz, seizure_avg_period_ms, ...
    detected_wave_precision_ms, predicted_wave_precision_ms, predicted_wave_relative_precision_percent, detected_spike_precision_ms, predicted_spike_precision_ms); 

disp(t)
