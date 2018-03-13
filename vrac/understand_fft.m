close all; clear; clc;
% analysis frequency :
Fs = 1000;
L = 1500;

t=(1:L)/Fs;

S = 0.7*sin(2*pi*50*t) + 3*cos(2*pi*13*t);
N = 2*randn(size(t));

X = S+N;

% compute FFT:
Y_X = fft(X);
Y_N = fft(N);
Y_S = fft(S);
% frequency axis:
freq = (1:L)*Fs/L;

P_X = abs(Y_X/L);
P_N = abs(Y_N/L);
P_S = abs(Y_S/L);


figure(1)
subplot(3,2,1)
plot(t, S);
xlabel('Time (s)')
title('Signal 0.7*sin(2*pi*50*t) + 3*cos(2*pi*13*t)');

subplot(3,2,2)
plot(freq, P_S);
xlabel('Freq (Hz)')
title('FFT signal')

subplot(3,2,3)
plot(t, N);
xlabel('Time (s)')
title('White Noise Var 4');

subplot(3,2,4)
plot(freq, P_N);
xlabel('Freq (Hz)')
title('FFT noise')

subplot(3,2,5)
plot(t, X);
xlabel('Time (s)')
title('Signal + Noise');

subplot(3,2,6)
plot(freq, P_X);
xlabel('Freq (Hz)')
title('FFT Signal + Noise')




