% full_script_closed_loop
% TODO's:
% BE ABLE TO CHANGE DURATION TIME OF PULSE
clc; clear; close all;

cd('C:\Users\thomas.bancel\Documents\epilepsia_internship\closed_loop_recordings\');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL CONFIGURATION OF CLOSED LOOP
minutes_to_record = 15; % number of minutes to record
threshold_value_nf_ll = 1.5; % threshold value

approx_epoch_timelength = 0.2; % 200ms
recording_time = minutes_to_record*60; % in seconds
sampling_rate_ced = 1000; % in Hz /!\ be careful, period must be a multiple of the clock period.
channel_to_sample = 4;
stimulation_duration = 0.05;
% END OF GENERAL CONFIGURATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% launch the recording for the baseline w/o stimulation
record_baseline;

% Saving baseline
str_filename = strcat(timestr, '_baseline.mat');
s.filename = str_filename;
s.realtime = realtime;
s.realdata = realdata;
s.sampled_data = data;
s.time_elapsed = time_elapsed;
s.baseline = baseline;
s.sampling_rate_ced = sampling_rate_ced;
s.approx_epoch_timelength = approx_epoch_timelength;
s.channel_to_sample = channel_to_sample;

save(str_filename, 's');

% launch the stimulation
norm_baseline = mean_ll
stimulate_line_length;

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
save(str_filename, 's');
