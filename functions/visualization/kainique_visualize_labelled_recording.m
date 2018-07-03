function f = kainique_visualize_labelled_recording(signal, timevector, seizure_info_matrix, channelname_cells, filename)
    % signal is a matrix n_lines = number of channels, n_columns = time series
    % channelnames has the same number of elements as size(signal, 1)

    n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);
    f.Name = filename;
    
    subplot_array = [];

    for i=1:size(signal,1)
        a = genvarname(strcat('h', num2str(i)));
        a = subplot(size(signal, 1),1,i);
        plot(timevector, signal(i,:));
        ylabel(strcat(channelname_cells{i}, ' - EEG (mV)'));
        xlim([0 max(timevector)]);
        hold on;

        y_lim = ylim;
        y_min = y_lim(1); y_max = y_lim(2);

        for j=1:size(seizure_info_matrix, 1)
            y_box = [y_min y_min y_max y_max];
            x_box = [seizure_info_matrix(j,1) seizure_info_matrix(j,2) seizure_info_matrix(j,2) seizure_info_matrix(j,1)];
            patch(x_box, y_box, [1 0 0], 'FaceAlpha', 0.1);
        end
        hold on;

        subplot_array(i)=a;
    end
    
    xlabel('Time (s)');
    linkaxes(subplot_array, 'x');
end