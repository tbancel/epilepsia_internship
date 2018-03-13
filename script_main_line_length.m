% select file
% must be a .mat file with structures representing channels
% each structure name has the name of a channel

% compare prediction with labelled manually
clc; clear; close all;

current_dir = pwd;
[FileName,PathName,FilterIndex] = uigetfile('*.mat', 'Get the file you want to analyze (export from Spike2)');
filepath = strcat(PathName,FileName);

script_get_raw_file;

% At this point, in the workspace, there are the following variables:
% - signal
% - fs
% - dt
% - length
% - crisis_info_matrix

% Steps:
% - downsample signal
% - epoch the signal (reshape)
% - calculate features on epochs (to be optimized and changed)
% - create labelled epochs

% - predict seizures with threshold
% - calculate specifity, sensitivity and accuracy

% 1. Downsample signal (1 point every N points);

N=30; 
rsignal = resample(signal, 1, N);
frs = fs/N; % resampled frequency
dtrs=dt*N; % step of time after resampling...
rs_time = (1:size(rsignal,2))*dtrs; % resample signal
clear signal; % save some space on that fucking shitty machine :@

disp('signal downsampled')


% 2. Epoch the signal

approx_epoch_timelength = 1; % in seconds
epoch_length = floor(approx_epoch_timelength*frs); % in number of signal points

% get an output structure that will be reused a lot of time.
output_computed_epochs = compute_epoch(rsignal, epoch_length, dtrs);

epoch_timelength = output_computed_epochs.epoch_timelength;
number_of_epochs = output_computed_epochs.number_of_epochs; % number of epochs
rsignal = output_computed_epochs.chunked_signal;
rs_time = output_computed_epochs.chunked_time_vector;
epoch_timestamps = output_computed_epochs.epoch_timestamps;
epoched_signal = output_computed_epochs.epoched_signal;
epoch_index_time = output_computed_epochs.epoch_index_time;

disp('epoch created, signal split in epochs')


% 3. Calculate features

[features, feature_description] = feature_line_length(epoched_signal);

% 4. Label epoch with the labelled seizures information:

labelled_crisis_info = get_crisis_info(crisis_info_matrix, FileName);
labelled_epochs = create_labelled_epochs(crisis_info_matrix, number_of_epochs, epoch_timelength);

% TODO : verify that there is no shift (WRONG!)
disp('crisis imported and labelled epochs created')


% 5. Compute AUC curve (with threshold)

threshold = 0:0.1:5;
for i=1:size(threshold,2)
    predicted_labels = (features >= threshold(i));
    [accuracy, sensitivity, specificity] = compute_performance(predicted_labels, labelled_epochs);
    performance(i,1)= accuracy;
    performance(i,2)= sensitivity;
    performance(i,3) = specificity;
    performance(i,4)= threshold(i);
    
    % add macro information about the performance (number of crisis
    % detected, difference in standard deviation etc.
end

% f2=figure(2);
% f2.Name = "Performance of line length with varying threshold";
% plot(1-performance(:,3), performance(:,2))
% xlabel('1-specifity');
% ylabel('sensitivity');
% title('ROC curve for threshold value varying between 0 and 5');
% disp('ROC curve for threshold value varying between 0 and 5');

% 6. Analyze results for a given value of threshold

threshold_value = 3.3;
predicted_labels = (features >= threshold_value);
[accuracy, sensitivity, specificity] = compute_performance(predicted_labels, labelled_epochs);

predicted_crisis_info_matrix = construct_crisis_info_matrix_from_epochs(predicted_labels, epoch_timelength);
predicted_crisis_info = get_crisis_info(predicted_crisis_info_matrix, FileName);

visualize_analysis(FileName, output_computed_epochs, features, predicted_labels, labelled_epochs, threshold_value);
visualize_analysis_summary(FileName, labelled_crisis_info, predicted_crisis_info, accuracy, sensitivity, specificity, threshold_value);

% 7. Save the results for further analysis (the smallest file as possible)

method_description = ...
["signal downsampled 30x ", 
"epoch with 1 second non overlapping",
feature_description,
"threshold is fixed and everything above is considered as a crisis"]; 

% script_save_results