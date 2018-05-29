function result = remove_low_onset_seizures(seizure_matrix, features, threshold_value_diff_features, epoch_timelength)
    diff_features = features - circshift(features, 1, 1);
    diff_features(1,1) = 0;
    n_seizures = size(seizure_matrix, 1);
    tmp = [];
    
    for i=1:n_seizures
        s_start = seizure_matrix(i,1);
        s_end = seizure_matrix(i,2);

        steep_times = find(abs(diff_features) > threshold_value_diff_features)*epoch_timelength;
        if ~isempty(find(steep_times > s_start & steep_times < s_end))
            tmp = [tmp; s_start s_end];
        end
    end
    
    result = tmp;
end