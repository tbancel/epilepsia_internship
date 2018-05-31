% work on stimulation and ecog

% load('20180515_16_43_stimulation_line_length_recording.mat')
load('20180515_16_43_stim_export_spike2.mat')

% stim_vector = zeros(1,size(realtime, 2));
% for i=1:size(stimulation_times, 2)
%     start_stim_index = min(find(realtime > stimulation_times(1,i)));
%     end_stim_index = max(find(realtime < stimulation_times(1,i)+ stimulation_duration));
%     stim_vector(1,start_stim_index:end_stim_index)=1;
% end
% f_line_length = [0; s.f_line_length];

signal = V20180515_N1047_stimulation_32_bit__Ch1.values';
dt = V20180515_N1047_stimulation_32_bit__Ch1.interval;
stim_times = V20180515_N1047_stimulation_32_bit__Ch2.times(1:2:V20180515_N1047_stimulation_32_bit__Ch2.length-1);
time = (1:size(signal, 2))*dt;

%%% WARNING ONLY FOR THIS FILE
samp_starts = 1048;
samp_ends = 1962;

time_stim_period = time(min(find(time > samp_starts)):max(find(time < samp_ends)));
signal_stim_period = signal(min(find(time > samp_starts)):max(find(time < samp_ends)));
% relevant_stims = stim_times(find(stim_times < samp_ends && stim_times > samp_starts));

plot(time_stim_period, signal_stim_period)


