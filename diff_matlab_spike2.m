% analyze difference between recordings spike2 and matlab recording
% we 
clc; clear; close all;

data1.filename = '20180507_Thomas_playback_Mark.mat';

%%%%%%%
% EXPORT FROM SPIKE 2:
% get EEG values:
load('export_long_rec.mat')

eeg_values_spike2 = V20180507_long_recording_32_bit__Ch4.values';
eeg_interval_spike2 = V20180507_long_recording_32_bit__Ch4.interval;
eeg_fs = 1/eeg_interval_spike2;
eeg_timevector_spike2 = (1:size(eeg_values_spike2, 2))*eeg_interval_spike2;

% get sampling period from Matlab:
samp_starts = V20180507_long_recording_32_bit__Ch11.times;
samp_ends = V20180507_long_recording_32_bit__Ch7.times;

index_samp_start = min(find(eeg_timevector_spike2 > samp_starts));
index_samp_ends = max(find(eeg_timevector_spike2 < samp_ends));

% get stimulation times
% WARNING : I don't get the length of the stimulation

stim_events = V20180507_long_recording_32_bit__Ch2.times;
stim_times(:,1) = stim_events(1:2:numel(stim_events)-1);
stim_times(:,2) = stim_events(2:2:numel(stim_events));
rel_stim_times = stim_times - samp_starts;

% truncate all vectors and plot
truncated_time = eeg_timevector_spike2(index_samp_start:index_samp_ends);
rel_truncated_time = truncated_time-min(truncated_time);
truncated_eeg_values = eeg_values_spike2(index_samp_start:index_samp_ends);
y_min_spike2 = min(truncated_eeg_values);
y_max_spike2 = max(truncated_eeg_values);

%%%%%%
% EXPORT FROM MATLAB
load('matlab_workspace.mat')

m_eeg_timevector = realtime + samp_starts;
m_eeg_values = realdata*y_scale^2; % we correct the mistake from the recording script
m_stim_times = stimulation_times' + samp_starts;

y_min_matlab = min(m_eeg_values);
y_max_matlab = max(m_eeg_values);


%%%%
% PLOTTING
% 1. Spike2 recording
figure(1)
h1=subplot(2,1,1);
plot(truncated_time, truncated_eeg_values);
ylim([y_min_spike2 y_max_spike2]);
title('ECoG recording recorded from Spike2')
xlabel('Time (s)')

% plot stimulation period
% for i=1:size(stim_times, 1)
%     y_box = [y_min_spike2 y_min_spike2 y_max_spike2 y_max_spike2];
%     x_box = [stim_times(i,1) stim_times(i,2) stim_times(i,2) stim_times(i,1)];
%     patch(x_box, y_box, [1 0 0], 'FaceAlpha', 0.1);
%     % vline(stim_times(i,1), 'r', '');
% end

%%%
% 2. Matlab recording
h2=subplot(2,1,2);
plot(m_eeg_timevector, m_eeg_values)
xlabel('Time (s)')
title("ECoG recording recorded from Matlab")
ylim([y_min_spike2 y_max_spike2])

% plot stimulation period
% for i=1:size(m_stim_times,1)
%     y_box = [y_min_matlab y_min_matlab y_max_matlab y_max_matlab];
%     x_box = [m_stim_times(i,1) m_stim_times(i,1)+0.05 m_stim_times(i,1)+0.05 m_stim_times(i,1)];
%     patch(x_box, y_box, [1 0 0], 'FaceAlpha', 0.1);
% end

% xlim([min(truncated_time) max(truncated_time)]);
linkaxes([h1 h2], 'xy');

%%%%%
% SAVE DATA

s.matlab_sampled_data = data*y_scale^2;
s.matlab_fs = fs;
s.matlab_time_elapsed = time_elapsed;
s.matlab_stimulation_times = stimulation_times;
s.matlab_realtime = realtime;
s.matlab_realdata = realdata*y_scale^2;

s.spike2_fs = eeg_fs;
s.spike2_eeg_values = eeg_values_spike2;
s.spike2_eeg_timevector = eeg_timevector_spike2;
s.spike2_matlab_sampling_starts = samp_starts;
s.spike2_matlab_sampling_ends = samp_ends;
s.spike2_stimulation_times = stim_times;
