clc; close;
% PARAMETERS TO SET UP:
resampling_rate = 30;
approx_epoch_timelength = 1;
f_c = [1 45];

threshold_value = 1.7;

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

% compute mean features on baseline
% line length:
mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));

% line length
[f_ll, feature_description] = feature_line_length(compute_epoch_fsignal.epoched_signal);
nf_ll = f_ll/mean_ll_b;

% Remove slow variation of nf_ll:
% dt_epoch = compute_epoch_fsignal.epoch_timelength;
% f_low = 0.1; 
% [b, a] = butter(5, 2*f_low*dt_epoch, 'high');
% filtered_nf_ll = abs(filtfilt(b,a,nf_ll));

% predict
predicted_epochs = (nf_ll >= threshold_value);
predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, compute_epoch_fsignal.epoch_timelength);
predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

% Remove short seizures
t_seizure = predicted_seizure_matrix(:, 2)-predicted_seizure_matrix(:,1);
index_ = find(t_seizure > 1);

predicted_seizure_matrix = predicted_seizure_matrix(index_, :);

visualize_recording_with_feature_calculation(data.filename, rsignal, rstime, predicted_seizure_matrix, nf_ll, compute_epoch_fsignal.epoch_timestamps, threshold_value);
