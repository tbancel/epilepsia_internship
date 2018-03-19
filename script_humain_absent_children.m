% script human data
% description of recording procedure

% children data : 
clc; clear;
close all;
load('children_rothschild.mat')

% get the signal
signal = data.values;
dt = data.interval;
fs = 1/dt;
time = (1:size(signal, 2))*dt;

% resample 10 times:
rsignal = resample(signal, 1, 10);
dtrs = dt*10;
frs = 1/dtrs;
rs_time = (1:size(rsignal, 2))*dtrs;

% notch filter
f_notch = 50; % filter 50 Hz
[b, a] = butter(3, 2*f_notch*[0.99 1.01]/frs, 'stop');
fsignal = filtfilt(b, a, rsignal);

% low pass filter 30 Hz:
f_cut = 30
[b, a] = butter(3, 2*f_cut/frs, 'low');
lowpass_signal = filtfilt(b, a,rsignal);

% plot signal 
f=figure(1)
f.Name = data.filename;
h1=subplot(3,1,1)
plot(rs_time, rsignal)
title('Resampled signal 10 times')
h2=subplot(3,1,2)
plot(rs_time, fsignal)
title('Notched signal at 50 Hz')
h3=subplot(3,1,3)
plot(rs_time, lowpass_signal)
title('Filtered signal below 30 Hz')
linkaxes([h1 h2 h3], 'x');
xlim([0 max(rs_time)])

% plot(rs_time, rsignal, rs_time, fsignal, rs_time, lowpass_signal);
% legend('Resampled signal 200Hz', 'Notched signal 50Hz', 'Lowpassed signal 30Hz');
% plot(rs_time, fsignal, rs_time, lowpass_signal);
% legend('Notched signal 50Hz', 'Lowpassed signal 30Hz');
% predict seizures

approx_epoch_timelength = 1;
threshold_value = 2;

output = predict_seizures_norm_line_length_threshold(data.filename, lowpass_signal, dtrs, 1, approx_epoch_timelength, threshold_value)


f = visualize_recording_with_prediction(lowpass_signal, rs_time, output.crisis_info_matrix, data.filename)




