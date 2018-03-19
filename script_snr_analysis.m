% snr analysis _ whole signal
close all;

% neuron 1523 : bonne détection avec 3.3
% neuron théo 478 : mauvaise détection avec 3.3
% load the neurons...

filename = data.filename;
signal = data.values;
dt = data.interval;
fs = 1/dt;
time = (1:size(signal, 2))*dt;

mu_signal = mean(signal);
sigma_signal = std(signal);
p_signal = rms(signal)^2;

noise = normrnd(mu_signal, sigma_signal, 1, size(signal,2));
% gaussian_noise = wgn(1, size(signal,2), p_signal);

[counts_signal, edges_signal] = histcounts(signal, 100);
[counts_noise, edges_noise] = histcounts(noise, edges_signal);
figure(1)
plot(edges_signal(1:100), counts_signal/sum(counts_signal), edges_noise(1:100), counts_noise/sum(counts_noise))
legend('Signal distribution of amplitude', 'Noise distribution of amplitude')

figure(2)
p1=plot(time, signal); hold on
p2=plot(time, noise)
p2.Color(4) = 0.3;
legend('Signal', 'Noise')

figure(3)
[p_s, f_s] = pwelch(signal, [], 0,[], 1/dt);
[p_n, f_n] = pwelch(noise, [], 0,[], 1/dt);

db_s = 20*log10(p_s);
db_n = 20*log10(p_n);

plot(f_s, db_s, f_n, db_n)
title(erase(data.filename, '_'))


find(db_s > db_n);



