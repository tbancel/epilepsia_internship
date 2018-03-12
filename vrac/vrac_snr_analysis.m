% have a raw_signal and dt variables, filename

signal_power = rms(raw_signal)^2;
mu_signal = mean(raw_signal);
sigma_signal = std(raw_signal);

length_signal = size(raw_signal, 2);
timevector = (1:length_signal)*dt;

noise = normrnd(mu_signal, sigma_signal, 1, length_signal);
gaussian_noise = wgn(1, length_signal, signal_power);
[counts, center] = hist(raw_signal, 100);


% questions to understand about noise and SNR
% - power
% 

% f = figure(10)
% f.Name = FileName;
% 
% subplot(3,1,1)
% plot(timevector, raw_signal); 
% 
% subplot(3,1,2)
% plot(timevector, noise);
% 
% subplot(3,1,3)
% plot(timevector, gaussian_noise);

% rng default
% Tpulse = 20e-3;
% Fs = 10e3;
% t = -1:1/Fs:1;
% x = rectpuls(t,Tpulse); %signal
% y = 0.00001*randn(size(x)); %bruit
% s = x + y; % signal bruité
% pulseSNR = snr(x,s-x) % signal to noise ratio between signal, and noise
% 
% % 10*log10 = dB (ou 20*log10)

