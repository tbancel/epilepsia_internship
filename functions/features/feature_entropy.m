function [entropy_feature, description] = feature_entropy(epoched_signal)
    n_epochs = size(epoched_signal, 1);
    
    entropy_feature = zeros(n_epochs,1);
    
    for i=1:n_epochs
        entropy_feature(i,1) = entropy(epoched_signal(i,:));
    end
    
    description = ["Entropy of the epochs"];
end
