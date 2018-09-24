function output = get_wave_positions_epoch(epoch_signal, epoch_time, fs)
	% crucial feature
	% we take the last epochs only and analyze the position of the wave

	% Output : 
	% output.d_wave_timestamps = 1xN array where each value is the timestamps of the detected waves.
	% output.p_wave_timestamps = 1xN array where each value is the timestamps of the predicted waves.
	% output.internal_frequency = detected frequency in the epoch
	% output.spike_orientation = 'up' or 'down'

    time_n = epoch_time;

	% filter signal between 0.1 and 40 Hz
    [b, a] = butter(2, 2/fs*[0.1 40], 'bandpass');
    rs_epoch = filtfilt(b, a, epoch_signal);

    % filter signal between 6 and 9 Hz
    [b, a] = butter(2, 2/fs*[6 9], 'bandpass');
    f_epoch = filtfilt(b, a, epoch_signal);
    
    [pxx, f_p] = pwelch(f_epoch, hamming(size(f_epoch, 2)), 0,[], fs);
    [m, i] = max(abs(pxx));
    internal_frequency = f_p(i);


    % split epochs in windows based on filtered signal
    % for more explanation look at the documentation:

    derivative_f_epoch = diff(f_epoch);

    [pks_1,locs_1] = findpeaks(f_epoch);
    [pks_2,locs_2] = findpeaks(-1*f_epoch);

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

	for i=1:(numel(windows)-1)
        start_window = windows(i); % timestamps not position
        end_window = windows(i+1)-1;
        
        windowed_epoch{i} = epoch_signal(start_window:end_window);
        windowed_rs_epoch{i} = rs_epoch(start_window:end_window);
        windowed_f_epoch{i} = f_epoch(start_window:end_window);

        std_epoch(i) = std(windowed_epoch{i}); % standard deviation of the non filtered signal
        std_diff_rs_epoch(i) = std(diff(windowed_rs_epoch{i})); % std de la dérivée du signal filtré entre 0.1 et 40Hz
        std_rs_epoch(i)=std(windowed_rs_epoch{i}); % standard deviation of the signal filtered between 0.1 and 40Hz
        std_diff_diff_rs_epoch(i)=std(diff(diff(windowed_rs_epoch{i}))); % deviation standard de la dérivée seconde du signal filtré entre 0.1 et 40Hz.
        max_abs_diff_rs_epoch(i)=max(abs(diff(windowed_rs_epoch{i}))); % maximum de la dérivée absolue du signal filtré entre 0.1 et 40Hz.
        mean_diff2_f_epoch(i)=mean(diff(diff(windowed_f_epoch{i}))); % moyenne de la dérivée seconde du signal filtré entre 6 et 9Hz.
    end

    if std_epoch(1) > std_epoch(2)
    % if std_rs_epoch(1) > std_rs_epoch(2)
        window_type(1:2:(numel(windows)-1)) = 1;
        window_type(2:2:(numel(windows)-1)) = 0;
    elseif std_rs_epoch(1) < std_rs_epoch(2)
        window_type(1:2:(numel(windows)-1)) = 0;
        window_type(2:2:(numel(windows)-1)) = 1;
    end

    % find the orientation of the spike and wave 
    % /!\ Discussion with Mark and Séverine to be sure /!\
    % find first wave and look at the average 2nd derivative of f_epochs
    if mean(mean_diff2_f_epoch(find(window_type == 0))) < 0
        wave_type = 'up';
        multiplier = 1;
    else
        wave_type = 'down';
        multiplier = -1;
    end

    % find location of waves and predict next position
    wave_windows_index = find(window_type==0);
    d_wave_timestamps = [];
    p_wave_timestamps = [];
    for i=1:size(wave_windows_index,2)
        [p, wave_locs] = findpeaks(multiplier*windowed_rs_epoch{wave_windows_index(i)});
        if ~isempty(wave_locs)
            wave_locs = wave_locs(1,1);
            d_wave_timestamps = [d_wave_timestamps epoch_time(windows(1, wave_windows_index(i))+wave_locs)];
            p_wave_timestamps = 1/internal_frequency + d_wave_timestamps;
        end
    end

    % set output structure:
    output.epoch_time = time_n;
    output.epoch_signal = epoch_signal;
    
    output.spike_orientation = wave_type;
    output.d_wave_timestamps = d_wave_timestamps;
    output.p_wave_timestamps = p_wave_timestamps;
    output.internal_frequency = internal_frequency;
end