% TODO: later the input parameters will be :
% - input signal
% - input model (containing epoch timelength, threshold value, resampling rate, etc.)

function output = predict_seizures_norm_line_length_threshold(FileName, raw_signal, dt, resampling_rate, approx_epoch_timelength, threshold_value)
    % INPUTS:    
    % - input_signal is a structure containing the following fields: interval
    % and values
    % - approx_epoch_timelength is the length of the epochs in seconds
    % - the threshold_value is the value of the threshold for the feature
    % classification

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
    
    % compute epochs
    epoch_length = floor(approx_epoch_timelength*frs); % in number of signal points
    output_computed_epochs = compute_epoch(rsignal, epoch_length, dtrs);
    number_of_epochs = output_computed_epochs.number_of_epochs;
    
    epoch_timelength = output_computed_epochs.epoch_timelength;
    epoched_signal = output_computed_epochs.epoched_signal;
    rs_time = output_computed_epochs.chunked_time_vector;
    rsignal = output_computed_epochs.chunked_signal;
    
    % calculate features
    [features, feature_description] = feature_norm_line_length(epoched_signal);

    % apply filter
    predicted_labels = (features >= threshold_value);
    predicted_crisis_info_matrix = construct_crisis_info_matrix_from_epochs(predicted_labels, epoch_timelength);
    predicted_crisis_info = get_crisis_info(predicted_crisis_info_matrix, FileName);
    
    % prepare the OUTPUT STRUCTURE
    output.raw_signal.values = raw_signal;
    output.raw_signal.interval = dt;
    output.raw_signal.timevector = (1:size(raw_signal,2))*dt;

    output.resampled_signal.values = rsignal;
    output.resampled_signal.interval = dtrs;
    output.resampled_signal.timevector = rs_time;
    output.resampling_rate = resampling_rate;
    
    output.computed_epochs_struct = output_computed_epochs;
    
    output.crisis_info_matrix = predicted_crisis_info_matrix;
    output.crisis_info = predicted_crisis_info;
    output.predicted_labels = predicted_labels;
    output.features = features;
end
