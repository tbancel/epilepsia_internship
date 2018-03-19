% To be optimized : NO FOLDER INPUT NAME

performance_table=table(performance(:,1), performance(:,2), performance(:,3), performance(:,4));
performance_table.Properties.VariableNames={'Accuracy', 'Sensivity', 'Specificity', 'Threshold'};

results.filename = FileName;
results.rsignal = rsignal;
results.dtrs = dtrs;

results.epoch_length = epoch_length;
results.method_description = method_description;
results.performance = performance_table;

results.threshold_value = threshold_value;
results.labelled_seizures = crisis_info_matrix;
results.predicted_seizures = predicted_crisis_info_matrix;
results.accuracy = accuracy;
results.sensitivity = sensitivity;
results.specificity = specificity;

% save in the results folder with some trick not to erase things
save_dir = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\';
cd(save_dir);
save(strcat('result_', erase(FileName, '.mat'), '_', datestr(clock, 'yyyy_mm_dd_HHMM')), 'results');
disp("Saved results")
cd('C:\Users\thomas.bancel\Documents\matlab_thomas_internship');
% saved !
