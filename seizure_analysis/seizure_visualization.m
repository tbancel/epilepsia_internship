% visualize a seizure and the manually labelled component locations (spike
% and wave)
% seizure is a structure with the same fields (like for eeg recording)

close all;
% script to visualize seizure etc.
p_loc = seizure.peak_locations;
w_loc = seizure.wave_locations;

s_time = seizure.time;
s_signal = seizure.signal;

% plotting signal with wave and peak locations
figure
plot(seizure.time, seizure.signal); hold on

% plot peak location
for i=1:size(p_loc, 2)
    p_index(1, i) = max(find(s_time < p_loc(1,i)));
    plot(s_time(p_index(1,i)), s_signal(p_index(1,i)), 'r*'); hold on
end

% plot wave location
for i=1:size(w_loc, 2)
    w_index(1, i) = max(find(s_time < w_loc(1,i)));
    plot(s_time(w_index(1,i)), s_signal(w_index(1,i)), 'g-o'); hold on
end

xlabel('Time (s)')
