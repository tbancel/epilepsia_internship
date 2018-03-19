function [features, feature_description] = feature_line_length(epoched_signal)
    size_epoched_signal = size(epoched_signal);
    number_of_epochs = size_epoched_signal(1);

    % calculate length line
    shifted_epoched = circshift(epoched_signal, -1, 2);
    shifted_epoched(:,size(epoched_signal,2)) = epoched_signal(:,size(epoched_signal,2));
    delta=abs(epoched_signal - shifted_epoched);
    line_length_features(:,1)=sum(delta,2);

    % smoothing the length line (1 before and 1 after)
    coeff = ones(3,1)/3;
    smooth_line_length = filter(coeff, 1, line_length_features);
    smooth_line_length = circshift(smooth_line_length, -1, 1); % compensate for delay
    smooth_line_length(number_of_epochs, 1) = smooth_line_length(number_of_epochs-1, 1); %at the end take the same the previous one

    features = smooth_line_length;

    feature_description = ...
        ["line length, smoothed with 3 points"];

    disp('line length calculated and normalized on each epoch')
end
