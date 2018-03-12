function [downsampled_signal, downsampled_time, downsampled_frequency] = downsample_signal(signal, time, n, fs)
    % NOT USED 
    % NOT FINISHED
    % Signal has to be filtered first
    
    dt=1/fs;
    signal_length=length(signal);
    downsampled_signal_length=floor(signal_length/n);
    
    for i=1:(downsampled_signal_length)
        downsampled_time=time((i-1)*n+1);
        downsampled_signal=signal((i-1)*n+1);
    end
    
    downsampled_frequency=fs/n;
end
