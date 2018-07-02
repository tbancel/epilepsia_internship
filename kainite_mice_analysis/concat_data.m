% run detection algorithm on Kainite mice

start_time = 0; % in seconds from midnight
channel = 7

folder = '/Users/tbancel/Desktop/epilepsia_internship/data/matlab_kainite_24h_recording';
load('names.mat');

whole_signal = []

for i=1:numel(names)
    load(names{i})
    
    if(data.fs == 204.8) 
        whole_signal = [whole_signal data.values(channel,:)];
    else
        continue
    end
end
