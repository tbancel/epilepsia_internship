%%%%%%%%%%%%%%%%%%%%%%%%
% Variable declaration:
global stim_params; % structure with the parameters for stimulation
global baseline_recording_time; % number of minutes to record
global stimulation_recording_time; % number of minutes with stimulation on
global threshold_value_nf_ll; % threshold value

global approx_epoch_timelength; % 200ms the CED will sample every XX seconds
global recording_time; % in seconds
global sampling_rate_ced; % in Hz /!\ be careful, period must be a multiple of the clock period.
global channel_to_sample; % channel of the CED that is sampled (ADC: analog to digital converter) and send to the computer
global stimulation_duration;

global planned_stimulation_times;
global executed_stimulation_times;

global AMPI_paradigm;
global AMPI_channel_stimulation;
global AMPI_channel_recording_starts;
global AMPI_channel_recording_ends;


%%%%%%%%%%%%%%%%%%%%%%%%
% Variable setup:
%
% 1. stimulation parameters.

% stimulation duration in seconds 
% the stimulation will continue for the stimulation duration even if 
% the seizure has stopped before the end of the stimulation 
% 
% choose -1 if you want to stimulate until seizure stops.
stim_param.stimulation_duration = 1; 

% minimal spacing between 2 consecutive stimuations
% a short inter-ictal period (shorter than the minimal stimulation spacing) will results in
% 
% choose -1 if you don't want any minimal spacing
stim_param.minimal_stimulation_spacing = 1;

% position of the 
% possible values are : 
% 'w' : stimulate on predicted 'waves'
% 's' : stimulate on predicted 'spikes'
% 'asap': no particular position, as soon as an epoch is labelled as seizure, launch the stimulation 
stim_param.stimulation_position = 'w';

% Variable definition which will be used by the timer functions to share informations
% across several different processes.
planned_stimulation_times = [];
executed_stimulation_times = [];


%%%%%%%%%%%%%%%%%%%%%%%%
% 2.recording parameters.

baseline_recording_time = 5; % number of minutes to record
stimulation_recording_time = 30; % number of minutes with stimulation on
threshold_value_nf_ll = 1.5; % threshold value

approx_epoch_timelength = 0.2; % 200ms the CED will sample every XX seconds
recording_time = minutes_to_record*60; % in seconds
sampling_rate_ced = 1000; % in Hz /!\ be careful, period must be a multiple of the clock period.
channel_to_sample = 4; % channel of the CED that is sampled (ADC: analog to digital converter) and send to the computer
stimulation_duration = 0.05;



