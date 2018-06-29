% split seizure in epochs

epoch_duration = 0.2; % 200 ms which is the sampling rate.

s_signal = seizure.signal;
dt = seizure.interval;

epoch_length = floor(epoch_duration/dt);
output_epoch = compute_epoch(s_signal, epoch_length, dt);
epochs = output_epoch.epoched_signal;

% filter signal between 0.1 and 40 Hz
[b, a] = butter(2, 2/fs*[0.1 40], 'bandpass');
rs_epochs = filtfilt(b, a, epochs')';

% filter signal between 6 and 9 Hertz
fs = 1/dt;
[b, a] = butter(2, 2/fs*[6 9], 'bandpass');
f_epochs = filtfilt(b, a, epochs')';


n = 10;
time_n = seizure.time(1,1)+output_epoch.epoch_timestamps(n)+(1:output_epoch.epoch_length)*dt;

figure
plot(time_n, epochs(n, :), time_n, rs_epochs(n,:), time_n, f_epochs(n,:))