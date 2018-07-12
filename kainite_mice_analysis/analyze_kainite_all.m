% run analysis on 1 hour recording:
clear all; 
clc; close all;

%%%%%
% PARAMETERS TO SET UP:
resampling_rate = 1;
f_c = [1 45];

threshold_value_nf_ll = 1.8;
approx_epoch_timelength = 10; % we want to detect at least 10s seizures
%%%%%%

% channel_number = 6; 
% KA2: channel 6-10 // KA1: channel 11-15
%%%%%

folder ='\\10.5.42.1\reve\TeamCharpier\Projet T Bancel\20180330\EEG2\matfiles\';
% folder ='/Users/tbancel/Desktop/epilepsia_internship/data/matlab_kainite_2_20180415/';
% folder ='/Users/tbancel/Desktop/epilepsia_internship/data/matlab_kainite_3_matlab_kainite_3_20180414_diazepam/';


cd(folder)
list = dir(fullfile(folder, '*.mat'));

% get baseline
% for each rat and need to define a channel and a baseline
    
h=1;

% i for the files
% channel_number for the rat
% 

for i=17:17%1:numel(list)
    load(list(i).('name'))

    % WARNING
    data.baseline = [1, 40]; % TO OPTIMIZE BECAUSE THERE COULD BE A SEIZURE THERE !!

    % we do it for each rat:
    for channel_number=11 %channel_number=[1,6,11]
        % BEGINNING OF THE SCRIPT:
        signal = data.values(channel_number,:);
        time = data.time;
        dt = data.interval;

        rsignal = resample(signal, 1, resampling_rate);
        dtrs = dt*resampling_rate;
        rstime = (1:size(rsignal, 2))*dtrs;

        % no centering, only filtering, fsignal for filtered signal
        [b, a] = butter(5, 2*f_c*dtrs, 'bandpass');
        fsignal = filtfilt(b, a, rsignal);

        % extract baseline signal, bsignal for baseline signal
        index_ = find(rstime > data.baseline(1) & rstime < data.baseline(2));
        bsignal = fsignal(index_);
        btime = rstime(index_);

        % epoch fsignal and bsignal
        epoch_length = floor(approx_epoch_timelength/dtrs);
        computed_epoch_fsignal = compute_epoch(fsignal, epoch_length, dtrs);
        computed_epoch_bsignal = compute_epoch(bsignal, epoch_length, dtrs);

        % compute mean features on baseline
        % line length:
        mean_ll_b = mean(feature_line_length(computed_epoch_bsignal.epoched_signal));
        % mean_ll_b = mean(feature_line_length(compute_epoch_bsignal.epoched_signal));

        % line length
        [f_ll, feature_description] = feature_line_length(computed_epoch_fsignal.epoched_signal);
        nf_ll = f_ll/mean_ll_b;

        % predict with fixed threshold
        predicted_epochs = (nf_ll >= threshold_value_nf_ll);
        predicted_seizure_matrix = construct_seizure_info_matrix_from_epochs(predicted_epochs, computed_epoch_fsignal.epoch_timelength);


        % SPECIFIC GAERS
        
        % % Finished the computation
        % predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);

        % %%%%%%% HYPER IMPORTANT OUTPUT
        % time_hours = max(rstime)/3600;

        % if isfield(predicted_seizure_info, 'number_of_seizures')
        %     n_seizures_per_hour = predicted_seizure_info.number_of_seizures/time_hours;
        %     percent_time_spent_in_swd = predicted_seizure_info.time_in_seizure/max(rstime);
        %     %%% Display results
        %     disp(data.filename)
        %     disp(percent_time_spent_in_swd)
        %     disp("%%%%")
        % end
            

        % % IMPORTANT:
        % % if this is a labelled recording, calculate the performance of the
        % % algorithm.
        % if isfield(data, 'seizure_info')
        %     labelled_epochs = create_labelled_epochs(data.seizure_info, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);
        %     predicted_epochs = create_labelled_epochs(predicted_seizure_matrix, computed_epoch_fsignal.number_of_epochs, computed_epoch_fsignal.epoch_timelength);
        %     [accuracy, sensitivity, specificity] = compute_performance(predicted_epochs, labelled_epochs);

        %     predicted_seizure_info = get_seizure_info(predicted_seizure_matrix, data.filename);
        %     labelled_seizure_info = get_seizure_info(data.seizure_info, data.filename);

        %     % visualization:
        %     visualize_analysis(data.filename, computed_epoch_fsignal, nf_ll, predicted_epochs, labelled_epochs, threshold_value_nf_ll);
        %     visualize_analysis_summary(data.filename, labelled_seizure_info, predicted_seizure_info, accuracy, sensitivity, specificity, threshold_value_nf_ll);
        % end

        filenames(h,1) = {data.filename}
        if channel_number==1
            mice(h,1) = {'ka_5-control'};
        elseif channel_number==6
            mice(h,1) = {'ka_2-kainite'};
        elseif channel_number==11
            mice(h,1) = {'ka_1-kainite'};
        end

         
        if isstring(predicted_seizure_matrix)
            seizures(h,1) = {'no seizure'};
        else
            seizures(h,1) = {mat2str(predicted_seizure_matrix)};
        end
        
        % visualize the labelled signal
        % visualize_labelled_recording(fsignal, rstime, predicted_seizure_matrix, strcat(data.filename, string(mice(h,1))));
        
        % increment h
        h = h+1;
    end

end

tt = table(filenames, mice, seizures);

%%%
% Start of auto-labelling script
    
