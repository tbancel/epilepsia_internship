function predicted_seizure_info_matrix = construct_seizure_info_matrix_from_onset_offset(index_onset_epochs, index_offset_epochs, real_epoch_timelength)
	% Once we predicted when a seizure starts and ends, we compute the 
	% predicted seizure info matrix (a Nx2 matrix)
    % the problem is if the two vectors don't have the same size.
    % we do it recursively

    % initial conditions:
    if isempty(index_onset_epochs)
        predicted_seizure_info_matrix = [];
    else 
        [index_of_first_seizure_onset, i] = min(index_onset_epochs);
        [index_of_first_seizure_offset, j] = min(index_offset_epochs(find(index_offset_epochs > index_of_first_seizure_onset)));

        next_index_onset = index_onset_epochs(find(index_onset_epochs > index_of_first_seizure_offset));
        next_index_offset  = index_offset_epochs(find(index_offset_epochs > index_of_first_seizure_offset));
       
        next_seizures = construct_seizure_info_matrix_from_onset_offset(next_index_onset, next_index_offset, real_epoch_timelength)

        first_seizure = [index_of_first_seizure_onset index_of_first_seizure_offset]*real_epoch_timelength;
        predicted_seizure_info_matrix = [first_seizure; next_seizures];
    end
end