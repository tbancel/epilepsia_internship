function baselines = gui_get_baseline(data, period)
    % data is the classical data structure
    % period : there is a baseline given at least once every period
    
    dt = data.interval_eeg_s1;
    n_columns = floor(period / dt);
    n_lines = floor(size(data.values_eeg_s1,2)/n_columns);
    
    signal = reshape(data.values_eeg_s1(1:n_columns*n_lines)', n_columns, n_lines)';
    time = reshape(data.timevector_eeg_s1(1:n_columns*n_lines)', n_columns, n_lines)';
    
    for i=1:n_lines
        plot(time(i,:), signal(i,:))
        draw now
        % ask user to identify where the baseline is:
        prompt = 'Time beginning baseline (s):';
        start_baseline = input(prompt);
        prompt = 'Time end baseline (s):';
        end_baseline = input(prompt);
        baselines(i,:) = [start_baseline end_baseline];
    end
end
% label baseline

% take the signal and split it in period of 20 minutes


