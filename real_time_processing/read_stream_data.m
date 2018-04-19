clc; clear;
%%%
% Manually written script
% Read data from buffer

ft_defaults

cfg                = [];
cfg.blocksize      = 1;                            % seconds
cfg.dataset        = 'buffer://localhost:1972';    % where to read the data

% while true
% % try to load the hdr
%     hdr = ft_read_header('buffer://localhost:1972');
%     dat = ft_read_data('buffer://localhost:1972');
%     fs = hdr.Fs;
%     nsample = size(dat, 2);
%     begsample = hdr.nSamples - nsample + 1;
%     endsample = hdr.nSamples;
%     fprintf('processing segment from sample %d to %d\n', begsample, endsample);
% end


% configure the config structure
cfg.dataformat   = ft_getopt(cfg, 'dataformat',   []);      % default is detected automatically
cfg.headerformat = ft_getopt(cfg, 'headerformat', []);      % default is detected automatically
cfg.eventformat  = ft_getopt(cfg, 'eventformat',  []);      % default is detected automatically
cfg.blocksize    = ft_getopt(cfg, 'blocksize',    1);       % in seconds
cfg.overlap      = ft_getopt(cfg, 'overlap',      0);       % in seconds
cfg.channel      = ft_getopt(cfg, 'channel',      'all');
cfg.readevent    = ft_getopt(cfg, 'readevent',    'no');    % capture events?
cfg.bufferdata   = ft_getopt(cfg, 'bufferdata',   'first'); % first or last
cfg.jumptoeof    = ft_getopt(cfg, 'jumptoeof',    'yes');   % jump to end of file at initialization
cfg.demean       = ft_getopt(cfg, 'demean',       'yes');   % baseline correction
cfg.detrend      = ft_getopt(cfg, 'detrend',      'no');
cfg.olfilter     = ft_getopt(cfg, 'olfilter',     'no');    % continuous online filter
cfg.olfiltord    = ft_getopt(cfg, 'olfiltord',    4);
cfg.olfreq       = ft_getopt(cfg, 'olfreq',       [2 45]);
cfg.offset       = ft_getopt(cfg, 'offset',       []);      % in units of the data, e.g. uV for the OpenBCI board
cfg.dftfilter    = ft_getopt(cfg, 'dftfilter',    'no');
cfg.dftfreq      = ft_getopt(cfg, 'dftfreq',      [50 100 150]);

whole_signal = [];

if ~isfield(cfg, 'dataset') && ~isfield(cfg, 'header') && ~isfield(cfg, 'datafile')
  cfg.dataset = 'buffer://localhost:1972';
end

% translate dataset into datafile+headerfile
cfg = ft_checkconfig(cfg, 'dataset2files', 'yes');
cfg = ft_checkconfig(cfg, 'required', {'datafile' 'headerfile'});

% ensure that the persistent variables related to caching are cleared
clear ft_read_header

% start by reading the header from the realtime buffer
% la seule valeur changeant dans le header c'est le nSamples qui augmente
% avec le temps.
hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat, 'cache', true, 'retry', true);

% define a subset of channels for reading
cfg.channel = ft_channelselection(cfg.channel, hdr.label);
chanindx    = match_str(hdr.label, cfg.channel);
nchan       = length(chanindx);

blocksize = round(cfg.blocksize * hdr.Fs);
overlap   = round(cfg.overlap*hdr.Fs);

if strcmp(cfg.jumptoeof, 'yes')
  prevSample = hdr.nSamples * hdr.nTrials;
else
  prevSample = 0;
end

count = 0;

while true
  
  % determine the samples to process
  if strcmp(cfg.bufferdata, 'last')
    % determine number of samples available in buffer
    hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat, 'cache', true);
    begsample  = hdr.nSamples*hdr.nTrials - blocksize + 1;
    endsample  = hdr.nSamples*hdr.nTrials;
  elseif strcmp(cfg.bufferdata, 'first')
    begsample  = prevSample+1;
    endsample  = prevSample+blocksize ;
  else
    ft_error('unsupported value for cfg.bufferdata');
  end
  
  % this allows overlapping data segments
  if overlap && (begsample>overlap)
    begsample = begsample - overlap;
    endsample = endsample - overlap;
  end
  
  % remember up to where the data was read
  prevSample  = endsample;
  count       = count + 1;
  fprintf('processing segment %d from sample %d to %d\n', count, begsample, endsample);
  
  % read data segment from buffer
  dat = ft_read_data(cfg.datafile, 'header', hdr, 'dataformat', cfg.dataformat, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx, 'checkboundary', false, 'blocking', true);

  % make a matching time axis
  time = ((begsample:endsample)-1)/hdr.Fs;
  
  % it only makes sense to read those events associated with the currently processed data
  if strcmp(cfg.readevent, 'yes')
    evt = ft_read_event(cfg.eventfile, 'header', hdr, 'minsample', begsample, 'maxsample', endsample);
  end
  
  whole_signal = [whole_signal dat];
  
  
end % while true*

time_read = size(whole_signal, 2)/hdr.Fs
start_time = prevSample/hdr.Fs - time_read;
time = start_time +(1:size(whole_signal, 2))/hdr.Fs;
plot(time, whole_signal)
xlabel('Time (s)');
title('DJ18.eeg');

% Example de data:
% cfg = 
% 
%   struct with fields:
% 
%        blocksize: 1
%          dataset: 'buffer://localhost:1972'
%       dataformat: 'fcdc_buffer'
%     headerformat: 'fcdc_buffer'
%      eventformat: []
%          overlap: 0
%          channel: {5×1 cell}
%        readevent: 'no'
%       bufferdata: 'first'
%        jumptoeof: 'yes'
%           demean: 'yes'
%          detrend: 'no'
%         olfilter: 'no'
%        olfiltord: 4
%           olfreq: [2 45]
%           offset: []
%        dftfilter: 'no'
%          dftfreq: [50 100 150]
%         datafile: 'buffer://localhost:1972'
%       headerfile: 'buffer://localhost:1972'

% hdr = 
% 
%   struct with fields:
% 
%              Fs: 1000
%          nChans: 5
%        nSamples: 277000
%     nSamplesPre: 0
%         nTrials: 1
%            orig: [1×1 struct]
%           label: {5×1 cell}
%        chantype: {5×1 cell}
%        chanunit: {5×1 cell}
