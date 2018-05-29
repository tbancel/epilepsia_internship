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



% PARAMETERS TO SET UP:
resampling_rate = 10;
approx_epoch_timelength = 1;
f_c = [1 45];

threshold_value_nf_ll = 1.57;
% threshold_value_diff_nf_ll = 1;
% min_ii_time = 1;

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
predicted_seizure_matrix = remove_short_seizures(predicted_seizure_matrix, min_seizure_time);

% remove seizure where there is no steep onset of line length
% predicted_seizure_matrix = remove_low_onset_seizures(predicted_seizure_matrix, nf_ll, threshold_value_diff_nf_ll, computed_epoch_fsignal.epoch_timelength);