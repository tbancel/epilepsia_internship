% label_seizure_script:
clear;
clc; close all;

load('20170419_Theo_GAERS_Data5_76SWD.mat')

% find two seizures randomly 
number_of_seizures = size(data.seizure_info, 1);
% seizure_numbers = unique([floor(rand*number_of_seizures)+1 floor(rand*number_of_seizures)+1]);
seizure_numbers = floor(rand*number_of_seizures)+1;

for seizure_number=[seizure_numbers]

    wave_locations = [];
    spike_locations = [];
    
    signal = data.values_eeg_s1;
    dt = data.interval_eeg_s1;
    fs = 1/dt;
    time = (1:size(signal, 2))*dt;

    seizure_info = data.seizure_info(seizure_number,:);
    
    % if seizure duration is more than 5 secondes : take 5 random seconds
    seizure_duration = seizure_info(2)-seizure_info(1);
    if seizure_duration > 5
        seizure_info(1) = seizure_info(1)+rand*(seizure_duration-5);
        seizure_info(2) = seizure_info(1)+5;
    end
    
    
    seizure_index = find(time > seizure_info(1) & time < seizure_info(2));

    s_signal = signal(seizure_index);
    s_time = time(seizure_index);
    
    plot(s_time, s_signal);
    disp("Press a key when you have labelled waves on the signal and exported the cursor info")
    pause;
    close all;
    
    for i=1:size(cursor_info, 2)
        wave_locations(i) = cursor_info(i).Position(1); 
    end
    wave_locations = sort(wave_locations);
    
    plot(s_time, s_signal);
    disp("Press a key when you have labelled spikes on the signal and exported the cursor info")
    pause;
    close all;

    for i=1:size(cursor_info, 2)
        spike_locations(i) = cursor_info(i).Position(1); 
    end
    spike_locations = sort(spike_locations);
    
    
    % create the output structure:
    seizure.filename = data.filename;
    seizure.seizure_number = seizure_number;
    
    seizure.signal = s_signal;
    seizure.time = s_time;
    seizure.interval = dt;
    
    seizure.spike_locations = spike_locations;
    seizure.wave_locations = wave_locations;
    
    visualize_swd_seizure(seizure, spike_locations, wave_locations);
    disp("Press enter if you are ok with the labelled seizure");
    pause;
    
    % save the output structure:
    save(strcat(erase(data.filename, '.mat'), '_seizure_', num2str(seizure_number), '.mat'), 'seizure');
end

