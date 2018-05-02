% This script trys to analyse to seizure pattern on a recording containing seizure informations.
% Basically, it gives: the internal frequency and the peak positions.

% analyze seizures 
% peak and frequency

close all;
seizure_number = 1;

seizure_info =data.seizure_info(seizure_number,:);
filename = data.filename;
signal = data.values;
dt = data.interval
time = (1:size(signal, 2))*dt;

seizure_index = find(time > seizure_info(1) & time < seizure_info(2));

s_signal = signal(seizure_index);
s_time = time(seizure_index);


%%% Find internal frequency:
% find peak frequency using pwelch
window_length = floor(1/dt); % 1 second window
[pxx, f_p] = pwelch(s_signal, hamming(window_length), 0,[], 1/dt);
[m, i] = max(abs(pxx));
internal_frequency = f_p(i);

%%% Find peaks
% we filter our signal between 0.5Hz and 30Hz
% because peaks timelength are around 40-50ms which means harmonic with 
% frequencies of 25Hz.
% the idea is to find the peaks of such filtered signal and to locate the
% closest peak of the raw signal. 

fs = 1/dt;
[b, a] = butter(2, 2/fs*[0.5 30], 'bandpass');
fsignal = filtfilt(b, a, s_signal);

[b, a] = butter(2, 2/fs*[0.5 30], 'stop');
removed_signal = filtfilt(b, a, s_signal);

% find peaks of both filtered and signal (s_signal stands for seizure
% signal).
[pks_f, locs_f] = findpeaks(fsignal*(-1));
[pkf_s, locs_s] = findpeaks(s_signal*(-1));

final_peaks_locs = ones(1, size(locs_f, 2));

for i=1:size(locs_f, 2)
    [c index] = min(abs(locs_s - locs_f(1, i)));    
    if (c*dt) < 0.02
        final_peaks_locs(1, i) = locs_s(index);
    end
end

figure(5)
plot(s_time, s_signal); hold on
% plot(s_time(locs_f), s_signal(locs_f), 'mo'); hold on
% plot(s_time(locs_s), s_signal(locs_s), 'r*'); hold on
plot(s_time(final_peaks_locs), s_signal(final_peaks_locs), 'r*'); hold on
xlabel('Time (s)')
title('Down peaks location during seizures')


% Show find filtered and original signal
figure(4)
p1=plot(s_time, s_signal); hold on
p2=plot(s_time, fsignal);
xlabel('Time (s)')
title('Original versus filtered signal'),
legend('Original signal', 'Filtered signal');


% peak detection at certain frequency
% min_distance = 1/(1.01*internal_frequency);
% findpeaks(fsignal);


% figure(1)
% plot(s_time, s_signal)
% title(strcat(filename, " / Seizure n°", num2str(seizure_number)));

% figure(2)
% spectrogram(s_signal, hamming(window_length), 0 ,[], 1/dt, 'yaxis');
% title(strcat(filename, " / Seizure n°", num2str(seizure_number)));
% [s, f_s, t_s] = spectrogram(s_signal, hamming(window_length), 0,[], 1/dt, 'yaxis');

% figure (3)
% pwelch(s_signal, hamming(window_length), 0,[], 1/dt)
% title(strcat(filename, " / Seizure n°", num2str(seizure_number)))

% figure(6)
% plot(s_time, s_signal, s_time, fsignal, s_time, s_signal - removed_signal, s_time, s_signal - fsignal);
% legend('raw', 'filtered', 'raw - high bands', 'raw - filtered')