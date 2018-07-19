% work on detection of spike and wave
% find peak and wave location
% epoch signal during 200ms
% first downsample and filter signal between 


close all;
seizure_number = 1;
N = 30; % downsample rate
f_b = [6 9]; % frequency band to filter frequency
epoch_duration = 0.2; % epochs duration (to mimick real time)

seizure_info = data.seizure_info(seizure_number,:);
filename = data.filename;
signal = data.values_eeg_s1;
dt = data.interval_eeg_s1;
time = (1:size(signal, 2))*dt;

seizure_index = find(time > seizure_info(1) & time < seizure_info(2));

s_signal = signal(seizure_index);
s_time = time(seizure_index);

% filter signal between 6 and 9 Hertz
fs = 1/dt;
[b, a] = butter(2, 2/fs*f_b, 'bandpass');
fsignal = filtfilt(b, a, s_signal);

% filter signal between 0.1 and 40 Hz
[b, a] = butter(2, 2/fs*[0.1 40], 'bandpass');
rsignal = filtfilt(b, a, s_signal);

% find peaks on filtered signal:
[up_pks_f, up_locs_f] = findpeaks(fsignal); % find local maxima
[down_pks_f, down_locs_f] = findpeaks(fsignal*(-1)); % find local minima

peak_locs_f = sort(cat(2, up_locs_f, down_locs_f));

tmp = circshift(peak_locs_f, -1, 2);
windows = floor((tmp + peak_locs_f)/2);
windows = windows(1, 1:(numel(windows)-1));

% based on the peak location of the filtered signal, we define time windows 
% plot data
figure(3)
plot(s_time, s_signal, s_time, rsignal);

% plot(s_time, rsignal, s_time, fsignal); hold on
% plot(s_time(up_locs_f), fsignal(up_locs_f), 'r*'); hold on
% plot(s_time(down_locs_f), fsignal(down_locs_f), 'r*'); hold on
% for i=1:numel(windows)
%     vline(s_time(windows(i)), 'r'); hold on
% end
% xlabel('Time (s)')

% figure
% plot(s_time, s_signal, s_time, fsignal)


%%%% Extracted data from the recording
% play with the cursor info

for i=1:size(cursor_info, 2)
    wave_locations(i) = cursor_info(i).Position(1); 
end
wave_locations = sort(wave_locations);

for i=1:size(cursor_info, 2)
    spike_locations(i) = cursor_info(i).Position(1); 
end
spike_locations = sort(spike_locations);