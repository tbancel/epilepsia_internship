% find executed timers

timers = timerfindall;

for j=1:numel(timers)
    t = timers(1,2);
    executed_time(j,1) = t.UserData.executed_stimulation_time
end