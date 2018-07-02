% run analysis on 1 hour recording:
clear; clc; close all;

folder ='/Users/tbancel/Desktop/epilepsia_internship/data/matlab_kainite_24h_recording/';
name = '180413a-b_0016_mice1.mat'; % KA2 channel 6-10
% name = '180413a-b_0014_mice1.mat'; % KA1 channel 11-15
channel_number = 11;

load(strcat(folder, name));
%visualize_labelled_recording(data.values(6,:), data.time, [], data.filename);

data.baseline = [1, 40];

% Start of prediction

% PARAMETERS TO SET UP:
resampling_rate = 1;
approx_epoch_timelength = 10;
f_c = [1 45];

threshold_value_nf_ll = 1.7;
threshold_value_diff_nf_ll = 1;

min_ii_time = 1;
min_seizure_time = 1;
%%%%%

    
% BEGINNING OF THE SCRIPT:
signal = data.values(channel_number,:);
time = data.time;
dt = data.interval;

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
% predicted_seizure_matrix = remove_short_interictal_period(predicted_seizure_matrix, min_ii_time);

% Remove short seizures
% predicted_seizure_matrix = remove_short_seizures(predicted_seizure_matrix, min_seizure_time);

% remove seizure where there is no steep onset of line length
% predicted_seizure_matrix = remove_low_onset_seizures(predicted_seizure_matrix, nf_ll, threshold_value_diff_nf_ll, computed_epoch_fsignal.epoch_timelength);

% Finished the computation
predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

% visualize the labelled signal
visualize_labelled_recording(fsignal, rstime, predicted_seizure_matrix, data.filename)

%%%%%%% HYPER IMPORTANT OUTPUT
time_hours = max(rstime)/3600;
n_seizures_per_hour = predicted_seizure_info.number_of_seizures/time_hours;
percent_time_spent_in_swd = predicted_seizure_info.time_in_seizure/max(rstime);
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
