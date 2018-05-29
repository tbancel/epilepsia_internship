function res = remove_short_seizures(seizure_info, min_seizure_time)
    t_seizure = seizure_info(:, 2)-seizure_info(:,1);
    index_ = find(t_seizure > min_seizure_time);
    res = seizure_info(index_, :);
end