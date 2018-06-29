% This script takes a .mat file and predict the seizures using a specific method
% 
% To be improved :
clear; clc;
% close all;
% predict seizure script

% Set the parameters:
% threshold_value = 3.3;
resampling_rate = 30;
approx_epoch_timelength = 1;
percentage = 0.99;

% load the results folder:

current_dir = pwd;
[FileName,PathName,FilterIndex] = uigetfile;
filepath = strcat(PathName,FileName);

data = load(filepath);
varlist = fieldnames(data);

% TO be optimized
% loaded files can be:
% - exported spike 2 channel from Spike2 into .mat file
% - edf physionet database

% in this case we only care of exported spike2 files
relevant_indices = find(~cellfun(@isempty, regexp(varlist, '_Ch'))==1);
relevant_field_name = varlist(relevant_indices(1));

input_signal = data.(relevant_field_name{1});

%%%%%%%%%%%%%%%%%%%%%%%
dt = input_signal.interval;
raw_signal = input_signal.values';
timevector = (1:size(raw_signal,2))*dt;

% predict seizures :
% huge function to refactor
% PAREMETER TO FIX HERE:

% f1=figure(1)
% plot(timevector, raw_signal);
start_baseline = input('debut periode sans crise:');
end_baseline = input('fin periode sans crise:');
% close(f1);

% predict with fixed threshold
% output = predict_seizures_line_length_threshold(FileName, raw_signal, dt, resampling_rate, approx_epoch_timelength, threshold_value);

% predict with varying threshold
baseline = [start_baseline end_baseline];
output = predict_seizures_line_length_baseline(FileName, raw_signal, dt, resampling_rate, approx_epoch_timelength, baseline, percentage);

% plot predicted results: 
visualize_recording_with_prediction(output.resampled_signal.values, output.resampled_signal.timevector, output.predicted_seizures_info, FileName)

% visualize seizures:
n = output.predicted_seizures_summary.number_of_crisis;

% if n > 2
%     for i=1:3
%         visualize_crisis(output.computed_epochs_struct, output.crisis_info_matrix, i, output.predicted_labels);
%     end
% end

% vrac_snr_analysis
% snr(raw_signal, noise)

