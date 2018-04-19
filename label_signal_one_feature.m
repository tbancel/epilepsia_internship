clc; close all;
% clear;
load('20150422A_Mark_GAERS.mat');
% load('20150424A_Mark_GAERS.mat')
% load('20150512A_Mark_GAERS.mat')
% load('20160722_Mark_GAERS_vigile_stim.mat')
% load('20160729_Mark_GAERS_vigile_stim.mat')

% PARAMETERS TO SET UP:
resampling_rate = 10;
approx_epoch_timelength = 1;
f_c = [1 45];

threshold_value_nf_ll = 1.8;
threshold_value_diff_nf_ll = 1;

min_ii_time = 1;
min_seizure_time = 1;
%%%%%

% BEGINNING OF THE SCRIPT:
signal = data.values_eeg_s1;
time = data.timevector_eeg_s1;
dt = data.interval_eeg_s1;

rsignal = resample(signal, 1, resampling_rate);
dtrs = dt*resampling_rate;
rstime = (1:size(rsignal, 2))*dtrs;

% no centering, only filtering, fsignal for filtered signal
[b, a] = butter(5, 2*f_c*dtrs, 'pass');
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

% compute mean features on baseline
% line length:
mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));

% line length
[f_ll, feature_description] = feature_line_length(compute_epoch_fsignal.epoched_signal);
nf_ll = f_ll/mean_ll_b;

% Remove slow variation of nf_ll:
dt_epoch = compute_epoch_fsignal.epoch_timelength;
f_low = 0.001; 
[b, a] = butter(5, 2*f_low*dt_epoch, 'high');
filtered_nf_ll = abs(filtfilt(b,a,nf_ll));

% predict with fixed threshold
predicted_epochs = (nf_ll >= threshold_value_nf_ll);
predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, compute_epoch_fsignal.epoch_timelength);

% Remove short interictals periods - recursively
output = remove_short_interictal_period(predicted_seizure_matrix, min_ii_time);

% Remove short seizures
t_seizure = predicted_seizure_matrix(:, 2)-predicted_seizure_matrix(:,1);
index_ = find(t_seizure > min_seizure_time);
predicted_seizure_matrix = predicted_seizure_matrix(index_, :);

% remove seizure where there is no steep onset of line length
diff_nf_ll = nf_ll - circshift(nf_ll, 1, 1);
diff_nf_ll(1,1) = 0;
epoch_timestamps = compute_epoch_fsignal.epoch_timestamps;

tmp = [];
n_seizures = size(predicted_seizure_matrix, 1);
epoch_timelength = compute_epoch_fsignal.epoch_timelength;

for i=1:n_seizures
    s_start = predicted_seizure_matrix(i,1);
    s_end = predicted_seizure_matrix(i,2);
    
    steep_times = find(abs(diff_nf_ll) > threshold_value_diff_nf_ll)*epoch_timelength;
    if ~isempty(find(steep_times > s_start & steep_times < s_end))
        tmp = [tmp; s_start s_end];
    end
end

predicted_seizure_matrix = tmp;

predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

%%%%%%% HYPER IMPORTANT OUTPUT
time_hours = max(rstime)/3600;
n_seizures_per_hour = predicted_seizure_info.number_of_crisis/time_hours;
percent_time_spent_in_swd = predicted_seizure_info.time_in_crisis/max(rstime);
%%%%%%%
disp(data.filename)
disp(percent_time_spent_in_swd)
disp("%%%%")

% le faire avant / après une stimulation

% mettre un stop a la fin dans tous les cas, 

figure(3);
h1 = subplot(3,1,1);
plot(rstime, rsignal);
title("Signal")
h2 = subplot(3,1,2);
plot(epoch_timestamps, diff_nf_ll)
hline(threshold_value_diff_nf_ll, 'r', strcat('threshold: ', num2str(threshold_value_diff_nf_ll)));
hline(-threshold_value_diff_nf_ll, 'r', '');
title("Diff line length")
h3 = subplot(3,1,3);
plot(epoch_timestamps, nf_ll)
hline(threshold_value_nf_ll, 'r', strcat('threshold: ', num2str(threshold_value_nf_ll)));
title("Line length")
linkaxes([h1 h2 h3], 'x');

%%%%% VRAC

% visualize features
% figure
% plot(compute_epoch_fsignal.epoch_timestamps, filtered_nf_ll)
% xlabel('Time (s)');

% visualize recording:
visualize_recording_with_feature_calculation(data.filename, rsignal, rstime, predicted_seizure_matrix, nf_ll, compute_epoch_fsignal.epoch_timestamps, threshold_value_nf_ll);
% visualize_recording_with_feature_calculation(data.filename, rsignal, rstime, predicted_seizure_matrix, filtered_nf_ll, compute_epoch_fsignal.epoch_timestamps, threshold_value);

figure
h1=subplot(2,1,1)
plot(compute_epoch_fsignal.epoch_timestamps, filtered_nf_ll)
h2=subplot(2,1,2)
plot(compute_epoch_fsignal.epoch_timestamps, nf_ll)
linkaxes([h1 h2], 'x')