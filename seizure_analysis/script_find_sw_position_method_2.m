% script_find_sw_position_method_2

% find spikes
diff2_rs_epoch = diff(diff(rs_epochs(n,:)));
[out,idx] = sort(diff2_rs_epoch);
% spike_candidates_position = idx(1:2);

d_spikes_timestamps = [d_spikes_timestamps time_n(idx(1:2))];
p_spikes_timestamps = 1/internal_frequency + d_spikes_timestamps;

d_waves_timestamps_whole_seizure = [d_waves_timestamps_whole_seizure d_waves_timestamps];
p_waves_timestamps_whole_seizure = [p_waves_timestamps_whole_seizure p_waves_timestamps];




if std_epoch(1) > std_epoch(2)
% if std_rs_epoch(1) > std_rs_epoch(2)
    window_type(1:2:(numel(windows)-1)) = 1;
    window_type(2:2:(numel(windows)-1)) = 0;
elseif std_rs_epoch(1) < std_rs_epoch(2)
    window_type(1:2:(numel(windows)-1)) = 0;
    window_type(2:2:(numel(windows)-1)) = 1;
end

% 0. find the orientation of the spike and wave 
% /!\ Discussion with Mark and Séverine to be sure /!\
% find first wave and look at the average 2nd derivative of f_epochs
if mean(mean_diff2_f_epoch(find(window_type == 0))) < 0
    wave_type = 'up';
    multiplier = 1;
else
    wave_type = 'down';
    multiplier = -1;
end
up_down_epochs(n, 1) = multiplier;

% find waves and peaks
% work on the filtered signal between 0.1 and 40Hz

% 1. detected and predicted wave locations (easier to find wave
% location first)
d_waves_timestamps = [];
p_waves_timestamps = [];
wave_windows_index = find(window_type==0);
for i=1:size(wave_windows_index,2)
    [p, wave_locs] = findpeaks(multiplier*windowed_rs_epoch{wave_windows_index(i)});
    if ~isempty(wave_locs)
        wave_locs = wave_locs(1,1);
        d_waves_timestamps = [d_waves_timestamps time_n(windows(1, wave_windows_index(i))+wave_locs)];
        p_waves_timestamps = 1/internal_frequency + d_waves_timestamps;
    end
end
d_waves_timestamps_whole_seizure = [d_waves_timestamps_whole_seizure d_waves_timestamps];
p_waves_timestamps_whole_seizure = [p_waves_timestamps_whole_seizure p_waves_timestamps];

% % 2. detected and predicted spike locations (idem)
% d_spikes_timestamps = [];
% p_spikes_timestamps = [];
% spike_windows_index = find(window_type==1);
% for i=1:size(spike_windows_index, 2)
%     [p, peak_locs] = findpeaks(multiplier*windowed_rs_epoch{spike_windows_index(i)});
%     if ~isempty(peak_locs)
%         peak_locs = peak_locs(1,1);
%         d_spikes_timestamps = [d_spikes_timestamps time_n(windows(1, spike_windows_index(i))+peak_locs)];
%         p_spikes_timestamps = 1/internal_frequency + d_spikes_timestamps;
%     end
% end
% d_spikes_timestamps_whole_seizure = [d_spikes_timestamps_whole_seizure d_spikes_timestamps];
% p_spikes_timestamps_whole_seizure = [p_spikes_timestamps_whole_seizure p_spikes_timestamps];