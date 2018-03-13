    clc; clear; close all;
    
    dt = 1/44100;
    
    t=0:dt:(117204*dt)-dt;                    
    x = chirp(t,1500,1,8000);
    S = zeros(501,117);
    
    windowlength = 1e3;
    k = 1;
    
    for jj = 1:117
        y = x(k:k+windowlength-1)'; % le signal pendant 0,0227 seconds
        ydft = fft(y).*gausswin(1e3); % lisser les fréquences hautes et basses
        S(:,jj) = ydft(1:501); % from 0 to windownlength/2
        k = k+windowlength;
    end
    
    t_window = dt*windowlength;
    F = 0:44100/1000:44100/2; % only half of the frequencies
    T = 0:(1e3*dt):(117000*dt)-(1e3*dt);
    
    %% Manual spectogram
    figure(1)
    surf(T,F,20*log10(abs(S)),'EdgeColor','none');
    axis xy; axis tight; colormap(jet); view(0,90);
    c=colorbar;
    c.Label.String = 'dB/Hz/sample';
    xlabel('Time');
    ylabel('Frequency (Hz)');
   
    %% Automatic spectrogram
    % figure(2)
    % spectrogram(x)
    % spectrogram(x, gausswin(10e3), 0, 501, 0:44100/1000:44100/2,44100)
    
    