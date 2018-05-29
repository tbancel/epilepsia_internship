% get vision of whole datasets in terms of 
% - number of seizures per hour
% - seizure internal frequencies
% - variability of seizure duration time
% - etc.

clear;
clc; close all;

current_dir = pwd;
folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\matlab_unlabelled_recordings\';
cd(folder);
filelist = dir('*.mat');

filenames = {};
recording_duration = [];
average_number_of_seizures_per_hour = [];
mean_seizure_duration = [];
std_seizure_duration = [];
std_number_of_seizures_per_hour = []; % only if recording is longer than 1 second
mean_seizure_internal_frequencies = [];
std_seizure_internal_frequencies = [];


% load also the signal
for k=1:size(filelist, 1)
	
    filepath = filelist(k).('name');
    disp(filepath)
    drawnow;
    
    load(filepath);
    
    script_label_recording
    
    % seizure_analysis_table = analyze_seizures(data, predicted_seizure_matrix);
    seizure_info_output = get_seizure_info(predicted_seizure_matrix, data.filename);
    
    filenames(k,1) = {data.filename};
    recording_duration(k,1) = max(data.timevector_eeg_s1) - min(data.timevector_eeg_s1);
    average_number_of_seizures_per_hour(k,1) = seizure_info_output.number_of_seizures/(recording_duration(k) / 3600);
    mean_seizure_duration(k,1)=  seizure_info_output.mean_seizure_time;
    std_seizure_duration(k,1) = seizure_info_output.std_seizure_time;
    
    % mean_seizure_internal_frequencies(k,1) = mean(seizure_analysis_table.seizure_internal_frequency);
    % std_seizure_internal_frequencies (k,1) = std(seizure_analysis_table.seizure_internal_frequency);
    
%     if recording_duration > 3600
%         number_of_crisis_in_hour = [];
%         for i=1:floor(recording_duration/3600)+1
%             number_of_seizures(i) = numel(find(data.seizure_info(:,1) < 3600*i)) - numel(find(data.seizure_info(:,1) < 3600*(i-1)));
%             time_in_hour(i) = (max(find(data.timevector_eeg_s1 < 3600*i))-3600*(i-1))/3600;
%             number_of_seizures_in_hour(i) = number_of_seizures(i)/time_in_hour(i);
%         end
%         std_number_of_seizures_per_hour(k,1) = std(number_of_crisis_in_hour);
%     else
%         std_number_of_seizures_per_hour(k,1) = 0;
%     end
    
    visualize_labelled_recording(rsignal, rstime, predicted_seizure_matrix, data.filename);
    % disp(seizure_analysis_table);
end

result_table = table(filenames, recording_duration, average_number_of_seizures_per_hour, ...
    mean_seizure_duration, std_seizure_duration);

% result_table = table(filenames, recording_duration, average_number_of_seizures_per_hour, std_number_of_seizures_per_hour, ...
%    mean_seizure_duration, std_seizure_duration, mean_seizure_internal_frequencies, std_seizure_internal_frequencies);

