%%%%
% This script takes a .mat file containing a structure with all the recording information:
% - sampled data
% - sampling frequency
% - baseline

% It labels the signal using the line length on each epoched_signal
% All following parameters are easily changeable:

% - resampling_rate
% - approx_epoch_timelength
% - frequency bandpass
% - threshold value for the ratio line_length_epoch / mean_line_length_baseline

% We also add some post validation parameters:
% - steep line length onset
% - minimum seizure and interictal times.


clc; close all;
clear;

% load('20150422A_Mark_GAERS.mat');
% load('20150424A_Mark_GAERS.mat')
% load('20150512A_Mark_GAERS.mat')
% load('20160722_Mark_GAERS_vigile_stim.mat')
% load('20160729_Mark_GAERS_vigile_stim.mat')
% load('20160407_Mark_GAERS_Neuron_486.mat');
% load('20141203_Mark_GAERS_Neuron_1047.mat');

% PARAMETERS TO SET UP:
resampling_rate = 10;
approx_epoch_timelength = 1;
f_c = [1 45];

threshold_value_diff_nf_ll = 1;

min_ii_time = 1;
min_seizure_time = 1;
%%%%%

current_dir = pwd;
folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_labelled_recordings\';
cd(folder);
filelist = dir('*.mat');

filenames = {};
accuracies = [];
specificities = [];
sensitivities = [];
threshold_values = [];

for k=1:size(filelist, 1)
	
    filepath = filelist(k).('name');
    load(filepath);
    
    % BEGINNING OF THE SCRIPT:
    signal = data.values_eeg_s1;
    time = data.timevector_eeg_s1;
    dt = data.interval_eeg_s1;

    rsignal = resample(signal, 1, resampling_rate);
    dtrs = dt*resampling_rate;
    rstime = (1:size(rsignal, 2))*dtrs;

    % no centering, only filtering, fsignal for filtered signal
    [b, a] = butter(5, 2*f_c*dtrs, 'bandpass');
    fsignal = filtfilt(b, a, rsignal);

    % extract baseline signal, bsignal for baseline signal
    index_ = find(rstime > data.baseline(1) & rstime < data.baseline(2));
    bsignal = fsignal(index_);
    btime = rstime(index_);

    % epoch fsignal and bsignal
    epoch_length = floor(approx_epoch_timelength/dtrs);
    computed_epoch_fsignal = compute_epoch(fsignal, epoch_length, dtrs);
    computed_epoch_bsignal = compute_epoch(bsignal, epoch_length, dtrs);

    % compute labelled_epochs:
    labelled_epochs = create_labelled_epochs(data.seizure_info, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);

    [b, a] = butter(5, 2*[6 8]*dtrs, 'bandpass');

    % compute mean features on baseline
    % line length:
    mean_ll_b = mean(feature_line_length(computed_epoch_bsignal.epoched_signal));
    % mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));

    % line length
    [f_ll, feature_description] = feature_line_length(computed_epoch_fsignal.epoched_signal);
    nf_ll = f_ll/mean_ll_b;

    

    % find best threshold
    threshold = 0:0.1:5;
    for i=1:size(threshold,2)
    
        predicted_epochs = (nf_ll >= threshold(i));
        predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, computed_epoch_fsignal.epoch_timelength);

        % Remove short interictals periods - recursively
        % predicted_seizure_matrix = remove_short_interictal_period(predicted_seizure_matrix, min_ii_time);

        % Remove short seizures
        predicted_seizure_matrix = remove_short_seizures(predicted_seizure_matrix, min_seizure_time);

        % remove seizure where there is no steep onset of line length
        % predicted_seizure_matrix = remove_low_onset_seizures(predicted_seizure_matrix, nf_ll, threshold_value_diff_nf_ll, computed_epoch_fsignal.epoch_timelength);

        % compute the predicted_epochs again to compare it to the
        % labelled_epochs
        predicted_epochs = create_labelled_epochs(predicted_seizure_matrix, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);
        [accuracy, sensitivity, specificity] = compute_performance(predicted_epochs, labelled_epochs);

        performance(i,1)= accuracy;
        performance(i,2)= sensitivity;
        performance(i,3) = specificity;
        performance(i,4)= threshold(i);
    end
    
    method_description = ...
    {erase(data.filename, '_'),
    "signal downsampled 10 ", 
    "bandpass [1 45hz]",
    "epoch with 1s non overlapping",
    "line length normalized over mean line length of baseline",
    "remove short seizures",
    "everything above threshold is considered as a crisis"}; 

    % visualize_roc_curve(performance, method_description);

    % find best parameters:
    
    auc = performance(:,3).*performance(:,2);
    [max_, index] = max(auc);
    threshold_value = performance(index, 4);
    % threshold_value = 1.57;
    
    filenames(k,1) = {data.filename};
    accuracies(k,1) = performance(index, 1);
    sensitivities(k,1) = performance(index, 2);
    specificities(k,1) = performance(index, 3);
    threshold_values(k,1) = threshold_value;
    
    predicted_epochs = (nf_ll >= threshold_value);
    predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, computed_epoch_fsignal.epoch_timelength);

    % Remove short interictals periods - recursively
    predicted_seizure_matrix = remove_short_interictal_period(predicted_seizure_matrix, min_ii_time);

    % Remove short seizures
    predicted_seizure_matrix = remove_short_seizures(predicted_seizure_matrix, min_seizure_time);

    % remove seizure where there is no steep onset of line length
    % predicted_seizure_matrix = remove_low_onset_seizures(predicted_seizure_matrix, nf_ll, threshold_value_diff_nf_ll, computed_epoch_fsignal.epoch_timelength);

    % Finished the computation
    predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

    % compute the predicted_epochs AGAIN to compare it to the
    % labelled_epochs
    predicted_epochs = create_labelled_epochs(predicted_seizure_matrix, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);
    [accuracy, sensitivity, specificity] = compute_performance(predicted_epochs, labelled_epochs);


    predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);
    labelled_seizure_info = get_seizure_info(data.seizure_info, data.filename);

    number_of_seizures(k,1) = labelled_seizure_info.number_of_seizures;
    number_of_predicted_seizures(k,1) = predicted_seizure_info.number_of_seizures;
    n = get_number_of_wrongly_detected_seizures(predicted_seizure_matrix, data.seizure_info);
    number_of_false_seizures_per_hour(k,1) = n/max(data.timevector_eeg_s1)*3600;

    % visualization:
    visualize_analysis(data.filename, computed_epoch_fsignal, nf_ll, predicted_epochs, labelled_epochs, threshold_value);
    % visualize_analysis_summary(data.filename, labelled_seizure_info, predicted_seizure_info, accuracy, sensitivity, specificity, threshold_value);
    
end

tt = table(filenames, number_of_seizures, number_of_predicted_seizures, number_of_false_seizures_per_hour, threshold_values, accuracies, sensitivities, specificities);

optimal_threshold = mean(tt.threshold_values);

avg_accuracy = mean(tt.accuracies);
min_accuracy = min(tt.accuracies);

avg_sensitivity = mean(tt.sensitivities);
min_sensitivity = min(tt.sensitivities);

avg_specificity = mean(tt.specificities);
min_specificity = min(tt.specificities);