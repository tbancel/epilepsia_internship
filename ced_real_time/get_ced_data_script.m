% script real time CED (almost real time)
clc; close all;
clear;

approx_epoch_timelength = 1;
threshold_value_nf_ll = 1.8;
number_of_loops = 5;

% à donner
norm_baseline = 1000; 

fs = 1000; % sampling rate = 1kHz
dt=1/fs;

% filter data
f_c = [1 45];
[b, a] = butter(5, 2*f_c*dt, 'pass');

% connect to Master 8 - change to Paradigm 7
Master8=actxserver('AmpiLib.Master8'); % Create COM Automation server
if ~(Master8.Connect),
    h=errordlg('Can''t connect to Master8!','Error');
    uiwait(h);
    delete(Master8); %Close COM
    return;
end;
Master8.ChangeParadigm(7);

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

% Launch the sampling
for i=1:number_of_loops
    
    % collect 1000 pts at 1000 Hz from channel 5 = 2000 bytes,
    % and implies a overall sampling rate of 10000 Hz for ADCMEM = 16x25
    % but just set desired sample rate for ADCBST (5000Hz) = 32x25 (H clock)

    % matced64c('cedSendString','ADCBST,T,0,1000;');  % limit burst rate on Power14
    
    % START SAMPLING:
    % launch the sampling:
    % here we sample channel 5 - 2 bytes - 1000 points - Clock 4kHz
    % Refer to Programmw manual
    matced64c('cedSendString','ADCBST,I,2,0,2000,4,1,H,32,125;');

    if i == 1
        tic
    end
    
    % compute calculation
    if i>1
        fsignal = filtfilt(b, a, data(i-1, :));
        line_length(i-1,1) = feature_line_length(fsignal);
        
        if line_length / norm_baseline > threshold_value_nf_ll
           seizures(i-1,1) = 1;
        end
        
        % analyse the line length in 1
        time_to_compute(i,1) = toc - time_elapsed(i-1,1);
        disp(strcat("Time to compute first sample :", num2str(time_to_compute(i,1))));
        drawnow;
        Master8.Trigger(3);
    end
    
    res=-1;
    % 1401 polling loop, note pause which allows other processing
    % that loop takes approx 1 second, we need to find a way to get
    % everything in real time
    while res ~=0
       matced64c('cedSendString','ADCBST,?;');
       res=eval(matced64c('cedGetString'));

       % disp(strcat("Status of sampling: ", int2str(res)));
       % drawnow; % flushes the event queue
    end
    
    % now get the data, no. of words not bytes
    data(i,:)=matced64c('cedToHost',1000,0);
    time_elapsed(i,1) = toc;
    disp(strcat("Time elapsed: ", num2str(time_elapsed(i,1))));
    drawnow;
    
    % TO DO:
    % we can write this in a buffer and have a second session of matlab to
    % read it using the fieldtrip buffer.
    
    % learn how to parallelize sampling so that we don't lose anything
    % look at PERI32
    % look at the script from Jim Colebatch
    
    % look at how to trigger stimulation using the clock (tomorrow with the
    % connector
end

% res=matced64c('cedCloseX');
% extract the channel data

% reconstruct time thanks to time_elapsed
ideal_time = ones(number_of_loops, 1000).*(1:1000)/1000;
delay = circshift(ones(number_of_loops, 1000).*time_elapsed, 1, 1);
delay(1,:) = 0;
real_time = ideal_time + delay;

realtime = reshape(real_time', [1 numel(real_time)]);
realdata = reshape(data', [1 numel(data)]);

plot(realtime, realdata);