% select file
% must be a .mat file with structures representing channels
% each structure name has the name of a channel

% compare prediction with labelled manually
clc; close all;
% clear; 

% A discuter demain avec Séverine et Mario
% paramètres à fixer:
N = 30; % resampling rate
approx_epoch_timelength = 1; % durée d'une epoch
f_c = [1 25]; % frequency for signal band filtering


current_dir = pwd;
% folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_labelled_recordings\raw_eeg_only';
%folder = 'C:\Users\thomas.bancel\Documents\data\data_spike2';
cd(folder);

% [FileName,PathName,FilterIndex] = uigetfile('*.mat', 'Get the file you want to analyze (export from Spike2)');
% filepath = strcat(PathName,FileName);
% script_get_raw_file;

filelist = dir('*.mat')

for k=1:1 %size(filelist, 1)
	
    filepath = filelist(k).('name');


    load(filepath);
    signal = data.values_eeg_s1;
    dt = data.interval_eeg_s1;
    % signal = data.values;
    % dt = data.interval;
    fs = 1/dt;
    length = size(signal, 2);
    % crisis_info_matrix = data.seizure_info;
    filename = data.filename;

    % At this point, in the workspace, there are the following variables:
    % - signal
    % - fs
    % - dt
    % - length
    % - crisis_info_matrix

    % Steps:
    % - downsample signal
    % - optional : normalize and filter signal
    % - epoch the signal (reshape)
    % - calculate features on epochs (to be optimized and changed)
    % - create labelled epochs

    % - predict seizures with threshold
    % - calculate specifity, sensitivity and accuracy

    % 1. Downsample signal (1 point every N points);

    rsignal = resample(signal, 1, N);
    frs = fs/N; % resampled frequency
    dtrs=dt*N; % step of time after resampling...
    rs_time = (1:size(rsignal,2))*dtrs; % resample signal
    clear signal; % save some space on that fucking shitty machine :@

    disp('signal downsampled')

    % 1. bis Filter the signal and normalize it (?)
    % Between 1 and 25 Hz for instance:

    rsignal = zscore(rsignal);

    n_filter = 5;
    [b, a] = butter(n_filter, 2*f_c/frs, 'pass');
    rsignal = filtfilt(b, a, rsignal);


    % 2. Epoch the signal

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

    [features, feature_description] = feature_norm_line_length(epoched_signal);

    % 4. Label epoch with the labelled seizures information:

    labelled_crisis_info = get_crisis_info(crisis_info_matrix, filename);
    labelled_epochs = create_labelled_epochs(crisis_info_matrix, number_of_epochs, epoch_timelength);

    % TODO : verify that there is no shift (WRONG!)
    disp('crisis imported and labelled epochs created')


    % 5. Compute AUC curve (with threshold)

    threshold = 0:0.1:10;
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

    method_description = ...
    {erase(filename, '_'),
    "signal downsampled 10 ", 
    "zscored and filtered below 40 Hz",
    "epoch with 50ms second non overlapping",
    feature_description,
    "everything above threshold is considered as a crisis"}; 

    n=size(findobj('type','figure'), 1);
    f=figure(n+1);
    f.Name = "Performance of line length with varying threshold";
    plot(1-performance(:,3), performance(:,2))
    xlabel('1-specifity');
    ylabel('sensitivity');
    annotation('textbox', [.2 .5 .3 .3], 'String', method_description, 'FitBoxToText','on');
    title('ROC curve for threshold value varying between 0 and 5');
    disp('ROC curve for threshold value varying between 0 and 5');

    % 6. Analyze results for a given value of threshold

    auc = performance(:,3).*performance(:,2);
    [max_, index] = max(auc);
    % threshold_value = 3.3;
    threshold_value = performance(index, 4);

    predicted_labels = (features >= threshold_value);
    [accuracy, sensitivity, specificity] = compute_performance(predicted_labels, labelled_epochs);

    predicted_crisis_info_matrix = construct_crisis_info_matrix_from_epochs(predicted_labels, epoch_timelength);
    predicted_crisis_info = get_crisis_info(predicted_crisis_info_matrix, filename);

    visualize_analysis(filename, output_computed_epochs, features, predicted_labels, labelled_epochs, threshold_value);
    visualize_analysis_summary(filename, labelled_crisis_info, predicted_crisis_info, accuracy, sensitivity, specificity, threshold_value);

    % n_crisis=3;
    % f = visualize_crisis(output_computed_epochs, crisis_info_matrix, n_crisis, predicted_labels)

    % Find onset of seizures with diff of line length
    % d_features = diff(features);
    % d_features(size(d_features, 1)+1,1)=0;

end 
% 7. Save the results for further analysis (the smallest file as possible)

disp("save the results");

% script_save_results