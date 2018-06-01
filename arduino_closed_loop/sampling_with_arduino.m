% creates a script for sampling with arduino using matlab
% see if there are connections with fieldrip
% write into the buffer (?)

% define a function that asks the arduino to sample the signal at XX Hz
% during XX s

clear; clc; close all;

a = arduino;

voltage = readVoltage(a, 'A0');

sampling_rate = 100; % in Hertz
sampling_window = 0.2; % in second
dt=1/sampling_rate;

points = sampling_window * sampling_rate;

tic
for i=1:points
    voltages(i, 1) = readVoltage(a, 'A0')
    reading_times(i, 1) = toc;
    pause(i*dt-reading_times(i,1));
end

% write in the buffer, will be the easier
plot(reading_times, voltage)

% monitor time it takes to read one voltage:
for i=1:100
    tic
    readVoltage(a, 'A0');
    samp_time(i,1) = toc;
end

avg_samp_time = mean(samp_time);
std_samp_time = std(samp_time);
min_samp_time = min(samp_time);
max_samp_time = max(samp_time);

% Conclusion : impossible d'échantilloner à plus de 20Hz dans ses conditions
% il faut que je trouve une autre solution
% Option : mettre un script en C sur l'arduino pour échantilloner pendant X temps
% commander ce script en C depuis Matlab pour gagner du temps

