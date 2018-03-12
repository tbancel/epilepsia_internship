function crisis_info_output = get_crisis_info(crisis_info_matrix, filename, varargin)
    % takes as an input a Nx2 matrix where N is the number of crisis.
    % each line has 2 columns : start and end timestamps of each crisis.
    
    % output is a structure containing a lot of information
    % - the number of crisis
    % - is the file is ok
    % - the time spent in crisis
    % - the time spent in interictal period
    % - the mean and std of crisis time and interical periods
     
    
    number_of_crisis = size(crisis_info_matrix, 1);
    
    crisis_length = crisis_info_matrix(:,2)-crisis_info_matrix(:,1);
    
    % TO VERIFY 
    % because different methods from constructing index matrix
    interictal_period_length = (circshift(crisis_info_matrix(:,1), -1, 1)-crisis_info_matrix(:,2));
    interictal_period_length(number_of_crisis)=0;
    
    if (crisis_length >= 0) & (interictal_period_length >= 0)
        crisis_info_output.file_ok = true;
    else
        crisis_info_output.file_ok = false;
    end
    
    crisis_info_output.number_of_crisis = number_of_crisis;
    crisis_info_output.time_in_crisis = sum(crisis_length);
    crisis_info_output.interictal_time = sum(interictal_period_length);
    
    crisis_info_output.mean_crisis_time = mean(crisis_length);
    crisis_info_output.std_crisis_time = std(crisis_length);
    crisis_info_output.min_crisis_time = min(crisis_length);
    crisis_info_output.max_crisis_time = max(crisis_length);
    
    crisis_info_output.mean_interictal_time = mean(interictal_period_length);
    crisis_info_output.std_interictal_time = std(interictal_period_length);
    crisis_info_output.min_interictal_time = min(interictal_period_length);
    crisis_info_output.max_interictal_time = max(interictal_period_length);
    
    if nargin > 2
        if varargin{1} == 'hist'
            n=size(findobj('type','figure'), 1);
            f=figure(n+1);
            f.Name = strcat(filename)
            histogram(crisis_length);
            %title(inputname(1));
        end
    end
end
