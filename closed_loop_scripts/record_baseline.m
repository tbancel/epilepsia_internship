function output = record_baseline(channel_to_sample, sampling_rate_ced, approx_epoch_timelength, recording_time)
    % Documentation
    
    % INPUT:
    % channel_to_sample : number
    % approx_epoch_timelength in seconds
    % recording_time : in seconds
    % sampling_rate_ced : in Hz, recommended : 1000
    %
    % OUTPUT:
    % output.timestr = string "YYYYMMDD_HH_MM"  (eg: 20180515_16_20) with the beginning of the recording;
    % output.realtime : 1xN vector with all timestamps (there is gap in the real time because of the time lost between each epoch);
    % output.realdata : 1xN vector with all the recording uV points
    % output.sampling_rate_ced : in Hz, configured sampling rate of the CED
    % output.sampled_data : PxM matrix where P is the number of epoch, M the number of data points per epoch
    % output.time_elapsed : Px1 vector where P is the number of epochs, and each value the timestamps of the beginning of the epochs.
    % output.channel_sampled : the channel of the CED that was sampled to get the data.


    % Configure CED Sampling
    fs = sampling_rate_ced;
    dt = 1/fs;
    n_points_epoch = fs*approx_epoch_timelength;
    number_of_loops = round(recording_time/approx_epoch_timelength);

    %%%%%%%%
    % Config for CED sampling 
    % matced64c('cedSendString','ADCBST,kind,byte,start_memory,size_array,chan,n_cycles,clock,pre,count;');
    % str = 'ADCBST,I,2,0,2000,4,1,H,32,125';
    clock_ced = 'H'; % H=4MHz, C=1Mhz, T=10MHz
    pre =32;
    count = 4*10^6/sampling_rate_ced*1/pre;
    kind = 'I';
    n_bytes = 2;
    start_memory = 0;
    size_array = sampling_rate_ced*approx_epoch_timelength*n_bytes;
    chan = channel_to_sample; % 4 = playback from CED recording, 2 = ECoG; 5 = Im;
    rpt = 1;
    n_cycles=1;
    ced_cmd_str = strcat('ADCBST,',kind',',',num2str(n_bytes),',',num2str(start_memory),',',num2str(size_array),',',num2str(chan),',',num2str(n_cycles),',',clock_ced,',',num2str(pre),',',num2str(count),';');
    % END OF CED CONFIG
    %%%%%%%

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

    y_scale = 5/(2^(n_bytes*8)/2);
    epoch_starts = [];
    t = datetime('now');
    timestr = strcat(num2str(yyyymmdd(t)), '_', num2str(t.Hour), '_', num2str(t.Minute));

    % Launch the sampling
    for i=1:number_of_loops
        
        % START SAMPLING:
        % launch the sampling:
        % Refer to Programmw manual
        % matced64c('cedSendString','ADCBST,kind,byte,start_in_memory,n_bytes_array,chan,n_cycles,clock,pre,count;');
        
        if i == 1
            tic
            % send TTL to CED Recording (Severine) to notify that sampling Starts
            Master8.Trigger(6);
        end
        
        epoch_starts(i,1) = toc;
        matced64c('cedSendString',ced_cmd_str); % ask the CED to start sampling
        
        % Ask the CED if it has finished sampling
        % it asks as fast as it can, basically 256Hz (limitation of the USB transmission rate)
        res=-1;
        while res ~=0
           matced64c('cedSendString','ADCBST,?;');
           res=eval(matced64c('cedGetString'));
           % disp(strcat("Status of sampling: ", int2str(res)));
           % drawnow; % flushes the event queue
        end
        
        % As soon as sampling has ended, get the data
        % Save it into the RAM of the computer
        % record the time lost (using toc), display sth to user and get to next sampling
        data(i,:)=matced64c('cedToHost', n_points_epoch, 0)*y_scale;
        time_elapsed(i,1) = toc; % at the end of the epochs
        disp(strcat("Time elapsed: ", num2str(time_elapsed(i,1))));
        drawnow;
        
        if i == number_of_loops
            % send TTL to CED recording to notify that sampling ends
            Master8.Trigger(7)
        end  
    end

    % reconstruct time thanks to time_elapsed
    ideal_time = ones(number_of_loops, n_points_epoch).*(1:n_points_epoch)/fs;
    delay = circshift(ones(number_of_loops, n_points_epoch).*time_elapsed, 1, 1);
    delay(1,:) = 0;
    real_time = ideal_time + delay;

    realtime = reshape(real_time', [1 numel(real_time)]);
    realdata = reshape(data', [1 numel(data)]);

    output.timestr = timestr;
    output.realtime = realtime;
    output.realdata = realdata;
    output.sampling_rate_ced = sampling_rate_ced;

    output.sampled_data = data;
    output.sampled_time = real_time;
    
    output.epoch_ends = time_elapsed;
    output.epoch_starts = epoch_starts;
    output.epoch_length = size(data, 2);

    output.approx_epoch_timelength = approx_epoch_timelength;
    output.sampled_channel = channel_to_sample;
end