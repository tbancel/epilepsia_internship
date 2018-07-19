function sw_detect_perf = sw_detection_perf(labelled_spikes_position, detected_spikes_position)
    % returns a structure containing the following fields:
    % - number of missed / over detected spikes / waves
    % - average precision in ms
    % - std precision in ms
    % - precision / average distance bw 2 spikes
    
    n_labelled_spikes = numel(labelled_spikes_position);
    n_detected_spikes = numel(detected_spikes_position);
    
    
    mean_distance_bw_spikes = mean(abs(diff(labelled_spikes_position)));
    prec = [];
    
    for i=1:n_labelled_spikes
        [m, ind] = min(abs(detected_spikes_position-labelled_spikes_position(i)));
        prec(i) = abs(detected_spikes_position(ind)-labelled_spikes_position(i));
    end
    
    sw_detect_perf.avg_precision = mean(prec);
    sw_detect_perf.std_precision = std(prec);
    sw_detect_perf.relative_precision = mean(prec)/mean_distance_bw_spikes;
    sw_detect_perf.wrong_number = n_detected_spikes - n_labelled_spikes; % can be a negative number
    sw_detect_perf.relative_number = sw_detect_perf.wrong_number / n_labelled_spikes; % idem
end