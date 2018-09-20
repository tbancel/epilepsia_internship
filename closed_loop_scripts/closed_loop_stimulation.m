% full_script_closed_loop
% TODO's:
% BE ABLE TO CHANGE DURATION TIME OF PULSE
clc; clear; close all;

cd('C:\Users\thomas.bancel\Documents\epilepsia_internship\closed_loop_recordings\');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL CONFIGURATION OF CLOSED LOOP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load the stimulation parameters
run stimulation_parameters.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF GENERAL CONFIGURATION         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Launch the recording without    %
% stimulation to compute baseline    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output = record_baseline(channel_to_sample, sampling_rate_ced, approx_epoch_timelength, baseline_recording_time);

% Saving baseline recording:
str_filename = strcat(output.timestr, '_baseline.mat'); % it is defined in the record_baseline.m file
recording.filename = str_filename;
recording.realtime = output.realtime;
recording.realdata = output.realdata;

recording.sampled_data = output.data;
recording.sampled_time = output.sampled_time;

recording.sampling_rate_ced = output.sampling_rate_ced;
recording.fs = sampling_rate_ced;
recording.interval = 1/fs;

recording.epoch_ends = output.epoch_ends;
recording.epoch_starts = output.epoch_starts;
recording.approx_epoch_timelength = output.approx_epoch_timelength;
recording.epoch_length = output.epoch_length;

recording.channel_sampled = output.channel_sampled;

% plot the recorded period and save the figure:
f1=figure(1);
f1.Name = strcat(recording.timestr,'_baseline_recording_figure');
plot(recording.realtime, recording.realdata);
xlabel("Time (s)");
title(strcat("Channel CED Analysis: ", num2str(channel_to_sample)));
saveas(f1,strcat(f1.Name, '.png'), 'png');

% warn user that baseline recording has finished (with a song)
% and ask the user for baseline labelling:
load gong.mat
sound(y)

% prompt for baseline:
prompt = 'Time beginning baseline (s):';
start_baseline = input(prompt);
prompt = 'Time end baseline (s):';
end_baseline = input(prompt);
baseline = [start_baseline end_baseline];

recording.baseline = baseline;
save(str_filename, 'recording');

% compute normalized line length during baseline:
index_first_epoch_in_baseline = min(find(recording.realtime(:,1) > start_baseline));
index_last_epoch_in_baseline = max(find(recording.realtime(:,1) < end_baseline));

ll_baseline = feature_line_length(data(index_first_epoch_in_baseline:index_last_epoch_in_baseline,:));
mean_ll = mean(ll_baseline);
disp(strcat('Mean line length for baseline : ', num2str(mean_ll)));

%
% End of baseline recording
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. launch the stimulation
% It records the same way as for the baseline recording but launch stimulations depending on the
% stimulations parameters.
%
str_description = {'norm_baseline is determined, seizure if f_line_length / norm_baseline > 1.5'};
norm_baseline = mean_ll;

output = record_detect_and_stimulate()
run stimulate_line_length.m;

% save the stimulation recording
str_filename = strcat(timestr, '_stimulation_line_length_recording.mat');
s.filename = str_filename;
s.realtime = realtime;
s.realdata = realdata;
s.sampled_data = data;
s.time_elapsed = time_elapsed;
s.mean_baseline_ll = norm_baseline;
s.sampling_rate_ced = sampling_rate_ced;
s.approx_epoch_timelength = approx_epoch_timelength;
s.channel_to_sample = channel_to_sample;
s.f_line_length = line_length;
s.seizures = seizures;
s.stimulation_times = stimulation_times;
s.stim_vector = stim_vector; % vector which has the same size as the realtime vector
s.threshold_value_nf_ll = threshold_value_nf_ll;
s.model_description = str_description;
save(str_filename, 's');

% plotting the recording with stimulations
% plot the stimulation and the realdata and saves it
f2=figure(2);
f2.Name = strcat(timestr,'_stimulation_line_length_recording_figure');
h1=subplot(2,1,1)
plot(realtime, realdata);
xlabel("Time (s)");
title(strcat("Channel CED Analysis: ", num2str(chan)));
h2=subplot(2,1,2)
plot(realtime, stim_vector);
ylim([-1 2])
xlabel("Time (s)");
title("Stimulation");
linkaxes([h1 h2], 'x');
saveas(f2,strcat(f2.Name, '.png'), 'png');


% 
% End of stimulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%