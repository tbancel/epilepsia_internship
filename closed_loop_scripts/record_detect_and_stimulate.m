function output = record_detect_and_stimulate(channel_to_sample, sampling_rate_ced, approx_epoch_timelength, stimulation_recording_time,  norm_baseline, threshold_value_nf_ll, stim_param)
    % script which is called from closed loop
    global executed_stimulation_times;

    %%% SCRIPT RUNNING
    fs = sampling_rate_ced;
    dt = 1/fs;
    n_points_epoch = fs*approx_epoch_timelength;
    number_of_loops = round(stimulation_recording_time/approx_epoch_timelength);
    %%%%%%%%
    % Config for CED sampling 
    % matced64c('cedSendString','ADCBST,kind,byte,start_memory,size_array,chan,n_cycles,clock,pre,count;');
    % str = 'ADCBST,I,2,0,2000,4,1,H,32,125';
    clock = 'H'; % H=4MHz, C=1Mhz, T=10MHz
    pre =32;
    count = 4*10^6/sampling_rate_ced*1/pre;
    kind = 'I';
    n_bytes = 2;
    start_memory = 0;
    size_array = sampling_rate_ced*approx_epoch_timelength*n_bytes;
    chan = channel_to_sample; % 4 = playback from CED recording, 2 = ECoG; 5 = Im;
    rpt = 1;
    n_cycles=1;
    ced_cmd_str = strcat('ADCBST,',kind',',',num2str(n_bytes),',',num2str(start_memory),',',num2str(size_array),',',num2str(chan),',',num2str(n_cycles),',',clock,',',num2str(pre),',',num2str(count),';');
    % END OF CED CONFIG
    %%%%%%%


    %%%%%%
    % OPEN CONNECTION TO MASTER 8
    % connect to Master 8 - change to Paradigm 7
    Master8=actxserver('AmpiLib.Master8'); % Create COM Automation server
    if ~(Master8.Connect)
        h=errordlg('Can''t connect to Master8!','Error');
        uiwait(h);
        delete(Master8); %Close COM
        return;
    end;
    % Change to paradigm7
    Master8.ChangeParadigm(7);
    % END OF MASTER 8 CONNEXION
    %%%%%%

    %%%%%%
    % OPEN CONNEXION TO CED
    % connect to CED - open connection
    res=matced64c('cedOpenX',0);  % v3+ can specify 1401
    if (res > 0)
        disp('error with call to cedWorkingSet - try commenting it out');
        return
    end 
    res=matced64c('cedResetX');
    % load the commend in the 1401 CED:
    matced64c('cedLdX','C:\1401Lang\','ADCMEM','ADCBST');
    res=0;
    % END OF CED CONNECTION
    %%%%%%

    y_scale = 5/(2^(n_bytes*8)/2);
    stimulation_times = [];
    epoch_starts = [];
    t = datetime('now');
    timestr = strcat(num2str(yyyymmdd(t)), '_', num2str(t.Hour), '_', num2str(t.Minute));
    d_wave_timestamps = [];

    % Launch the sampling
    for i=1:number_of_loops
        
        % START SAMPLING:
        % launch the sampling:
        % Refer to Programmw manual
        % matced64c('cedSendString','ADCBST,kind,byte,start_in_memory,n_bytes_array,chan,n_cycles,clock,pre,count;');
        
        % send TTL to CED Recording (Severine) to notify that sampling Starts
        if i == 1
            tic    
            Master8.Trigger(6);
        end
        
        epoch_starts(i,1) = toc;
        matced64c('cedSendString',ced_cmd_str); % really starts sampling here
        
        % compute calculation from the previously sampled epoch
        if i>1
            line_length(i-1,1) = feature_line_length(sampled_data(i-1,:));
            
            % seizure detection
            if line_length(i-1,1) / norm_baseline > threshold_value_nf_ll;
               seizures(i-1,1) = 1;

               switch stim_param.stimulation_position
                   case 'w'
                    output_stimulation = find_waves_and_stimulate(fs, sampled_time, sampled_data, Master8, seizures, stim_param, d_wave_timestamps);
                    d_wave_timestamps = output_stimulation.d_wave_timestamps;
                    internal_frequency(i-1,1) = output_stimulation.internal_frequency;
                   case 's'
                    % todo not precise enough at the moment
                   case 'asap'
                    Master8.Trigger(3);
                    executed_stimulation_times = [executed_stimulation_times; toc];
                end
            else
                seizures(i-1,1)=0;
                internal_frequency(i-1,1) = 0;
            end
            
            % analyse the line length in 1
            time_to_compute(i,1) = toc - time_elapsed(i-1,1);
        end
        
        % Ask the CED if it has finished sampling
        res=-1;
        while res ~=0
           matced64c('cedSendString','ADCBST,?;');
           res=eval(matced64c('cedGetString'));
        end
        
        % As soon as sampling has ended, get the data, no. of words not bytes
        % Save it into the RAM, record the time, display sth and get to next
        % sampling
        sampled_data(i,:)=matced64c('cedToHost', n_points_epoch, 0)*y_scale;       
        sampled_time(i, :) = (1:n_points_epoch)/fs+epoch_starts(i,1);
        time_elapsed(i,1) = toc; % at the end of the epochs

        disp(strcat("Time elapsed: ", num2str(time_elapsed(i,1))));
        drawnow;
        
        if i == number_of_loops
            % send TTL to CED recording to notify that sampling ends
            Master8.Trigger(7)
        end
    

    end
    %%% end of the sampling / stimulation loop.

    % reconstruct time thanks to time_elapsed
    % ideal_time = ones(number_of_loops, n_points_epoch).*(1:n_points_epoch)/fs;
    % delay = circshift(ones(number_of_loops, n_points_epoch).*time_elapsed, 1, 1);
    % delay(1,:) = 0;
    % real_time = ideal_time + delay;
    realtime = reshape(sampled_time', [1 numel(sampled_time)]);
    realdata = reshape(sampled_data', [1 numel(sampled_data)]);


    output.timestr = timestr;
    output.realtime = realtime;
    output.realdata = realdata;
    output.sampling_rate_ced = sampling_rate_ced;

    output.sampled_data = sampled_data;
    output.sampled_time = sampled_time;
    
    output.epoch_ends = time_elapsed;
    output.epoch_starts = epoch_starts;
    output.epoch_length = size(sampled_data, 2);

    output.approx_epoch_timelength = approx_epoch_timelength;
    output.sampled_channel = channel_to_sample;

    output.seizures = [seizures; 0];
    output.norm_baseline = norm_baseline; 
    output.f_line_length = [line_length; 0];
    output.threshold_value_nf_ll = threshold_value_nf_ll;
    output.internal_frequency = [internal_frequency; 0];

    if exist('output_stimulation')
        output.d_wave_timestamps = output_stimulation.d_wave_timestamps;
    else
        output.d_wave_timestamps = [];
    end

    % wait for all timers to execute
    pause(1);
    output.stimulation_timestamps = executed_stimulation_times;

    % stim_vector = zeros(1,size(realtime, 2));
    % for i=1:size(stimulation_times, 2)
    %     start_stim_index = min(find(realtime > stimulation_times(1,i)));
    %     end_stim_index = max(find(realtime < stimulation_times(1,i)+ stimulation_duration));
    %     stim_vector(1,start_stim_index:end_stim_index)=1;
    % end
end