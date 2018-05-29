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

threshold_value_nf_ll = 1.8;
threshold_value_diff_nf_ll = 1;

min_ii_time = 1;
min_seizure_time = 1;
%%%%%

current_dir = pwd;
folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_labelled_recordings\';
cd(folder);
filelist = dir('*.mat');

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


    [b, a] = butter(5, 2*[6 8]*dtrs, 'bandpass');

    % compute mean features on baseline
    % line length:
    mean_ll_b = mean(feature_line_length(computed_epoch_bsignal.epoched_signal));
    % mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));

    % line length
    [f_ll, feature_description] = feature_line_length(computed_epoch_fsignal.epoched_signal);
    nf_ll = f_ll/mean_ll_b;

    % Not useful (does not work)
    % Remove slow variation of nf_ll:
    % dt_epoch = computed_epoch_fsignal.epoch_timelength;
    % f_low = 0.001; 
    % [b, a] = butter(5, 2*f_low*dt_epoch, 'high');
    % filtered_nf_ll = abs(filtfilt(b,a,nf_ll));

    % predict with fixed threshold
    
    predicted_epochs = (nf_ll >= threshold_value_nf_ll);
    predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, computed_epoch_fsignal.epoch_timelength);

    % Remove short interictals periods - recursively
    predicted_seizure_matrix = remove_short_interictal_period(predicted_seizure_matrix, min_ii_time);

    % Remove short seizures
    predicted_seizure_matrix = remove_short_seizures(predicted_seizure_matrix, min_seizure_time);
    
    % remove seizure where there is no steep onset of line length
    predicted_seizure_matrix = remove_low_onset_seizures(predicted_seizure_matrix, nf_ll, threshold_value_diff_nf_ll, computed_epoch_fsignal.epoch_timelength);

    % Finished the computation
    predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

    %%%%%%% HYPER IMPORTANT OUTPUT
    time_hours = max(rstime)/3600;
    n_seizures_per_hour = predicted_seizure_info.number_of_crisis/time_hours;
    percent_time_spent_in_swd = predicted_seizure_info.time_in_crisis/max(rstime);
    %%%%%%%
    disp(data.filename)
    disp(percent_time_spent_in_swd)
    disp("%%%%")

    % IMPORTANT:
    % if this is a labelled recording, calculate the performance of the
    % algorithm.
    if isfield(data, 'seizure_info')
        labelled_epochs = create_labelled_epochs(data.seizure_info, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);
        predicted_epochs = create_labelled_epochs(predicted_seizure_matrix, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);
        [accuracy, sensitivity, specificity] = compute_performance(predicted_epochs, labelled_epochs);

        predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);
        labelled_seizure_info = get_seizure_info(data.seizure_info, data.filename);

        % visualization:
        visualize_analysis(data.filename, computed_epoch_fsignal, nf_ll, predicted_epochs, labelled_epochs, threshold_value_nf_ll);
        visualize_analysis_summary(data.filename, labelled_seizure_info, predicted_seizure_info, accuracy, sensitivity, specificity, threshold_value_nf_ll);
    end
    
end