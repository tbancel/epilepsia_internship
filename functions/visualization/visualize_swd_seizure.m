function f = visualize_swd_seizure(seizure, p_loc, w_loc)
    
    n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);

    s_time = seizure.time;
    s_signal = seizure.signal;


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
end