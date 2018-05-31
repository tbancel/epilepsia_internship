% this script emulates what would be the predicted seizure online
% to optimize:
clc; close all;
clear;

%%% parameters to set
acquisition_time = 0.2;
threshold_value_nf_ll = 1.57; 
% sampling_rate = 1000; % in Hz NOT USEFUL YET TO BE ADDED (be able to
% simulate another sampling rate
%%%

% load a file with labelled 
[file, path] = uigetfile;
load(strcat(path, file))


epoch_length = floor(acquisition_time/data.interval_eeg_s1);
output_epoch = compute_epoch(data.values_eeg_s1, epoch_length, data.interval_eeg_s1);

% get baseline and calculate mean 
start_baseline = data.baseline(1);
end_baseline = data.baseline(2);
index_first_epoch_in_baseline = min(find(output_epoch.epoch_timestamps(:,1) > start_baseline));
index_last_epoch_in_baseline = max(find(output_epoch.epoch_timestamps(:,1) < end_baseline-acquisition_time));
ll_baseline = feature_line_length(output_epoch.epoched_signal(index_first_epoch_in_baseline:index_last_epoch_in_baseline,:));
mean_ll = mean(ll_baseline);

% compute norm baseline for the given file


for i=1:size(output_epoch.epoched_signal, 1)
    tic
    if feature_line_length(output_epoch.epoched_signal(i,:)) / mean_ll > threshold_value_nf_ll
        predicted_seizure(i,1) = 1;
    else
        predicted_seizure(i,1) = 0;
    end
    calc_time(i,1) = toc;
end

% get the seizure timestamps
predicted_seizure_info_matrix = construct_seizure_info_matrix_from_epochs(predicted_seizure, output_epoch.epoch_timelength);
visualize_labelled_recording(data.values_eeg_s1, data.timevector_eeg_s1, predicted_seizure_info_matrix, data.filename);

% compute average calculation time:
avg_calc_time = mean(calc_time);

% calculate accuracy, specificity, sensitivity:
labelled_seizure = create_labelled_epochs(data.seizure_info, output_epoch.number_of_epochs, output_epoch.epoch_timelength);
[accuracy, sensitivity, specificity] = compute_performance(predicted_seizure, labelled_seizure);

% compare number of seizure and std:
labelled_seizure_info = get_seizure_info(data.seizure_info);
predicted_seizure_info = get_seizure_info(predicted_seizure_info_matrix);
visualize_analysis_summary(data.filename, labelled_seizure_info, predicted_seizure_info, accuracy, sensitivity, specificity, threshold_value_nf_ll);
