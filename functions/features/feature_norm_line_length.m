function [features, feature_description] = feature_norm_line_length(epoched_signal)
    size_epoched_signal = size(epoched_signal);
    number_of_epochs = size_epoched_signal(1);

    % calculate length line
    shifted_epoched = circshift(epoched_signal, -1, 2);
    shifted_epoched(:,size(epoched_signal,2)) = epoched_signal(:,size(epoched_signal,2));
    delta=abs(epoched_signal - shifted_epoched);
    line_length_features(:,1)=sum(delta,2);

    std_ft=std(line_length_features);
    norm_features= line_length_features/std_ft;

    % smoothing the length line (1 before and 1 after)
    % it has to be a parameter in the function
    % TODO

    coeff = ones(3,1)/3;
    smooth_norm_features = filter(coeff, 1, norm_features);
    smooth_norm_features = circshift(smooth_norm_features, -1, 1); % compensate for delay
    smooth_norm_features(number_of_epochs, 1) = smooth_norm_features(number_of_epochs-1, 1); %at the end take the same the previous one

    features = smooth_norm_features;

    feature_description = ...
        ["line length, normalized and smoothed with 3 points"];

    disp('line length calculated and normalized on each epoch')
end
