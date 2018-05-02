% real time analysis:

% In this script, I try to quantify the time it takes to compute the several steps:

% Get the signal for 200ms (approx_epoch_timelength)
% Resample normalize, filter, compute line length
% Compare it to the threshold.
% Record how long it takes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
% RESULTS
%
% The results are the following:
% For 200ms epochs, the mean computation time is 0.64ms
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear;

% 1. epoch signal with certain epoch timelength
% 2. for each epochs: resample, normalize, filter, compute line length, apply threshold
% 3. record time spent

f_c = [1 30];
resample_rate = 5;
approx_epoch_timelength = 0.2;
threshold_value = 2.55;

% folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_unlabelled_recordings\';
% load(strcat(folder, '20150421A_Mark_GAERS.mat'));
load('20150421A_Mark_GAERS.mat')

signal = data.values_eeg_s1;
dt = data.interval_eeg_s1;

% prepare filter:
dtrs = dt*resample_rate;
frs = 1/dtrs;
[b a] = butter(5, 2*f_c/frs,'bandpass');

epoch_length = floor(approx_epoch_timelength/dt);

epoched_signal_struct = compute_epoch(signal, epoch_length, dt);
computation_time = zeros(epoched_signal_struct.number_of_epochs, 1);
epoched_signal = epoched_signal_struct.epoched_signal;
n_epochs = epoched_signal_struct.number_of_epochs;

clearvars epoched_signal_struct data signal
disp("Ready to launch the loop on each epoch")

for i=1:n_epochs
    epoch = epoched_signal(i,:);
    
    tic
    rsignal = resample(epoch, 1, resample_rate);
    nsignal = zscore(rsignal);
    fsignal = filtfilt(b, a, nsignal);
    
    % does not work because it is smoothed:
    % f = feature_line_length(epoch);
    
    shifted_epoch = circshift(epoch, -1, 2);
    shifted_epoch(:,size(epoch,2)) = epoch(:,size(epoch,2));
    delta=abs(epoch - shifted_epoch);
    f=sum(delta,2);
    
    bool = f > threshold_value;
    
    % end of the calculation for each epoch:
    computation_time(i,1) = toc;
end

mean_comp_time = mean(computation_time);
max_time = max(computation_time);
min_time = min(computation_time);
std_comp_time = std(computation_time);
