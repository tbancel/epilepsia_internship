function [accuracy, sensitivity, specificity, positive_predictive_value] = compute_performance(predicted_labels, labeled_epochs)
%     this function takes 2 inputs which should be 1xN matrix of same sizes.
%     each input should only contain 1 or 0, they represent epochs of the signal. 
%     the epoch is labeled with "1" if it is considered to be part of a crisis, and "0" if it is considered to be inter-ictal.
    
    number_of_epochs = length(labeled_epochs);
    
    accurate_labels = (predicted_labels == labeled_epochs);
    accuracy = sum(accurate_labels)/number_of_epochs;
    
    TP=0;
    TN=0;
    FN=0;
    FP=0;
    %result=[];
    
    for i=1:number_of_epochs
        if (accurate_labels(i)==1) & (labeled_epochs(i)==1)
            % result(i)='TP';
            TP=TP+1;
        elseif (accurate_labels(i)==1) & (labeled_epochs(i)==0)
            % result(i)='TN';
            TN=TN+1;
        elseif (accurate_labels(i)==0) & (labeled_epochs(i)==1)
            % result(i)='FN';
            FN=FN+1;
        elseif (accurate_labels(i)==0) & (labeled_epochs(i)==0)
            % result(i)= 'FP';
            FP=FP+1;
        end
    end
    
    sensitivity = TP/(TP+FN);
    specificity = TN/(FP+TN);
    positive_predicted_value = TP/(TP+FP);
    
end