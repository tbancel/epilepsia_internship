% analyze evoked response potential

clc; clear;
close all;
% A relire

% file with stimulation
% load('20150909B_Mark_GAERS.mat')
load('20151019C6462_Mark_GAERS.mat')

% PARAMETERS TO FIX HERE:
% n_stim_erp = 20;
time_window_stim = [6270 6310];

% get the predicted seizures
% label_signal_one_feature

% get clean stimulation vector:
c_values_puffs(1,find(data.values_puffs > 3.5))=1;
c_values_puffs(1,find(data.values_puffs <= 3.5))=0;

% plot puff and eeg
f=figure(1)
f.Name = data.filename;

h1=subplot(2,1,1);
plot(data.timevector_puffs, c_values_puffs)
title('Air Puff')
xlabel('Time (s)')
h2=subplot(2,1,2);
plot(data.timevector_eeg_s1, data.values_eeg_s1)
title('EEG S1')
xlabel('Time (s)')
ylabel('EEG (mV)')
linkaxes([h1 h2], 'x')

% identify stimulation (start end, duration, position):
shifted_stim = circshift(c_values_puffs, 1, 2);
diff = c_values_puffs-shifted_stim;
index_stim = find(diff == 1);
time_stim = data.timevector_puffs(index_stim);

n_stim = size(index_stim, 2);

index_relevant_stim = find(time_stim < time_window_stim(1,2) & time_stim > time_window_stim(1,1));


evoked_response = [];
time_window = 0.5; % 100ms before stim and 400ms after stim
n_sample_window = floor(time_window/data.interval_eeg_s1);
time_window = -0.1+(0:n_sample_window)*data.interval_eeg_s1;

f2=figure(2);
f2.Name = data.filename;
subplot(2,1,1)
for i=index_relevant_stim
    time_stim_i = data.timevector_puffs(index_stim(i)); % in second
    index_time_eeg_start_window = min(find(data.timevector_eeg_s1 > (time_stim_i - 0.1)));
    evoked_response(i,:) = data.values_eeg_s1(1, (index_time_eeg_start_window:index_time_eeg_start_window+n_sample_window));
    plot(time_window, evoked_response(i,:)); hold on
end
vline(0, 'r', 'Stimulation')
xlabel('Time (s)')
ylabel('EEG S1 (mv)')
title('Evoked Response (mV)')

% plot average
erp=mean(evoked_response, 1);
subplot(2,1,2)
plot(time_window, erp)
vline(0, 'r', 'Stimulation')
xlabel('Time (s)')
ylabel('EEG S1 (mv)')
title('Average response potential')


% plot specific times of simulation
f3=figure(3)
f3.Name = data.filename;

% start_t = data.timevector_puffs(index_stim(1)) - 1;
% end_t = data.timevector_puffs(index_stim(n_stim_erp)) + 1;
start_t = time_window_stim(1,1) -1;
end_t = time_window_stim(1,2)+1;

index_t_eeg = find(data.timevector_eeg_s1 > start_t & data.timevector_eeg_s1 < end_t);
index_t_puff = find(data.timevector_puffs > start_t & data.timevector_puffs < end_t);

h1=subplot(2,1,1);
plot(data.timevector_puffs(index_t_puff), c_values_puffs(index_t_puff))
title('Air Puff')
xlabel('Time (s)')
h2=subplot(2,1,2);
plot(data.timevector_eeg_s1(index_t_eeg), data.values_eeg_s1(index_t_eeg))
title('EEG S1')
xlabel('Time (s)')
ylabel('EEG (mV)')
linkaxes([h1 h2], 'x')