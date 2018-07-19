clear; 
close all;
clc;

load('20141203_Mark_GAERS_Neuron_1047_seizure_1.mat')

signal = seizure.signal;
time = seizure.time;
dt_1 = seizure.interval;
fs_1 = 1/dt_1;

% resample frequency:
fs_2 = 552;
dt_2 = 1/fs_2;

% low pass filter
[b, a] = butter(2, 2/fs_1*fs_2);
f_signal = filtfilt(b, a, signal); % + mean(signal);

time_duration_signal = max(time) - min(time);
n_points = floor(time_duration_signal*fs_2)+1;

rs_signal = zeros(1, n_points);
rs_signal(1,1) = signal(1,1);

rs_time = zeros(1, n_points);
rs_time(1,1) = time(1,1);

for i=1:(n_points-1)
   index = max(find(i*dt_2 + time(1,1) > time));
   rs_time(1, i+1) = time(1,1) + i*dt_2;
   rs_signal(1,i+1) = f_signal(1, index) + (rs_time(1,i+1) - time(1, index))*(f_signal(1, index+1) - f_signal(1, index))/dt_1;
end

figure
plot(time, f_signal, 'b-o', rs_time, rs_signal, 'k-*')

% figure
% plot(time, signal, time, f_signal)