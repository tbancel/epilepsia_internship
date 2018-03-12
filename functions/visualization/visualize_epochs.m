function visualize_epoch(epoched_signal, epoch_number, dtrs, varargin)
    % get number of figures and creates a new one
    % can contain a structure as an optionnal parameter
    % 
    % varargin.features (Nx1 matrix where N is the epoch number)
    % varargin.labelled_epochs
    % varargin.predicted_labels
    
    % Be careful when signal are resampled
    
    % Can be parametrized
    number_of_additional_epochs = 3;
    starting_epoch = epoch_number - number_of_additional_epochs;
    ending_epoch = epoch_number+ number_of_additional_epochs;
    total_number_of_epochs_displayed = 1+2*number_of_additional_epochs;
    
    n_figures=size(findobj('type','figure'), 1);
    figure(n_figures+1);
    
    n_subplot = length(varargin);
    input = varargin{1};
    input_names = fieldnames(input);
    input_count = numel(input_names);
    
    epoch_length = size(epoched_signal, 2);
    n_epochs = size(epoched_signal, 1);
    
    % First Plot
    subplot(1+input_count, 1, 1)
    relevant_signal = reshape(epoched_signal(starting_epoch:ending_epoch,:), [1, total_number_of_epochs_displayed*epoch_length]);
    
    n_points=size(relevant_signal, 2)
    relevant_time_vector = [(starting_epoch-1)*epoch_length:ending_epoch*epoch_length-1]*dtrs;
    
    plot(relevant_time_vector, relevant_signal)
    xlabel('Time (s)')
    title('Signal')
    
    % Other optional subplot
    for i=1:input_count
        subplot(1+input_count, 1, 1+i)
        plot
        
    end
end
