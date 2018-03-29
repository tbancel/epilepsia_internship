function labelled_epochs = create_labelled_epochs(crisis_info_matrix, number_of_epochs, real_epoch_timelength)
%     from the Nx2 matrix giving start and end timestamp of each crisis, and given the
%     duration of one epoch as well as the number of total epochs, the function returns the labelled
%     epochs

    labelled_epochs = zeros(number_of_epochs,1);
    number_of_crisis = size(crisis_info_matrix, 1);
    
    for i=1:number_of_crisis
        crisis_starts = crisis_info_matrix(i,1);
        crisis_ends = crisis_info_matrix(i,2);
        
        index_epoch_start= floor(crisis_starts/real_epoch_timelength)+1;
        index_epoch_stop= floor(crisis_ends/real_epoch_timelength);
        
        labelled_epochs(index_epoch_start:index_epoch_stop,1)=1;
    end
end
