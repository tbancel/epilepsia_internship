function f = visualize_seizure(output_computed_epochs, crisis_info_matrix, n_crisis, predicted_labels)
    % tool to visualize seizure easily.
    % 
    % takes as INPUTS : 
    % - the output of the compute epoch function
    % - the matrix N x 2 with all informations about the crisis start and
    % end timestamps
    % - the number of the crisis we want to analyze
    % - predicted or labelled value on epochs
    %
    % number of the crisis, the epochs timestamp, as well as the predicted
    % epoch value.
    
    rsignal = output_computed_epochs.chunked_signal;
    rs_time = output_computed_epochs.chunked_time_vector;
    epoch_timestamps = output_computed_epochs.epoch_timestamps;
    epoch_index_time = output_computed_epochs.epoch_index_time;
    
    start_crisis_time = crisis_info_matrix(n_crisis, 1);
    end_crisis_time = crisis_info_matrix(n_crisis, 2);
    crisis_duration = end_crisis_time - start_crisis_time;
    
    x_lim=[(start_crisis_time - 0.2*crisis_duration) (end_crisis_time+0.2*crisis_duration)];
     
    % plot the crisis on top of the curve
    n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);
   
    h1=subplot(2,1,1)
    plot(rs_time, rsignal)
    xlim(x_lim); % limits the drawing to the surroundings of the crisis
    xlabel('Time (s)');
    ylabel('EEG (mV)');
    title(strcat("Crisis number: ", int2str(n_crisis)));
    
    % Add vertical line at the onset and end of crisis
    vline(start_crisis_time, 'r', 'Start Crisis - Manual');
    vline(end_crisis_time, 'r', 'End Crisis - Manual');
    
    % plot epochs in background
    y_lim = ylim;
    y_min = y_lim(1); y_max = y_lim(2);
    y_box = [y_min y_min y_max y_max];
    
    first_epoch_index=min(find(epoch_timestamps>x_lim(1)))-1;
    last_epoch_index=max(find(epoch_timestamps<x_lim(2)));
    
    color= true(1);
    for i=first_epoch_index:last_epoch_index
        x_box=[epoch_timestamps(i) epoch_timestamps(i+1) epoch_timestamps(i+1) epoch_timestamps(i)];
        patch(x_box, y_box, [color 0 0], 'FaceAlpha', 0.1);
        text(epoch_timestamps(i)+0.3*(epoch_timestamps(i+1)-epoch_timestamps(i)), y_min+0.8*(y_max-y_min), strcat("Epoch: ", int2str(i)));
        color = ~color;
    end
    
    % plot the value of the predicted labels
    h2=subplot(2,1,2)
    
    predicted_values = zeros(1,size(epoch_index_time,2)); % size of rsignal (chunked)
    
    for i=1:size(predicted_values,2)
        label_index = epoch_index_time(i);
        predicted_values(i)=predicted_labels(label_index);
    end
    
    plot(rs_time, predicted_values)
    title('Predicted Value from line length')
    xlim(x_lim)
    ylim([-0.5 1.5])

    linkaxes([h1 h2], 'x');
    
    output.start_crisis_time = start_crisis_time;
    output.end_crisis_time = end_crisis_time;  
end