%%%% PLOTTING
% plot specific epoch with the peak and wave location

f = visualize_swd_epoch(time_n , epochs(n, :), spikes_timestamps, waves_timestamps, windows);

% Add info to the figure.
% filtered signals
plot(time_n, rs_epochs(n,:), time_n, f_epochs(n,:)); hold on;

% predicted position of spikes and waves
for i=1:numel(p_spikes_timestamps)
    index_i = min(find(p_spikes_timestamps(i) < time_n));
    plot(time_n(1,index_i), epochs(n, index_i), 'g-*'); hold on;
end

for i=1:numel(p_waves_timestamps)
    index_i = min(find(p_waves_timestamps(i) < time_n));
    plot(time_n(1,index_i), epochs(n, index_i), 'g-o'); hold on;
end

% END OF PLOTTING
%%%%%%%%%%%%%%%%%