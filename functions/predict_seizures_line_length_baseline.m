function output = predict_seizures_line_length_baseline(FileName, raw_signal, dt, resampling_rate, approx_epoch_timelength, baseline, percentage)
    % INPUTS:    
    % - input_signal is a structure containing the following fields: interval
    % and values
    % - approx_epoch_timelength is the length of the epochs in seconds
    % - the baseline corresponds to a 1x2 matrix containing start and end of interictal period.

    % OUTPUT is a structure containing:
    % - the original raw signal (raw_signal) structure
    % - the chunked resampled signal (resampled_signal) (value, interval, timevector)
    % - the resampling_rate
    % - the output structure of the function compute_epochs (with all info about the epochs)
    % - the predicted seizures timestamps (former crisis info matrix)
    % - the predicted seizures info matrix
    % - the general info about the predicted seizures (number of seizures, mean time, std, etc.)
    % - the predicted labels of epochs (predicted labels)
  
    
    % The steps are the same as in main_line_length:
    % - get the signal
    % - resample the signal
    % - compute epochs
    % - calculate features
    % - apply threshold
    
    signal = raw_signal;
    length = size(signal, 2); % length of data
    fs= 1/dt; % sampling frequency
    time = (1:length)*dt; % time vector
    
    % resampling
    N=resampling_rate; 
    rsignal = resample(signal, 1, N);
    frs = fs/N; % resampled frequency
    dtrs=dt*N; % step of time after resampling...
    rs_time = (1:size(rsignal,2))*dtrs; % resample signal

    % see if we had some normalization and filtering
    
    % compute epochs
    epoch_length = floor(approx_epoch_timelength*frs); % in number of signal points
    output_computed_epochs = compute_epoch(rsignal, epoch_length, dtrs);
    number_of_epochs = output_computed_epochs.number_of_epochs;
    
    epoch_timelength = output_computed_epochs.epoch_timelength;
    epoched_signal = output_computed_epochs.epoched_signal;
    rs_time = output_computed_epochs.chunked_time_vector;
    rsignal = output_computed_epochs.chunked_signal;

    
    % calculate features (not smoothed)
    [features, feature_description] = feature_line_length(epoched_signal);

    % calculate baseline threshold:
    baseline_index = find(rs_time > baseline(1,1) & rs_time < baseline(1,2));
    baseline_rsignal = rsignal(baseline_index);
    baseline_rstime = rs_time(baseline_index);
    threshold_value = calculate_baseline_threshold(FileName, baseline_rsignal, dtrs, epoch_length, percentage); 
    
    % apply filter
    predicted_labels = (features >= threshold_value);
    predicted_crisis_info_matrix = construct_crisis_info_matrix_from_epochs(predicted_labels, epoch_timelength);
    predicted_crisis_info = get_crisis_info(predicted_crisis_info_matrix, FileName);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prepare the OUTPUT STRUCTURE
    % Filename
    output.filename = FileName;
    % Raw signal
    output.raw_signal.values = raw_signal;
    output.raw_signal.interval = dt;
    output.raw_signal.timevector = (1:size(raw_signal,2))*dt;
    % Resampled signal
    output.resampled_signal.values = rsignal;
    output.resampled_signal.interval = dtrs;
    output.resampled_signal.timevector = rs_time;
    output.resampling_rate = resampling_rate;
    % Baseline
    output.baseline_rsignal = baseline_rsignal;
    output.baseline_rstime = baseline_rstime;
    output.baseline_timestamps = baseline;
    % Threshold
    output.threshold = threshold_value;
    output.percentage = percentage;
    % Epochs
    output.computed_epochs_struct = output_computed_epochs;
    % Features
    output.features = features;
    % Predicted seizures
    output.predicted_seizures_info = predicted_crisis_info_matrix;
    output.predicted_seizures_summary = predicted_crisis_info;
    output.predicted_labels = predicted_labels;
end
