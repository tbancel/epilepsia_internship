% load a data structure before:
% with the specification in the notes.md;
clc;
close all;

resampling_rate = 20;
filter_interval = [1 10];
approx_epoch_timelength = 1;
threshold_value = 3.0;

filelist = dir('*.mat');
n_files = size(filelist, 1);

for i=2:2
    filename = filelist(i).('name');
    load(filename);
    
    FileName = data.filename;
    % depending on the type of file
    % raw_signal = data.values;
    % dt = data.interval;
    raw_signal = data.values_eeg_s1;
    dt = data.interval_eeg_s1;

    % contains : resampling, normalzing, filtering, epoching
    output = predict_seizures_norm_line_length_threshold(FileName, raw_signal, dt, resampling_rate, filter_interval, approx_epoch_timelength, threshold_value);

    % visualize_recording_with_prediction(output.resampled_signal.values, output.resampled_signal.timevector, output.predicted_seizures_info, FileName)
    visualize_recording_with_feature_calculation(FileName, output.resampled_signal.values, output.resampled_signal.timevector, output.predicted_seizures_info, output.features, output.computed_epochs_struct.epoch_timestamps, threshold_value);  
end


%%% END %%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% f=figure
% subplot(3,1,1)
% title(data.filename);
% plot(data.timevector_eeg_s1, data.values_eeg_s1)
% subplot(3,1,2)
% plot(output.resampled_signal.timevector, output.resampled_signal.values)
% subplot(3,1,3)
% plot(output.computed_epochs_struct.epoch_timestamps, output.features)
% Plot the threshold
