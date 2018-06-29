function n = get_number_of_wrongly_detected_seizures(predicted_seizure_matrix, labelled_seizure_matrix)
	% finds the number of seizures in the predicted_seizure_matrix which are not overlapping
	% with any of the seizures in the labelled seizure matrix
	
	n = 0;
	for i=1:size(predicted_seizure_matrix, 1)
		max_index_start = max(find(labelled_seizure_matrix(:,1) < predicted_seizure_matrix(i,2)));
		start_time = labelled_seizure_matrix(max_index_start, 1);
		end_time = labelled_seizure_matrix(max_index_start, 2);
		if end_time < predicted_seizure_matrix(i, 1)
			n = n+1;
		end
	end
end
