% script to play with SNR and spectogram:
clc; clear; 
close all;

import mlreportgen.report.*
import mlreportgen.dom.*;

% Create report
report = Report('Report variable threshold');

titlepg = TitlePage;
titlepg.Title = 'Giving a baseline to algorithms';
titlepg.Author = 'Thomas BANCEL';
add(report,titlepg);
p = Paragraph('We used 95% of the interictal distribution of line length as a threshold to detect seizures');
add(report, p)

% load the table
% load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\labelled_features_epoch.mat')

% loat the results folder:

% load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\labelled_recordings\result_20170307_Theo_GAERS_Data3_50SWD_2018_03_05_1405.mat')
% load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\labelled_recordings\result_20150103_Mark_GAERS_Neuron_1081_2018_03_08_1154.mat')

current_dir = pwd;
% [FileName,PathName,FilterIndex] = uigetfile;
% filepath = strcat(PathName,FileName);
% load(filepath)

folder_name = uigetdir('*.mat', 'Get the folder you want to analyze');
cd(folder_name);
files = dir('*.mat')

n = numel(files);

for i=1:n
    filename = files(i).('name');
	filepath = strcat(folder_name, '\',files(i).('name'));
    load(filepath);
    
    filename = results.filename;
    chapter = Chapter();
    chapter.Title = filename;
    add(report, chapter);
    
    % TODO
    % histogram of line length repartition outside crisis (the problem with 5%
    % is that we will detect 5% of non crisis as crisis, maybe we can also
    % remove the 5% smaller of the crisis...)

    % LINE LENGTH DISTRIBUTION OUTSIDE CRISIS
    
    signal = results.rsignal;
    dtrs = results.dtrs;
    epoch_length= results.epoch_length;
    labelled_seizures = results.labelled_seizures;

    timevector = (1:size(signal, 2))*dtrs;
    output_epoch_computation = compute_epoch(signal, epoch_length, dtrs);
    number_of_epochs = output_epoch_computation.number_of_epochs;

    labelled_epochs = create_labelled_epochs(labelled_seizures, number_of_epochs, output_epoch_computation.epoch_timelength);

    % visualize_labelled_recording(signal, timevector, labelled_seizures, filename)

    % find in the feature table the lines corresponding to the specific
    % subject:
    index = find(strcmp(final_table.filename, results.filename));
    features_subject = final_table(index, :);

    f_norm_line_length = features_subject.f_norm_line_length;

    line_length_interical = features_subject.f_norm_line_length(find(labelled_epochs == 0));
    line_length_seizures = features_subject.f_norm_line_length(find(labelled_epochs == 1));

    % figure
    % histogram(line_length_seizures)
    % xlabel("norm line length seizures")
    % title(erase(filename, "_"))

    f1=figure(1)
    h=histogram(line_length_interical, 150)
    xlabel("norm line length interictal")
    title(erase(filename, "_"))

    % find 95% threshold
    rel_cum_sum = cumsum(h.Values)/sum(h.Values);
    index_95 = min(find(rel_cum_sum > 0.95));
    threshold_95 = h.BinEdges(index_95+1);

    index_99 = min(find(rel_cum_sum > 0.99));
    threshold_99 = h.BinEdges(index_99+1);

    vline(threshold_95, 'r', '95% threshold');
    vline(threshold_99, 'r', '99% threshold');

    % predict seizures with the threshold determined above
    % and visualize:

    % Parameters to fix for prediction :
    threshold_value = threshold_95;
    resampling_rate = 1; % the input signal is already resampled.
    approx_epoch_timelength = 1;

    output_prediction = predict_seizures(filename, signal, dtrs, resampling_rate, approx_epoch_timelength, threshold_value);
    predicted_crisis_info = output_prediction.crisis_info;
    epoch_timelength = output_prediction.computed_epochs_struct.epoch_timelength;

    % Get the labels:
    labelled_crisis_info = get_crisis_info(labelled_seizures, filename);

    % visualize_recording_with_prediction(output_prediction.resampled_signal.values, output_prediction.resampled_signal.timevector, output_prediction.crisis_info_matrix, filename);

    [accuracy, sensitivity, specificity] = compute_performance(output_prediction.predicted_labels, labelled_epochs);
    f2=visualize_analysis(filename, output_prediction.computed_epochs_struct, f_norm_line_length, output_prediction.predicted_labels, labelled_epochs, threshold_value);
    f3=visualize_analysis_summary(filename, labelled_crisis_info, predicted_crisis_info, accuracy, sensitivity, specificity, threshold_value);

    number_of_crisis = output_prediction.crisis_info.number_of_crisis;

    % for i=1:2
    %     visualize_crisis(output_prediction.computed_epochs_struct, ...
    %         output_prediction.crisis_info_matrix, i,...
    %         output_prediction.predicted_labels);
    % end
    
    f3.Position = [10, 10, 800, 420];
    
    fig1 = Figure(f1);
    fig2 = Figure(f2);
    fig3 = Figure(f3);
    
    add(report, fig1);
    add(report, fig2);
    add(report, fig3);
    
    close all;
end


close(report);
rptview(report);