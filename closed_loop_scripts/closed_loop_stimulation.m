% full_script_closed_loop
% TODO's:
% BE ABLE TO CHANGE DURATION TIME OF PULSE
clc; clear; close all;
delete(timerfindall);

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
recording_baseline.filename = str_filename;
recording_baseline.realtime = output.realtime;
recording_baseline.realdata = output.realdata;

recording_baseline.sampled_data = output.sampled_data;
recording_baseline.sampled_time = output.sampled_time;

recording_baseline.sampling_rate_ced = output.sampling_rate_ced;
recording_baseline.fs = sampling_rate_ced;
recording_baseline.interval = 1/recording_baseline.fs;

recording_baseline.epoch_ends = output.epoch_ends;
recording_baseline.epoch_starts = output.epoch_starts;
recording_baseline.epoch_length = output.epoch_length;

recording_baseline.sampled_channel = output.sampled_channel;

% plot the recorded period and save the figure:
f1=figure(1);
f1.Name = strcat(recording_baseline.filename);
plot(recording_baseline.realtime, recording_baseline.realdata);
xlabel("Time (s)");
title(strcat("Channel CED Analysis: ", num2str(recording_baseline.sampled_channel)));
saveas(f1,strcat(f1.Name, '.png'), 'png');

% warn user that baseline recording has finished (with a song)
% and ask the user for baseline labelling:
% load gong.mat
% sound(y)

% prompt for baseline:
prompt = 'Time beginning baseline (s):';
start_baseline = input(prompt);
prompt = 'Time end baseline (s):';
end_baseline = input(prompt);
baseline = [start_baseline end_baseline];

recording_baseline.baseline = baseline;
save(str_filename, 'recording_baseline');

%%%
% compute normalized line length during baseline:
index_first_epoch_in_baseline = min(find(recording_baseline.sampled_time(:,1) > start_baseline));
index_last_epoch_in_baseline = max(find(recording_baseline.sampled_time(:,1) < end_baseline));

ll_baseline = feature_line_length(recording_baseline.sampled_data(index_first_epoch_in_baseline:index_last_epoch_in_baseline,:));
mean_ll = mean(ll_baseline);
disp(strcat('Mean line length for baseline : ', num2str(mean_ll)));
close all;

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

output_stimulation = record_detect_and_stimulate(channel_to_sample, sampling_rate_ced, approx_epoch_timelength, stimulation_recording_time,  norm_baseline, threshold_value_nf_ll, stim_param);
% run stimulate_line_length.m;

% save the stimulation recording
str_filename = strcat(output_stimulation.timestr, '_stimulation_line_length_recording.mat');
recording_stimulation.filename = str_filename;
recording_stimulation.realtime = output_stimulation.realtime;
recording_stimulation.realdata = output_stimulation.realdata;

recording_stimulation.sampled_data = output_stimulation.sampled_data;
recording_stimulation.sampled_time = output_stimulation.sampled_time;

recording_stimulation.sampling_rate_ced = output_stimulation.sampling_rate_ced;
recording_stimulation.fs = sampling_rate_ced;
recording_stimulation.interval = 1/recording_stimulation.fs;

recording_stimulation.epoch_ends = output_stimulation.epoch_ends;
recording_stimulation.epoch_starts = output_stimulation.epoch_starts;
recording_stimulation.epoch_length = output_stimulation.epoch_length;

recording_stimulation.sampled_channel = output_stimulation.sampled_channel;

recording_stimulation.mean_baseline_ll = output_stimulation.norm_baseline;
recording_stimulation.f_line_length = output_stimulation.f_line_length;
recording_stimulation.seizures = output_stimulation.seizures;
recording_stimulation.executed_stimulation_times = executed_stimulation_times;
recording_stimulation.threshold_value_nf_ll = output_stimulation.threshold_value_nf_ll;
recording_stimulation.model_description = str_description;

save(str_filename, 'recording_stimulation');

plot(recording_stimulation.realtime, recording_stimulation.realdata);
% delete(timerfindall);

% plotting the recording with stimulations
% plot the stimulation and the realdata and saves it
f2=figure(2);
f2.Name = strcat(str_filename);
plot(recording_stimulation.realtime, recording_stimulation.realdata);
xlabel("Time (s)");
title(strcat("Channel CED Analysis: ", num2str(recording_stimulation.sampled_channel)));
for i=1:numel(executed_stimulation_times)
    vline(executed_stimulation_times(1,i), 'r')
end
saveas(f2,strcat(f2.Name, '.png'), 'png');


% 
% End of stimulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%