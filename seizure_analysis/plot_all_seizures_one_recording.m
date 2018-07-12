clear; clc; close all;

% load('20150422_Mark_GAERS_Neuron_1225.mat')
% load('20150103_Mark_GAERS_Neuron_1037.mat')
load('20150103_Mark_GAERS_Neuron_1081.mat')
% load('20170213_Theo_GAERS_Data4_78SWD.mat')

number_of_seizures = size(data.seizure_info, 1);

for seizure_number=1:number_of_seizures
    
    % extract seizure signal from total EEG recording
    filename = data.filename;
    signal = data.values_eeg_s1;
    dt = data.interval_eeg_s1;
    fs = 1/dt;
    time = (1:size(signal, 2))*dt;

    seizure_info = data.seizure_info(seizure_number,:);
    seizure_index = find(time > seizure_info(1) & time < seizure_info(2));

    s_signal = signal(seizure_index);
    s_time = time(seizure_index);

    figure(seizure_number)
    plot(s_time, s_signal);
    
end