function f = visualize_recording_with_prediction(signal, timevector, crisis_info_matrix, filename)
    n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);
    f.Name = filename;
    
    h1=subplot(2,1,1)
    plot(timevector, signal)
    xlabel('Time (s)');
    ylabel('EEG (mV)');
    xlim([0 max(timevector)]);
    title('EEG recording');
    
    h2=subplot(2,1,2)
    plot(timevector, signal)
    xlabel('Time (s)');
    ylabel('EEG (mV)');
    xlim([0 max(timevector)]);
    title('Predicted EEG recording');
    
    hold on

    % plot seizures in background
    y_lim = ylim;
    y_min = y_lim(1); y_max = y_lim(2);

    for i=1:size(crisis_info_matrix, 1)
    	y_box = [y_min y_min y_max y_max];
    	x_box = [crisis_info_matrix(i,1) crisis_info_matrix(i,2) crisis_info_matrix(i,2) crisis_info_matrix(i,1)];
    	patch(x_box, y_box, [1 0 0], 'FaceAlpha', 0.1);
    end

    linkaxes([h1 h2], 'xy');
end