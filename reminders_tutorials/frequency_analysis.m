% frequency analysis:

clc; clear; close all;

% load the signal:
dir = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_labelled_recordings\raw_only_EEG';
cd(dir);
% load('20150103_Mark_GAERS_Neuron_1037_raw.mat');
% load('20141203_Mark_GAERS_Neuron_1047_raw.mat')
% load('/Users/tbancel/Desktop/epilepsia_internship/data/matlab_labelled_recordings/raw/20141203_Mark_GAERS_Neuron_1047_raw.mat')
load('20150422_Mark_GAERS_Neuron_1225_raw.mat')

Fs = 1/data.interval;
dt = data.interval;
signal = data.values;
timevector = data.timevector;

seizure_info=data.seizure_info;

% resample & epoch (1/30 points):
rsignal = resample(signal, 1, 30);
dtrs = dt*30;
rs_time=(1:size(rsignal,2))*dtrs;
frs = Fs/30;

epoch_timelength = 1;
epoch_length = floor(frs);
L = size(rsignal, 2);

% visualize laballed_signal
% figure(1)
% f=visualize_labelled_recording(rsignal, rs_time, data.seizure_info, data.filename)

% use the spectrogram function:
% window_length = epoch_length;
% window = hamming(epoch_length);
% noverlap = 50;
% nfft = epoch_length;
% [y_f,w_f,t_f] = spectrogram(rsignal, window_length, noverlap, [], frs, 'yaxis');

figure(2)
h1=subplot(2,1,1)
plot(rs_time/60, rsignal)
xlabel('Time (s)')
ylabel('mV')
title('Signal')
xlim([0 max(rs_time/60)])

h2=subplot(2,1,2)
[y_f,w_f,t_f] = spectrogram(rsignal, hamming(epoch_length), [], [], frs, 'yaxis');
% spectrogram(rsignal, hamming(epoch_length), 45, [], frs, 'yaxis');

linkaxes([h1 h2],'x')

%%%%%%
% MANUALLY COMPUTE SPECTROGRAM

% manually computed spectogram:
% strange I don't see any thing in the spectrum

epoch_output = compute_epoch(rsignal, epoch_length, dtrs);
epoched_signal = epoch_output.epoched_signal;
hamming_window = hamming(epoch_length)';
number_of_epochs = epoch_output.number_of_epochs;
M = repmat(hamming_window, number_of_epochs, 1);
% hamming_window = ones(epoch_output.number_of_epochs, 1)*hamming(epoch_length)

y_freq = fft(epoch_output.epoched_signal.*M);

freq = (1:epoch_length)*frs/epoch_length;
p_freq = abs(y_freq);
t = epoch_output.epoch_timestamps';

figure(3)

h1=subplot(2,1,1)
surf(t, freq, 20*log10(p_freq)','EdgeColor', 'none');
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time (s)')
ylabel('Freq (Hz)')
title('Manually Computed Spectrogram')
xlim([0 max(rs_time)])

h2=subplot(2,1,2)
plot(rs_time, rsignal)
xlabel('Time (s)')
ylabel('mV')
title('Signal')
xlim([0 max(rs_time)])

linkaxes([h1 h2],'x')


% % low pass filter (<100Hz)
% Fc = 100; % low pass frequency (below 100Hz)
% Fn = 50; % remove 50Hz;
% [b, a] = butter(15, 2*Fc/Fs);
% filtered_signal = filtfilt(b, a, rsignal);
% 
% % Notch filter (stop 50Hz)
% [d,c] = iirnotch(2*Fn/Fs, (2*Fn/Fs)/35);
% notched_filtered_signal = filtfilt(d,c, filtered_signal);

% FFT
% Reminders : 
% If the signal is sampled at Fs and has length of L, the frequency
% resolution in the frequency domain is Fs/L, the minimum frequency that
% the FFT algo can compute is Fs/L, the max frequency is Fs.

% mean_signal = mean(notched_filtered_signal);
% std_signal = std(notched_filtered_signal);
% norm_signal = (notched_filtered_signal-mean_signal)/std_signal;
% 
% Y_fft = fft(norm_signal);
% 
% spectrum = abs(Y_fft/L);
% F = (frs/L:frs/L:frs);

% Plot frequency analysis:

% figure(1)
% subplot(2,1,1)
% plot(rstimevector, rsignal);
% xlabel('Time(s)')
% xlim([0, max(rstimevector)]);
% 
% subplot(2,1,2)
% plot(F, spectrum)
% xlabel('Frequency (Hz)');
% ylabel('Frequency Power');

% work on spectogram (rééchantilloné):

%



%freq_f = w_f'/(2*pi)*frs;


% h1=subplot(3,1,1)
% p_f = abs(y_f/epoch_length);
% surf(t_f/60, w_f', 20*log10(p_f),'EdgeColor', 'none');
% axis xy; axis tight; colormap(jet); view(0,90);
% ylim([0, 15])
% xlabel('Time (s)')
% ylabel('Freq (Hz)')
% title('Automatically computed spectogram')


% %%
% figure(3)
% spectrogram(norm_signal, hamming(window_length), 45, [], frs, 'yaxis');




% figure
% plot(timevector, signal, timevector, filtered_signal, timevector, notched_filtered_signal);
% legend('Signal', 'Low pass 100Hz', '+Notching 50Hz');
% xlim([O max(timevector)]);
% xlabel('Time(s)');
% ylabel('EEG (mV)');

% h1 = subplot(3,1,1)
% plot(timevector, signal);
% h2 = subplot(3,1,2)
% plot(timevector, filtered_signal);
% h3 = subplot(3,1,3)
% plot(timevector, notched_filtered_signal);
% freq = fft(signal);
