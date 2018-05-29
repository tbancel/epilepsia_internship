function output_table = analyze_seizures(data, seizure_info)
	% return the internal frequency
	% return the peak position

    seizure_number = [];
    seizure_starts = [];
    seizure_ends = [];
    seizure_duration = [];
    seizure_internal_frequency = [];

	for i=1:size(seizure_info, 1)
        
        if seizure_info(i,2) - seizure_info(i,1) > 1;
            signal = data.values_eeg_s1;
            dt = data.interval_eeg_s1;
            time = (1:size(signal, 2))*dt;

            seizure_index = find(time > seizure_info(i,1) & time < seizure_info(i,2));

            s_signal = signal(seizure_index);
            s_time = time(seizure_index);

            window_length = floor(1/(dt)); % 1 second windowplot
            [pxx, f_p] = pwelch(s_signal, hamming(window_length), 0,[], 1/(dt));
            [m, k] = max(abs(pxx));
            internal_frequency = f_p(k);

            seizure_number(i,1) = i;
            seizure_starts(i,1) = seizure_info(i,1);
            seizure_ends(i,1) = seizure_info(i,2);
            seizure_duration(i,1) = seizure_info(i,2) - seizure_info(i,1);
            seizure_internal_frequency(i,1) = internal_frequency;
        else
            continue
        end
        
	end

    output_table = table(seizure_number, seizure_starts, seizure_ends, seizure_duration, seizure_internal_frequency);
end