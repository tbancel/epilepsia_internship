close all; clc;

dt= data.interval;
time = (1:size(data.values,2))*dt;

seizure_info = data.seizure_info;
n_channel = size(data.values, 1);

% visualize recording on a few channels
f=figure
f.Name = data.filename
for i=1:20
    varname = genvarname(strcat('h',num2str(i)));
    
    eval(strcat(varname, '= subplot(20, 1, i)'));
    plot(time, data.values(i, :));
    if i < 19
        set(gca,'XTick',[]);
    else
        xlabel('Time (s)')
    end
    
    ylabel(data.edf_header.label{i});
    set(get(gca,'YLabel'),'Rotation',0);
    set(gca,'YTick',[]);
    xlim([0 max(time)]);
    
    y_lim = ylim;
    y_min = y_lim(1); y_max = y_lim(2);
    
    for j=1:size(seizure_info, 1)
    	y_box = [y_min y_min y_max y_max];
    	x_box = [seizure_info(j,1) seizure_info(j,2) seizure_info(j,2) seizure_info(j,1)];
    	patch(x_box, y_box, [1 0 0], 'FaceAlpha', 0.1);
    end
end

% linkaxes([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10], 'x');
% clearvars h1 h2 h3 h4 h5 h6 h7 h8 h9 h10

linkaxes([h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16 h17 h18 h19 h20], 'x');
clearvars h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 h16 h17 h18 h19 h20

% predict seizure using one channel
i = 9;
signal = data.values(i, :);
f_cut = 30; % cut all frequencies above 30 Hz
[b, a] = butter(5, 2*f_cut*dt, 'low');
fsignal = filtfilt(b, a, signal);

resampling_rate = 1;
approx_epoch_timelength = 1;
threshold_value = 8;

output = predict_seizures_norm_line_length_threshold(data.filename, fsignal, dt, resampling_rate, approx_epoch_timelength, threshold_value)
f = visualize_recording_with_prediction(fsignal, time, output.crisis_info_matrix, data.filename);


