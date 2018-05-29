function seizure_info_output = get_seizure_info(seizure_info_matrix, filename, varargin)
    % takes as an input a Nx2 matrix where N is the number of crisis.
    % each line has 2 columns : start and end timestamps of each crisis.
    
    % output is a structure containing a lot of information
    % - the number of crisis
    % - is the file is ok
    % - the time spent in crisis
    % - the time spent in interictal period
    % - the mean and std of crisis time and interical periods
     
    
    number_of_seizures = size(seizure_info_matrix, 1);
    
    seizure_length = seizure_info_matrix(:,2)-seizure_info_matrix(:,1);
    
    if isempty(seizure_info_matrix)
        seizure_info_output = 'No seizure detected';
        return
    end
    
    % TO VERIFY 
    % because different methods from constructing index matrix
    interictal_period_length = (circshift(seizure_info_matrix(:,1), -1, 1)-seizure_info_matrix(:,2));
    interictal_period_length(number_of_seizures)=0;
    
    if (seizure_length >= 0) & (interictal_period_length >= 0)
        seizure_info_output.file_ok = true;
    else
        seizure_info_output.file_ok = false;
    end
    
    seizure_info_output.number_of_seizures = number_of_seizures;
    seizure_info_output.time_in_seizure = sum(seizure_length);
    seizure_info_output.interictal_time = sum(interictal_period_length);
    
    seizure_info_output.mean_seizure_time = mean(seizure_length);
    seizure_info_output.std_seizure_time = std(seizure_length);
    seizure_info_output.min_seizure_time = min(seizure_length);
    seizure_info_output.max_seizure_time = max(seizure_length);
    
    seizure_info_output.mean_interictal_time = mean(interictal_period_length);
    seizure_info_output.std_interictal_time = std(interictal_period_length);
    seizure_info_output.min_interictal_time = min(interictal_period_length);
    seizure_info_output.max_interictal_time = max(interictal_period_length);
    
    if nargin > 2
        if varargin{1} == 'hist'
            n=size(findobj('type','figure'), 1);
            f=figure(n+1);
            f.Name = strcat(filename)
            histogram(seizure_length);
            %title(inputname(1));
        end
    end
end
