function f = visualize_analysis(FileName, output_computed_epochs, features, predicted_labels, labelled_epochs, threshold_value)
    % Creates and returns a new figure
    % TO BE OPTIMIZED TO BE ADAPTED
    % 
    %  The figures has 4 subplots:
    % - the EEG recording
    % - the manually labelled seizures
    % - the predicted seizures
    % - the feature for each epoch and the threshold 

    % INPUTS :
    % 

    rsignal = output_computed_epochs.chunked_signal;
    dtrs = output_computed_epochs.timestep;
    epoch_timelength = output_computed_epochs.epoch_timelength;
    number_of_epochs = output_computed_epochs.number_of_epochs;
    epoch_timestamps = output_computed_epochs.epoch_timestamps;

    n=size(findobj('type','figure'), 1);
    f=figure(n+1);
    f.Name = strcat(FileName, " Seizure detection");

    h1=subplot(4,1,1);
    time_signal=(1:size(rsignal,2))*dtrs;
    plot(time_signal, rsignal)
    ylabel("mV")
    xlim([0 max(time_signal)])
    title('EEG recording')

    h2=subplot(4,1,2);
    time_epoch =(1:number_of_epochs)*epoch_timelength;
    plot(time_epoch, [labelled_epochs])
    ylim([-0.5 1.5])
    xlim([0 max(time_signal)])
    title('Manually labelled epochs')

    h3=subplot(4,1,3);
    time_epoch =(1:number_of_epochs)*epoch_timelength;
    plot(time_epoch, [predicted_labels])
    ylim([-0.5 1.5])
    xlim([0 max(time_signal)])
    title('Predicted epochs')

    h4=subplot(4,1,4);
    plot(epoch_timestamps, features);
    hline(threshold_value, 'r', strcat('threshold: ', num2str(threshold_value)));
    xlim([0 max(time_signal)])
    title(strcat("line length features with epoch of ", num2str(epoch_timelength)," seconds"));

    linkaxes([h1 h2 h3 h4], 'x');
end