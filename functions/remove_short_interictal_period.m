function output = remove_short_interictal_period(predicted_seizure_matrix, min_ii_time)
	% recursive function
    % complex to explain but TODO
    
    output = [];
    m = predicted_seizure_matrix;
    
	if size(m, 1) == 1
		output = m;
    else
        tmp = remove_short_interictal_period(m(2:size(m,1),:), min_ii_time);
        if tmp(1,1) - m(1,2)  < min_ii_time
            output(1,1) = m(1,1);
            output(1,2) = tmp(1,2);
            if size(tmp, 1) > 1
                output(2:size(tmp,1),:) = tmp(2:size(tmp,1),:);
            end
        else
            output(1,1) = m(1,1);
            output(1,2) = m(1,2);
            output(2:(2+size(tmp,1)-1),:) = tmp;
        end
    end
end