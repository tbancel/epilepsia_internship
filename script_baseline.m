% OLD SCRIPT

%
%


% clc; close all;
N = 30; % resampling rate
percentage = 0.99;

signal = data.values;
dt = data.interval;

rsignal = resample(signal, 1, N);
dtrs = dt*N;
rs_time = (1:size(rsignal, 2))*dtrs;

start_baseline = data.seizure_info(3,2);
end_baseline = data.seizure_info(4,1);

baseline = [start_baseline end_baseline];

% visualize_labelled_recording(rsignal, rs_time, data.seizure_info, data.filename);
output_epoch = compute_epoch(rsignal, floor(1/dtrs), dtrs);

baseline_signal = rsignal(find(rs_time > baseline(1,1) & rs_time < baseline(1,2)));
baseline_time = rs_time(find(rs_time > baseline(1,1) & rs_time < baseline(1,2)));

% threshold = calculate_baseline_threshold(baseline_signal, dtrs, floor(1/dtrs), percentage);
% [features, features_description] = feature_line_length(output_epoch.epoched_signal);

output_prediction = predict_seizures_line_length_baseline(data.filename, signal, dt, N, 1, baseline, percentage);
labels = create_labelled_epochs(data.seizure_info, output_epoch.number_of_epochs, output_epoch.epoch_timelength);

% visualize_recording_with_prediction(output_prediction.resampled_signal.values, output_prediction.resampled_signal.timevector, output_prediction.crisis_info_matrix, data.filename);
visualize_analysis(data.filename, output_epoch, output_prediction.features, output_prediction.predicted_labels, labels, output_prediction.threshold);

% summary:
[accuracy, sensitivity, specificity] = compute_performance(output_prediction.predicted_labels, labels);
visualize_analysis_summary(data.filename, get_crisis_info(data.seizure_info, data.filename) ,output_prediction.predicted_seizures_summary, accuracy, sensitivity, specificity, output_prediction.threshold);

