clear all; clc;

global break_times;
break_times = [];
t = createErgoTimer;
a=1;

tic
start(t);

% delete(timerfindall);

% check next schedule stimulation
% out = timerfind
% out = timerfind('Running', 'on')
% size(out)
% for j=1:numel(out)
%     timer = out(1,j);
% end


function t = createErgoTimer()
    secondsBreak = 1;
    secondsBreakInterval = 3;
    secondsPerHour = 60^2;
    secondsWorkTime = 15;

    t = timer;
    
    % here we can pass a lot to the timer (Master 8,
    % previous_stimulation_time, etc).
    % struct.break_duration = secondsBreak;
    % struct.break_times = [];
    
    user_data.secondsBreak = secondsBreak;
    user_data.executed_times = [];
    
    t.UserData = user_data;
    
    t.StartFcn = @ergoTimerStart;
    t.TimerFcn = @takeBreak;
    t.StopFcn = @ergoTimerCleanup;  
    
    t.Period = secondsBreakInterval+secondsBreak; % 11 seconds.
    t.StartDelay = t.Period-secondsBreak; % 10 seconds
    t.TasksToExecute = ceil(secondsWorkTime/t.Period);
    t.ExecutionMode = 'fixedRate';
end

function ergoTimerStart(mTimer,~)
    user_data = mTimer.UserData;
    
    secondsPerMinute = 60;
    secondsPerHour = 60*secondsPerMinute;
    
    str1 = 'Starting Ergonomic Break Timer.';
    
    str2 = sprintf('For the next %d seconds you will be notified',...
        round(mTimer.TasksToExecute*(mTimer.Period + user_data.secondsBreak)));
    
    str3 = sprintf(' to take a %d second break every %d seconds.',...
        user_data.secondsBreak, (mTimer.Period - user_data.secondsBreak));
    
    disp([str1 str2 str3])
end

function takeBreak(mTimer, ~)
    user_data = mTimer.UserData;
    % str = sprintf('Take a %d second break.', mTimer.UserData);
    str = sprintf('Take a %d second break.', user_data.secondsBreak);
    user_data.executed_times = [user_data.executed_times toc];
    mTimer.UserData = user_data;
    disp(str)
    
    global break_times
    break_times = [break_times toc];
    % disp(toc)
end

function ergoTimerCleanup(mTimer,~)
    disp('Stopping Ergonomic Break Timer.')
    stop(mTimer)
    % delete(mTimer)
    % create an invalid object in the workspace
end

