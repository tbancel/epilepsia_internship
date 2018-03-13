% frequency analysis:

clc; clear; close all;

% load the signal:
load('/Users/tbancel/Desktop/epilepsia_internship/data/matlab_labelled_recordings/raw/20141203_Mark_GAERS_Neuron_1047_raw.mat')

Fs = 1/data.interval;
dt = data.interval;
signal = data.values;
timevector = data.timevector;

% resample & epoch (1/30 points):
rsignal = resample(signal, 1, 30);
frs = Fs/30;
dtrs = dt*30;
epoch_timelength = 1;
epoch_length = floor(frs);
compute_epoch(rsignal, epoch_length, dtrs);
L = size(rsignal, 2);
rstimevector=(1:L)*dtrs;

% low pass filter (<100Hz)
Fc = 100; % low pass frequency (below 100Hz)
Fn = 50; % remove 50Hz;
[b, a] = butter(15, 2*Fc/Fs);
filtered_signal = filtfilt(b, a, rsignal);

% Notch filter (stop 50Hz)
[d,c] = iirnotch(2*Fn/Fs, (2*Fn/Fs)/35);
notched_filtered_signal = filtfilt(d,c, filtered_signal);

% FFT
% Reminders : 
% If the signal is sampled at Fs and has length of L, the frequency
% resolution in the frequency domain is Fs/L, the minimum frequency that
% the FFT algo can compute is Fs/L, the max frequency is Fs.

mean_signal = mean(notched_filtered_signal);
std_signal = std(notched_filtered_signal);
norm_signal = (notched_filtered_signal-mean_signal)/std_signal;

Y_fft = fft(norm_signal);

spectrum = abs(Y_fft/L);
F = (frs/L:frs/L:frs);

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

%%
% use the spectrogram function:
window_length = epoch_length;
window = hamming(epoch_length);
noverlap = 0;
nfft = epoch_length;
[y_f,w_f,t_f] = spectrogram(norm_signal, window_length, noverlap, nfft);

freq_f = w_f'/(2*pi)*frs;

figure(1)
h1=subplot(2,1,1)
p_f = abs(y_f/epoch_length);
surf(t_f, freq_f, 20*log10(p_f),'EdgeColor', 'none');
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time (s)')
ylabel('Freq (Hz)')
title('Manually Computed Spectrogram')

h2=subplot(2,1,2)
plot(rstimevector, rsignal)
xlabel('Time (s)')
ylabel('mV')
title('Signal')
xlim([0 max(rstimevector)])

%linkaxes([h1 h2],'x')


%%

% manually computed spectogram:
% strange I don't see any thing in the spectrum

epoch_output = compute_epoch(norm_signal, epoch_length, dtrs);
y_freq = fft(epoch_output.epoched_signal);

freq = (1:epoch_length)*frs/epoch_length;
p_freq = abs(y_freq / epoch_length);
t = epoch_output.epoch_timestamps';

figure(2)

h1=subplot(2,1,1)
surf(t, freq, 20*log10(p_freq)','EdgeColor', 'none');
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time (s)')
ylabel('Freq (Hz)')
title('Manually Computed Spectrogram')
xlim([0 max(rstimevector)])

h2=subplot(2,1,2)
plot(rstimevector, rsignal)
xlabel('Time (s)')
ylabel('mV')
title('Signal')
xlim([0 max(rstimevector)])

linkaxes([h1 h2],'x')


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






