% this script calculates a lof features for the load signal
close all; clc;
clear;

% PARAMETERS TO SET UP:
resampling_rate = 30;
approx_epoch_timelength = 1;
f_c = [1 45];

% load all files
filelist = dir('*.mat');
n_files = size(filelist, 1);

for i=1:n_files
    filename = filelist(i).('name');
    load(filename);

    % BEGINNING OF THE SCRIPT:
    signal = data.values_eeg_s1;
    time = data.timevector_eeg_s1;
    dt = data.interval_eeg_s1;

    rsignal = resample(signal, 1, resampling_rate);
    dtrs = dt*30;
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
    compute_epoch_fsignal = compute_epoch(fsignal, epoch_length, dtrs);
    compute_epoch_bsignal = compute_epoch(bsignal, epoch_length, dtrs);

    [b, a] = butter(5, 2*[6 8]*dtrs, 'bandpass');

    % create labelled epochs
    n_epochs = compute_epoch_fsignal.number_of_epochs;
    labelled_epochs = create_labelled_epochs(data.seizure_info, n_epochs, compute_epoch_fsignal.epoch_timelength);
    labelled_seizure_info = get_seizure_info(data.seizure_info, data.filename);

    %%%
    % compute mean features on baseline
    % line length:
    mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));

    % power 6-8
    b_seiz_signal = filtfilt(b, a, bsignal);
    b_seiz_epoch_signal_struc = compute_epoch(b_seiz_signal, epoch_length, dtrs);
    mean_pw_b = mean(rms(b_seiz_epoch_signal_struc.epoched_signal, 2).^2);

    %%%
    % compute features on whole signal:

    % line length
    [f_ll, feature_description] = feature_line_length(compute_epoch_fsignal.epoched_signal);
    nf_ll = f_ll/mean_ll_b;

    % power 6-8
    f_seiz_signal = filtfilt(b, a, fsignal);
    f_seiz_epoch_signal_struc = compute_epoch(f_seiz_signal, epoch_length, dtrs);
    f_pw_6_8 = rms(f_seiz_epoch_signal_struc.epoched_signal, 2).^2/mean_pw_b;

    threshold = 0:0.1:10;
    for i=1:size(threshold,2)
        predicted_epochs = (nf_ll >= threshold(i));
        [accuracy, sensitivity, specificity] = compute_performance(predicted_epochs, labelled_epochs);
        performance(i,1)= accuracy;
        performance(i,2)= sensitivity;
        performance(i,3) = specificity;
        performance(i,4)= threshold(i);

        % add macro information about the performance (number of crisis
        % detected, difference in standard deviation etc.
    end

    method_description = ...
        {erase(data.filename, '_'),
        "signal downsampled 30x ", 
        "filted between 1 and 45 Hz",
        "epoch with 1s second non overlapping",
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

    auc = performance(:,3).*performance(:,2);
    [max_, index] = max(auc);
    threshold_value = performance(index, 4);

    predicted_epochs = (nf_ll >= threshold_value);
    [accuracy, sensitivity, specificity] = compute_performance(predicted_epochs, labelled_epochs);

    predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, compute_epoch_fsignal.epoch_timelength);
    predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

    visualize_analysis(data.filename, compute_epoch_fsignal, nf_ll, predicted_epochs, labelled_epochs, threshold_value);
    visualize_analysis_summary(data.filename, labelled_seizure_info, predicted_seizure_info, accuracy, sensitivity, specificity, threshold_value);
end
    
    
    

%%%%%
% ADDITIONAL STEP

%%%%%
% plot all features on timelength:
% figure(1);
% h1=subplot(3, 1, 1);
% plot(rstime, rsignal);
% xlim([0 max(rstime)]);
% title('Signal');
% h2=subplot(3, 1, 2);
% plot(compute_epoch_fsignal.epoch_timestamps, f_ll);
% xlim([0 max(rstime)]);
% title('Line length over baseline')
% h3=subplot(3, 1, 3);
% plot(compute_epoch_fsignal.epoch_timestamps, f_pw_6_8);
% xlim([0 max(rstime)]);
% title('Power 6_8 over baseline')
% linkaxes([h1 h2 h3], 'x');