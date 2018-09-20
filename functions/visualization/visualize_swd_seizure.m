function f = visualize_swd_seizure(seizure, s_loc, w_loc)
    % plot seizure with location of the spike and the waves
    % 
    % TODO: if s_loc or w_loc is not defined, just plot the seizure.
    
    n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);

    s_time = seizure.time;
    s_signal = seizure.signal;


    plot(seizure.time, seizure.signal); hold on

    % plot peak location
    for i=1:size(s_loc, 2)
        p_index(1, i) = max(find(s_time < s_loc(1,i)));
        plot(s_time(p_index(1,i)), s_signal(p_index(1,i)), 'r*'); hold on
    end

    % plot wave location
    for i=1:size(w_loc, 2)
        w_index(1, i) = max(find(s_time < w_loc(1,i)));
        plot(s_time(w_index(1,i)), s_signal(w_index(1,i)), 'g-o'); hold on
    end

    xlabel('Time (s)')
end