% analyse peaks and waves location
% offline

clc; close all;
clear;

%%%%%
% Parameters to set for the script
%


%%%%%

% METHOD 1: load a labelled EEG recording
% pick a random seizure

% load('20150103_Mark_GAERS_Neuron_1081.mat')
% load('20150422_Mark_GAERS_Neuron_1225.mat')
% number_of_seizures = size(data.seizure_info, 1);
% seizure_number = floor(number_of_seizures*rand)+1;


% METHOD 2 : load a seizure (labelled potentially)
%
% load('20141203_Mark_GAERS_Neuron_1047_seizure_1.mat')
% s_signal = seizure.signal;
% s_time = seizure.time;
% dt = seizure.interval;
% fs = 1/dt;

for seizure_number=8:8 %1:number_of_seizures
    
    % extract seizure signal from total EEG recording
    filename = data.filename;
    signal = data.values_eeg_s1;
    dt = data.interval_eeg_s1;
    fs = 1/dt;
    time = (1:size(signal, 2))*dt;

    seizure_info = data.seizure_info(seizure_number,:);
    seizure_index = find(time > seizure_info(1) & time < seizure_info(2));

    s_signal = signal(seizure_index);
    s_time = time(seizure_index);

    % filter signal between 0.1 and 40 Hz
    [b, a] = butter(2, 2/fs*[0.1 40], 'bandpass');
    rs_signal = filtfilt(b, a, s_signal);

    % filter signal between 6 and 9 Hertz
    [b, a] = butter(2, 2/fs*[6 9], 'bandpass');
    f_signal = filtfilt(b, a, s_signal);

    % internal frequency:
    [pxx, f_p] = pwelch(f_signal, hamming(size(f_signal, 2)), 0,[], 1/dt);
    [m, i] = max(abs(pxx));
    internal_frequency = f_p(i);

    % know if we look for up and down peaks
    % idea: find the local extrema of the f_signal, split the signal in
    % windows
    
    % find local extrema (minima and maxima) of f_signal and split into windows
    [pks_1,locs_1] = findpeaks(f_signal);
    [pks_2,locs_2] = findpeaks(-1*f_signal);

    loc_peaks_f_signal = sort(cat(2, locs_1, locs_2));
    time_peaks_f_signal = s_time(loc_peaks_f_signal);

    % split signal into different windows:
    tmp = circshift(loc_peaks_f_signal, -1, 2);
    windows = floor((tmp + loc_peaks_f_signal)/2);
    windows = windows(1:(numel(windows)-1));

    % compute window length etc.
    windows_length = diff(windows)*dt;
    win_avg = mean(windows_length);
    win_min = min(windows_length);
    win_max = max(windows_length);

    % know if we are looking for up wave or down wave:
    % full_windows = [0 windows numel(s_time)];
    for i=1:(numel(windows)-1)
        s_time_window{i} = s_time(windows(i):windows(i+1));
        s_signal_window{i} = s_signal(windows(i):windows(i+1));
        rs_signal_window{i} = rs_signal(windows(i):windows(i+1));
        f_signal_window{i} = f_signal(windows(i):windows(i+1));
        
        % difference between f_signal and rs_signal for each window.
        win_mean_diff(i) = mean(abs(f_signal_window{i} - rs_signal_window{i}));
    end

    [m, w_index] = min(win_mean_diff);
    avg_2nd_derivative_f_signal = mean(diff(diff(f_signal_window{w_index})));
    is_up = (avg_2nd_derivative_f_signal < 0);

    if is_up
        multiplier = 1;
    else
        multiplier = -1;
    end

    % FIND WAVES (using a comparison between f_signal and s_signal)

    % locs_f : local maxima of the filtered signal between 6 and 9Hz : 
    % they somehow corresponds to a wave
    [pks_f, locs_f] = findpeaks(f_signal*multiplier);

     % locs_s : peaks of the rs_signal:
    [pkf_s, locs_rs] = findpeaks(rs_signal*multiplier);  

    final_waves_locs = [];
    start_index = 1;
    abs_2nd_derivative_value = [];
    
    for i=1:(size(locs_f, 2)-1)
        % find the local maxima of the rs_signal which are around the local
        % maxima of the f_signal
        
        last_index = floor((locs_f(1,i)+locs_f(1,i+1))/2);
        potential_waves_locs = locs_rs(find(locs_rs < last_index & locs_rs > start_index));
        start_index = last_index + 1;
        
        abs_2nd_derivative_value = [];
        for j=1:size(potential_waves_locs)
            abs_2nd_derivative_value(j) = abs(diff(diff(rs_signal((potential_waves_locs(j)-1):(potential_waves_locs(j)+1)))));
        end
        
        if ~isempty(abs_2nd_derivative_value)
            [m, index] = min(abs_2nd_derivative_value);
            final_waves_locs = [final_waves_locs potential_waves_locs(index)];
        end
        
        % [c index] = min(abs(locs_rs - locs_f(1, i)));
        % if (c*dt) < 0.02 % 20 ms
        %     final_waves_locs(1, i) = locs_rs(index);
        % end
    end

    % FIND PEAKS
    % look at the peak from the rs_signal which captures the peak
    % peak width is ~40ms which is ~25Hz. rs_signal has frequencies between 0.1
    % and 40 Hz.
    rs_max_timestamps = s_time(locs_rs);
    waves_timestamps = s_time(final_waves_locs);
    
    final_peaks_locs = [];
    start_index = 1;
    abs_2nd_derivative_value = [];
    
    for i=1:(size(final_waves_locs, 2)-1)
        potential_peaks_locs = locs_rs(find(locs_rs < final_waves_locs(i) & locs_rs > start_index));
        start_index = final_waves_locs(i);

        abs_2nd_derivative_value = [];
        for j = 1:size(potential_peaks_locs, 2)
            % compute local 2nd derivative around each potential peak take the
            % larges one in absolute value (it is a negative value for up peak)

            abs_2nd_derivative_value(j) = abs(diff(diff(rs_signal((potential_peaks_locs(j)-1):(potential_peaks_locs(j)+1)))));
            % disp(num2str(s_time(potential_peaks_locs(1,j))));
        end

        if ~isempty(abs_2nd_derivative_value)
            [m, index] = max(abs_2nd_derivative_value);
            final_peaks_locs = [final_peaks_locs potential_peaks_locs(index)];
        end
        % disp("next");
    end


    % post treatement


    % END OF DETECTION AND LABELLING SCRIPT
    %%%%%%%%%%%%%%

    %%%%%%%%%%%%%%
    % PLOTTING
    % plotting always at the end:
    % figure(1)
    % plot(s_time, s_signal, s_time, rs_signal, s_time, f_signal); hold on;
    % for i=1:size(windows, 2)
    %     vline(s_time(windows(i)), 'r');
    % end
    % xlim([min(s_time) max(s_time)]);
    
    figure(seizure_number)
    
    % plot(s_time, -s_signal); hold on
    plot(s_time, s_signal, s_time, rs_signal, s_time, f_signal); hold on
    plot(s_time(final_waves_locs), s_signal(final_waves_locs), 'r*'); hold on
    plot(s_time(final_peaks_locs), s_signal(final_peaks_locs), 'g*'); hold on
    
    % vline(min(s_time_window{w_index}), 'r');
    % vline(max(s_time_window{w_index}), 'r');

    % legend('red => waves', 'green => peaks');
    annotation('textbox', [0.2 0.5 0.3 0.3], 'String','* - Waves', 'Color', 'r', 'FitBoxToText','on');
    annotation('textbox','String','* - Spikes', 'Color', 'g');
    
    xlabel('Time (s)');
    title('Spike and wave location seizures');

    % figure(2)
    % plot(s_time, s_signal, s_time, rs_signal);
    % 
    % figure(3)
    % plot(s_time_window{w_index}, s_signal_window{w_index}, s_time_window{w_index}, rs_signal_window{w_index}, s_time_window{w_index}, f_signal_window{w_index})


    % END OF PLOTTING
    %%%%%%%%%%%%%%%%%
    
end