% essai en temps réel avec tic toc
clc; clear;

% tic
% pause(4);
% output = do_things();
% last = toc;

tic
t1 = timer('TimerFcn', 'stat=false; disp(''Timer!'')', 'StartDelay',3);
start(t1)
stat=true;
get(t1)
while(stat==true)
  disp('.')
  pause(1)
end

t2 = timer;
t2.StartFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
    datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t2.TimerFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
     datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t2.StopFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
    datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t2.Period = 2;
t2.TasksToExecute = 3;
t2.ExecutionMode = 'fixedRate';
start(t2)