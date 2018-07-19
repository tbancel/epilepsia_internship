function  f = visualize_swd_epoch(time, signal, peaks_timestamps, waves_timestamps, windows)
	% visualize epoch n with peak and waves position and windows separator
	n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);
	
	plot(time, signal); hold on;
    xlim([min(time) max(time)])

    for i=1:numel(peaks_timestamps)
        index_i = min(find(peaks_timestamps(i) < time));
        plot(time(1,index_i), signal(1 , index_i), 'b-*'); hold on;
    end

    for i=1:numel(waves_timestamps)
        index_i = min(find(waves_timestamps(i) < time));
        plot(time(1,index_i), signal(1 , index_i), 'b-o'); hold on;
    end
    
    % plot windows vertical separators
    for i=1:numel(windows)
        vline(time(windows(i)), 'r'); hold on;
    end	


end