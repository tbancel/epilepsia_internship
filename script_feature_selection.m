% This script quickly compiles several features in a table
% where each line is an epoch (labelled or not).
% The table can be inputed in the classificationLearner app of Matlab
% for data exploration and model building.

% very important script which computes a lot of features for each epoch

% The only parameter of the script to fix is the epoch timelength for the
% epoching.
% The signals that we take from the .mat file are already downsampled to
% approx 100Hz.

clc; clear; close all;

% labelled directory
% directory = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\labelled_recordings\';

% unlabelled directory
directory = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\unlabelled_recordings\';

current_directory = pwd;
cd(directory)

files = dir('*.mat');
n = numel(files);

approx_epoch_timelength = 1; %the only thing to parameter for this script

% epoch_length = 90;
% number_of_epochs = 1057; % to create a matrix of homogeneous size

% epoched_signal = zeros(n, number_of_epochs, epoch_length);
% labels = zeros(n, number_of_epochs);
% subject_info = zeros(1, n);
% dtrs_array = zeros(1, n);
% number_of_epochs = zeros(1, n);

% final_table = table;
figure

for i=1:n
    
    FileName = files(i).('name');
	filepath = strcat(directory, files(i).('name'));
    load(filepath);
   
    rsignal = results.rsignal;
    dtrs = results.dtrs;
    timevector = (1:size(rsignal, 2))*dtrs;
    epoch_length = floor(approx_epoch_timelength/dtrs);
   
    % plotting
    h(i) = subplot(5,2,i);
    plot(timevector, rsignal);
    title(erase(results.filename,'_'));
    xlim([0 max(timevector)]);
    
    signal_entropy = entropy(rsignal);
    signal_mean = mean(rsignal);
    signal_std = std(rsignal);
    signal_snr = snr(rsignal); % signal-to-noise ratio
    
    output_epoch = compute_epoch(rsignal, epoch_length, dtrs);
    epoched_signal = output_epoch.epoched_signal;
    number_of_epochs = output_epoch.number_of_epochs;
    
    % labels = create_labelled_epochs(results.labelled_seizures, output_epoch.number_of_epochs, output_epoch.epoch_timelength);
    
    % work on normed signal
    norm_signal = (rsignal-signal_mean)/signal_std; % centered and normalized
    norm_epoched_signal = (epoched_signal-signal_mean)/signal_std;
    
    norm_signal_entropy = entropy(norm_signal); % should not change
    norm_signal_snr = snr(norm_signal); % signal-to-noise ratio (should not change)
    
    % compute features
    % on raw signal
    [f_norm_line_length, description]= feature_line_length(epoched_signal);
    [f_entropy, entropy_description] = feature_entropy(epoched_signal);
    f_signal_entropy = ones(number_of_epochs, 1)*signal_entropy;
    f_signal_mean = ones(number_of_epochs, 1)*signal_mean;
    f_signal_std = ones(number_of_epochs, 1)*signal_std;
    f_signal_snr = ones(number_of_epochs, 1)*signal_snr;
    
    % on normalized signal
    [f_norm_line_length_norm_signal, description]= feature_line_length(norm_epoched_signal);
    [f_entropy_norm_signal, entropy_description] = feature_entropy(norm_epoched_signal);
    f_norm_signal_entropy = ones(number_of_epochs, 1)*norm_signal_entropy;
    f_norm_signal_snr = ones(number_of_epochs, 1)*norm_signal_snr;
    
    % combination of features
    
    
    filename = cell(number_of_epochs, 1);
    filename(:) = {results.filename};
    
    disp(strcat(results.filename, " done!"))
    
    var = genvarname(strcat('table_', num2str(i)));
    
    
    current_table = table(filename, f_norm_line_length, f_entropy, f_signal_entropy, ...
        f_signal_mean, f_signal_std, f_signal_snr, ...
        f_norm_line_length_norm_signal, f_entropy_norm_signal , f_norm_signal_entropy, ...
        f_norm_signal_snr); 
    
    % final_table = [current_table; final_table];
    % eval([var '= table(filename, f_norm_line_length, f_entropy, f_signal_entropy, f_signal_mean, f_signal_std, f_signal_snr, labels);']);
end


% subject_info = table(subject_info, dtrs_array);


% epoched_signal(i,:,:) = output_epoch.epoched_signal(1:number_of_epochs, 1:epoch_length);
% labels(i, :) = labelled_epochs(1:number_of_epochs,1);

% subject_info(1, i) = results.filename;
% dtrs_array(1,i) = dtrs;

% number_of_epochs(1,i) = output_epoch.number_of_epochs;

% h(i) = subplot(5,2,i);
% plot(timevector, rsignal);
% title(erase(results.filename,'_'));
% xlim([0 max(timevector)]);

% feature = snr(rsignal);

% disp(results.filename);
% disp(feature);
