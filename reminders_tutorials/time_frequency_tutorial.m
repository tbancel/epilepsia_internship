close all; clear; clc;
% audio time frequency analysis - audio
[tones, Fs] = helperDTMFToneGenerator();

N = numel(tones);
t = (0:N-1)/Fs; 
subplot(2,1,1)
plot(1e3*t,tones)
xlabel('Time (ms)')
ylabel('Amplitude')
title('DTMF Signal')
subplot(2,1,2)
periodogram(tones,[],[],Fs)
xlim([0.65 1.5])
