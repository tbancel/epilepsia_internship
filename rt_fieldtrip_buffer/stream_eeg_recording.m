% in this script, I try to understand how the fieldtrip buffer works
% basically, the fieldtrip buffer uses a binary called buffer (a .dll file)
% I don't exactly know how this .dll works, the input and output. I don't manage yet to 
% put the data in the buffer using the binary

% The ultimate goal is to be able to playback a recording in realtime, putting data in the buffer every
% XX ms, and reading in another session the data in the buffer.

% Basically, the fieldtrip buffer is just a header structure and a data file (matrix data)
% The header structure contains all important informations, like sampling rate, what data are in the buffer,
% when it was read for the last time etc.



clear; clc;
% stream_mark_recording
load('20141203_Mark_GAERS_Neuron_1047.mat')

% block size
blocksize = 0.2; % 200 ms window

% configure a few things to make the function ft_write_data work
cfg.blocksize = blocksize;
cfg.fsample = round(1/data.interval_eeg_s1);
cfg.target.datafile      = 'buffer://localhost:1972';

if ~isfield(cfg.target, 'headerformat'),  cfg.target.headerformat = [];                     end % default is detected automatically
if ~isfield(cfg.target, 'dataformat'),    cfg.target.dataformat = [];                       end % default is detected automatically
if ~isfield(cfg.target, 'datafile'),      cfg.target.datafile = 'buffer://localhost:1972';  end

cfg.target = ft_checkconfig(cfg.target, 'dataset2files', 'yes');
ft_checkconfig(cfg.target, 'required', {'datafile' 'headerfile'});

% custom code to make Mark and Theo data go into the pipe
fs = round(1/data.interval_eeg_s1);
blocklength = floor(blocksize*fs);
realblocksize = blocklength / fs;

nsamples = floor(size(data.values_eeg_s1, 2)/blocklength);
data_array = reshape(data.values_eeg_s1(1, 1:(nsamples*blocklength)), [nsamples, blocklength]);

dat = data_array(1, :);

% configure hdr :
% hdr.Fs = fs;
% hdr.nChans = 1;
% hdr.label = {'S1'};
% hdr.nSamples = size(data, 2);

% go into ft_write_data
% variable packet :
% fsample: 1000
% nchans: 5
% nsamples: 1000
% nevents: 0
% data_type: 10
% channel_names: {5×1 cell}
% bufsize: 40000
% buf: [5×1000 double]

% packet:

% type
type = {
      'char'
      'uint8'
      'uint16'
      'uint32'
      'uint64'
      'int8'
      'int16'
      'int32'
      'int64'
      'single'
      'double'
      };
  
  wordsize = {
      1 % 'char'
      1 % 'uint8'
      2 % 'uint16'
      4 % 'uint32'
      8 % 'uint64'
      1 % 'int8'
      2 % 'int16'
      4 % 'int32'
      8 % 'int64'
      4 % 'single'
      8 % 'double'
      };
  
% browse the array and write the data to the buffer
for i=1:(size(data_array, 1)-1)
    tic
    
    % ft_write_data(cfg.target.datafile, dat, 'header', hdr, 'dataformat', cfg.target.dataformat, 'chanindx', chanindx, 'append', true);
    % ft_write_data(cfg.target.datafile, dat, 'dataformat', cfg.target.dataformat, 'append', false);
    % ft_write_data(cfg.target.datafile, dat, 'dataformat', cfg.target.dataformat, 'chanindx', [1], 'append', true);
    
    host = 'localhost';
    port = 1972;
    
    packet.fsample = fs;
    packet.nchans = 1
    packet.nsamples = 555;
    packet.nevents = 0;
    packet.data_type = 10;
    packet.channel_names = {'S1'};
    packet.buf = dat;
    packet.bufsize = numel(dat)* wordsize{find(strcmp(type, class(dat)))};
    
    buffer('put_dat', packet, host, port)
    
    dat = data_array(i+1, :)
    
    t = toc
    % wait to emulate real time processing
    if t < blocksize
        pause(blocksize-t);
    end
end


