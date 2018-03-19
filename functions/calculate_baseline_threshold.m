function threshold = calculate_baseline_threshold(filename, baseline_signal, dt, epoch_length, percentage)
    % takes a signal which is interictal and calculate the line length 
    % distribution, define the threshold beyond which we will say that it
    % is a crisis.
    
    output_epoch = compute_epoch(baseline_signal, epoch_length, dt);
    
    [features, feature_description] = feature_line_length(output_epoch.epoched_signal);
    [N, edges] = histcounts(features, 100);
    
    rel_cum_sum = cumsum(N)/sum(N);
    index = min(find(rel_cum_sum > percentage));
    threshold = edges(index+1);

    n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);
    f.Name = filename;
    histogram(features, 100);
    vline(threshold, 'r', strcat("threshold: ",num2str(percentage)))
    xlabel('Inter-ictal line length distribution (mV)')
end