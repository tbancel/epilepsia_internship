function [features, feature_description] = feature_line_length(epoched_signal)
    % this function calculates the line length for each epoch of the
    % epoched signal
    
    % INPUTS :
    % - epoch_signal : NxM matrix where N is the number of epochs, M the
    % number of samples per epochs. Each element is the value of the
    % sampled signal
    
    % OUPUTS :
    % - features : Nx1 vector where each element is the value of the line
    % length for each epoch smoothed by 3 values around
    % - feature_description : array of string containing a short
    % description of the method.
   
    size_epoched_signal = size(epoched_signal);
    number_of_epochs = size_epoched_signal(1);

    % calculate length line
    shifted_epoched = circshift(epoched_signal, -1, 2);
    shifted_epoched(:,size(epoched_signal,2)) = epoched_signal(:,size(epoched_signal,2));
    delta=abs(epoched_signal - shifted_epoched);
    line_length_features(:,1)=sum(delta,2);

    % % smoothing the length line (1 before and 1 after)
    % coeff = ones(3,1)/3;
    % smooth_line_length = filter(coeff, 1, line_length_features);
    % smooth_line_length = circshift(smooth_line_length, -1, 1); % compensate for delay
    % smooth_line_length(number_of_epochs, 1) = smooth_line_length(number_of_epochs-1, 1); %at the end take the same the previous one

    features = line_length_features;

    feature_description = ...
        ["line length"];

    % disp('line length calculated and normalized on each epoch')
end
