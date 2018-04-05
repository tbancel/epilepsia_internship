function predicted_crisis_info_matrix = construct_seizure_info_matrix_from_epochs(predicted_labels, real_epoch_timelength)
    % once we predicted if an epoch is corresponding to a seizure (predicted_epochs), we want to reconstruct a
    % Nx2 vector where each line represents a crisis and gives the time
    % when the crisis starts and the crisis ends
    
    % we add 0 at the end and at the start of the labelled epochs so that we
    % artificially say that a crisis starts at the beginning of the recording
    % if the signal is predicted at 1 at the beginning, at ends at the ends
    % if the signal is predicted at 1 at the end
       
    number_of_epochs = size(predicted_labels, 1);
    
    predicted_labels_mod = [0; predicted_labels; 0];
    shifted_labels_up = circshift(predicted_labels_mod, -1, 1);
    
    delta = predicted_labels_mod - shifted_labels_up;
    start_crisis_index = find(delta == -1);
    end_crisis_index = find(delta == 1) - 1;
    
    predicted_crisis_info_matrix = [start_crisis_index-1 end_crisis_index]*real_epoch_timelength;   
end