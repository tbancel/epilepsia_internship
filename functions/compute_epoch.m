function output = compute_epoch(signal, time, epoch_length, dt)
    % INPUTS:
    % - signal (1xN matrix)
    % - time (1xN matrix)
    % - epoch length (P) number of points in each epochs
    % - dt : timelaps between each point (somewhat redundant with the vector time)
    % 
    % OUTPUT:
    % - number_of_epochs (N):  number of epochs
    % - epoch_length : P
    % - epoch_timelength: duration of 1 epoch 
    % - epoched_signal: N x P matrix where each line represents an epoch
    % - epoched_time : N x P matrix where each line represents the time on the epoch
    % - chunked_signal: removal of the last non completed epoch of the signal (size equals N*P)
    % - chunked_time_vector: idem with the time vector
    % - epoch_timestamps: N x 1 vector where line(i) gives the start time of epoch(i)
    % - epoch_index_time: vector of same size as chunked_time_vector, but each point has the index of the epoch it belongs to.

    % takes a raw signal and an integer P (epoch_length) as an input and returns 
    % a NxP matrix where each line represents an epoch and P is the length of
    % the epoch
    % throws away last samples if not enough to create a full epoch

    number_of_epochs = floor(size(signal,2)/epoch_length);
    epoched_signal = (reshape(signal(1:number_of_epochs*epoch_length), epoch_length, number_of_epochs))';
    epoched_time = (reshape(time(1:number_of_epochs*epoch_length), epoch_length, number_of_epochs))';
    
    output.number_of_epochs = number_of_epochs;
    output.timestep = dt;
    output.epoch_length = epoch_length;
    output.epoch_timelength = epoch_length*dt;
    
    output.epoched_signal = epoched_signal; % <number_of_epochs> x <epoch_length> matrix
    output.epoched_time = epoched_time;
    
    output.chunked_signal = signal(1:numel(epoched_signal));
    output.chunked_time_vector = time(1:numel(epoched_time));
    
    output.epoch_timestamps = (epoched_time(:, 1)); % <number_of_epochs> x 1 matrix
    output.epoch_index_time = ceil(output.chunked_time_vector/output.epoch_timelength);

end
