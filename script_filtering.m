% analysis prefiltering:

filename = data.filename;
signal = data.values;
dt = data.interval;
fs = 1/dt;
time = (1:size(signal, 2))*dt;

% resample
rsignal = resample(signal, 1, 30);
dtrs = dt*30;
frs = 1/dtrs;
rs_time = (0:size(rsignal, 2)-1)*dtrs;

% filter
f_1 = 1;
f_2 = 15;
[b, a] = butter(2, 2/frs*[f_1 f_2], 'bandpass');
fsignal = filtfilt(b, a, rsignal);

f1=figure(1)
f1.Name = filename
plot(time, signal, rs_time, rsignal, rs_time, fsignal);
xlabel('Time (s)')
legend('Raw signal', 'Resampled signal', 'Filtered signal');
xlim([0 max(rs_time)])

f2 = figure(2)
f2.Name = filename
subplot(3,1,1)
pwelch(signal, [], 0, [], fs)
title(strcat("Spectogram Raw signal, fs = ", num2str(fs), " Hz"));

subplot(3,1,2)
pwelch(rsignal, [], 0, [], frs); % regarder si les frequence au dessus de 100Hz ont sauté.
title(strcat("Resampled signal, frs = ", num2str(frs), " Hz"));

subplot(3,1,3)
pwelch(fsignal, [], 0, [], frs);
title(strcat("Filtered signal [1 15]Hz, frs = ", num2str(frs), " Hz"));



