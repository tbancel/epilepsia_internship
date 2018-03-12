% analyze the testing dataset...

clc; clear; close all;

% ! labelled folder !
% directory = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data\matlab_labelled_recordings\';

% ! unlabelled folder !
directory = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data\matlab_unlabelled_recordings\';
save_dir = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\unlabelled_recordings\';
current_directory = pwd;
cd(directory)

files = dir('*.mat');
n = numel(files);

approx_epoch_timelength = 1; %the only thing to parameter for this script

final_table = table;

cd(save_dir);

for i=1:n
    
    FileName = files(i).('name');
	filepath = strcat(directory, files(i).('name'));
    
    % loading variables
    data = load(filepath);
	varlist = fieldnames(data);
    relevant_indices = find(~cellfun(@isempty, regexp(varlist, '_Ch'))==1);
    relevant_field_name = varlist(relevant_indices(1));

    % get raw signal
    input_signal = data.(relevant_field_name{1});
    dt = input_signal.interval;
    fs = 1/dt;
    raw_signal = input_signal.values';
    timevector = (1:size(raw_signal,2))*dt;
    
    % Resampling
	N=30; 
    rsignal = resample(raw_signal, 1, N);
    frs = fs/N; % resampled frequency
    dtrs=dt*N; % timestep after resampling
    timevector = (1:size(rsignal, 2))*dtrs;
    
    results.filename = FileName;
    results.rsignal = rsignal;
    results.dtrs = dtrs;
    
    save(strcat('clean_', erase(FileName, '.mat')), 'results');
    disp("Saved results")
% 
%     % plotting
%     h(i) = subplot(4,2,i);
%     plot(timevector, rsignal);
%     title(erase(FileName,'_'));
%     xlim([0 max(timevector)]);
% 
%     % calculate whole signal features
%     signal_entropy = entropy(rsignal);
%     signal_mean = mean(rsignal);
%     signal_std = std(rsignal);
%     signal_snr = snr(rsignal); % signal-to-noise ratio
%     
%     % Epoching
%     epoch_length = floor(approx_epoch_timelength/dtrs);
%     output_epoch = compute_epoch(rsignal, epoch_length, dtrs);
%     epoched_signal = output_epoch.epoched_signal;
%     number_of_epochs = output_epoch.number_of_epochs;
%     
%     % calculate features on each epoch
%     [f_norm_line_length, description]= feature_line_length(epoched_signal);
%     f_signal_entropy = ones(number_of_epochs, 1)*signal_entropy;
%     f_signal_mean = ones(number_of_epochs, 1)*signal_mean;
%     f_signal_std = ones(number_of_epochs, 1)*signal_std;
%     f_signal_snr = ones(number_of_epochs, 1)*signal_snr;
%     [f_entropy, entropy_description] = feature_entropy(epoched_signal);
%     
%     filename = cell(number_of_epochs, 1);
%     filename(:) = {FileName};
%     
%     disp(strcat(FileName, " done!"))
%     
%     var = genvarname(strcat('table_', num2str(i)));
%     
%     current_table = table(filename, f_norm_line_length, f_entropy, f_signal_entropy, f_signal_mean, f_signal_std, f_signal_snr);
%     
%     final_table = [current_table; final_table];
%     % eval([var '= table(filename, f_norm_line_length, f_entropy, f_signal_entropy, f_signal_mean, f_signal_std, f_signal_snr, labels);']);
end