% In this script, we apply a chosen model to predict the label of the
% epochs (seizure or not). We load the unlabelled file (in the unlabelled
% file folder).

clc; clear;
current_dir = pwd;

% 1. get the model
% [FileName,PathName,FilterIndex] = uigetfile('*.mat','Get the model');
% filepath = strcat(PathName,FileName);
% load(filepath);
% called trainedModel
load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\trained_model\svm_lot_of_features.mat')

% load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\trained_model\classification_tree.mat');
% load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data_results\trained_model\classification_tree.mat');

% 2. Set preprocessing parameters
N=30; 
approx_epoch_timelength = 1;

% 3. load the recording to be predicted (take the results structure in the
% dedicated folder)
[FileName,PathName,FilterIndex] = uigetfile('*.mat', 'Get the recording to predict');
filepath = strcat(PathName,FileName);

load(filepath);

% 4. load the file with all the features saved.
load('C:\Users\thomas.bancel\Documents\matlab_thomas_internship\unlabelled_features_epoch.mat');

% 5. get the prediction, display the results.
rsignal = results.rsignal;
dtrs = results.dtrs;
timevector = (1:size(rsignal, 2))*dtrs;

yfit = trainedModel.predictFcn(final_table);

index = find(strcmp(final_table.filename, results.filename));
predicted_epochs = yfit(index);

epoch_length = floor(approx_epoch_timelength/dtrs);
output_epoch = compute_epoch(rsignal, epoch_length, dtrs);

epoch_timelength = output_epoch.epoch_timelength;
crisis_info_matrix = construct_crisis_info_matrix_from_epochs(yfit, epoch_timelength);

model_name = "SVM with different features";
visualize_recording_with_prediction(rsignal, timevector, crisis_info_matrix, results.filename);


% % in this case we only care of exported spike2 files
% relevant_indices = find(~cellfun(@isempty, regexp(varlist, '_Ch'))==1);
% relevant_field_name = varlist(relevant_indices(1));
% 
% % 4. Get the signal
% input_signal = data.(relevant_field_name{1});
% dt = input_signal.interval;
% fs = 1/dt;
% raw_signal = input_signal.values';
% timevector = (1:size(raw_signal,2))*dt;
% 
% % 5. Resample the signal
% 
% rsignal = resample(raw_signal, 1, N);
% frs = fs/N; % resampled frequency
% dtrs=dt*N; % step of time after resampling...
% timevector = (1:size(rsignal, 2))*dtrs;
% epoch_length = floor(approx_epoch_timelength/dtrs);
% 
% % 6. Compute features
% 
% signal_entropy = entropy(rsignal);
% signal_mean = mean(rsignal);
% signal_std = std(rsignal);
% signal_snr = snr(rsignal); % signal-to-noise ratio
% 
% output_epoch = compute_epoch(rsignal, epoch_length, dtrs);
% epoched_signal = output_epoch.epoched_signal;
% number_of_epochs = output_epoch.number_of_epochs;
% 
% [f_norm_line_length, description]= feature_line_length(epoched_signal);
% f_signal_entropy = ones(number_of_epochs, 1)*signal_entropy;
% f_signal_mean = ones(number_of_epochs, 1)*signal_mean;
% f_signal_std = ones(number_of_epochs, 1)*signal_std;
% f_signal_snr = ones(number_of_epochs, 1)*signal_snr;
% [f_entropy, entropy_description] = feature_entropy(epoched_signal);
% 
% % 7. create table
% t=table(f_norm_line_length, f_entropy, f_signal_entropy, f_signal_mean, f_signal_std, f_signal_snr);
% 
% % 8. predict with the model



