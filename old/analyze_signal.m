% select file
% must be a .mat file with structures representing channels
% each structure name has the name of a channel

[FileName,PathName,FilterIndex] = uigetfile;
filepath = strcat(PathName,FileName);

load(filepath); % load data variable in the workspace

% find EEG channels and seizures labelling recording

signal = (dataspike2.values)';
length = dataspike2.length; % length of data
dt = dataspike2.interval; % time step
fs= 1/dt; % sampling frequency

time = (1:length)*dt; % time vector

% Steps:
% - downsample signal
% - create epochs
% - calculate features on epochs
% - create label epochs
% - predict seizures with threshold
% - calculate specifity, sensitivity and accuracy
% - compute AUC

% 1. Downsample signal (1 point every N points);

N=30; 
rsignal = resample(signal, 1, N);
frs = fs/N; % resampled frequency
dtrs=dt*N; % step of time after resampling...

rs_time = (1:size(rsignal,2))*dtrs;

clear signal; % save some space on that fucking shitty machine :@

disp('signal downsampled')

% 2. Create epochs

% warning : epochs timelength cannot systematically be a round number of seconds
% because it depends on the clock settings.

approx_epoch_timelength = 1; % in seconds
epoch_length = floor(approx_epoch_timelength*frs); % in number of signal points

% get a huge output structure that will be reused a lot of time.
output_computed_epochs = compute_epoch(rsignal, epoch_length, dtrs);

epoch_timelength = output_computed_epochs.epoch_timelength;
number_of_epochs = output_computed_epochs.number_of_epochs; % number of epochs
rsignal = output_computed_epochs.chunked_signal;
rs_time = output_computed_epochs.chunked_time_vector;
epoch_timestamps = output_computed_epochs.epoch_timestamps;
epoched_signal = output_computed_epochs.epoched_signal;
epoch_index_time = output_computed_epochs.epoch_index_time;

disp('epoch created, signal split in epochs')

% 3. Calculate features

size_epoched_signal = size(epoched_signal);

shifted_epoched = circshift(epoched_signal, -1, 2);
shifted_epoched(:,size(epoched_signal,2))=epoched_signal(:,size(epoched_signal,2));
delta=abs(epoched_signal - shifted_epoched);
features(:,1)=sum(delta,2);

std_ft=std(features);
norm_features= features/std_ft;

disp('line length calculated and normalized on each epoch')

% 4. Plotting the results for a given value of threshold.

threshold_value = 1.3;
predicted_labels = (norm_features >= threshold_value);

disp('labels predicted with threshold value of 1');

figure(2)

subplot(3,1,1)
time_signal=(1:size(rsignal,2))*dtrs;
plot(time_signal, rsignal)
title('EEG recording')

subplot(3,1,2)
plot(predicted_labels)
title('predicted crisis')
ylim([-0.5 1.5])

subplot(3,1,3)
plot(norm_features);
title('line length epoch = 1 second')

% 5. Get the detected crisis:

predicted_crisis_info_matrix = construct_crisis_info_matrix_from_epochs(predicted_labels, epoch_timelength);
crisis_info_output = get_crisis_info(predicted_crisis_info_matrix, 'hist');
n_crisis = crisis_info_output.number_of_crisis;

% 6. Plot 30th crisis

% if n_crisis > 10
%     for i=2:8
%         visualize_crisis(output_computed_epochs, predicted_crisis_info_matrix, i, predicted_labels);
%     end
% end



