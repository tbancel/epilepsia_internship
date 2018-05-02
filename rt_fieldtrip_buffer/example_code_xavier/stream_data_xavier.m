% Fieldtriptbuffer basic usage

addpath('/Users/xnavarro/matlab/fieldtrip')
ft_defaults


datafile   = '/Users/xnavarro/pneumo/DYSPEV/data_OK/Setup 12-15Hz/DJ18/DJ18.eeg';
headerfile = '/Users/xnavarro/pneumo/DYSPEV/data_OK/Setup 12-15Hz/DJ18/DJ18.vhdr';
eventfile  = '/Users/xnavarro/pneumo/DYSPEV/data_OK/Setup 12-15Hz/DJ18/DJ18.vmrk';


%datafile = '/Users/xnavarro/Downloads/fichier_severine_essai.smr';
%headerfile   = '/Users/xnavarro/Downloads/fichier_severine_essai.S2R';

% % To read all data 
%hdr = ft_read_header(filename);
%dat = ft_read_data(datafile);

%dat = ft_read_spike(datafile);


% Configure emulated data real-time stream
cfg                      = [];
cfg.blocksize            = 1; % seconds
cfg.channel              = 'all';
cfg.jumptoeof            = 'no';
cfg.readevent            = 'no'; %event type can also be specified; e.g., 'UPPT002')
cfg.fsample              = 250; % sampling frequency

%  The source of the data is configured as
%cfg.source.datafile      = datafile;
%cfg.source.headerfile    = headerfile;
%cfg.source.eventfile     = eventfile;

cfg.source.dataset       = datafile;

% The target to write the data to is configured as
cfg.target.datafile      = 'buffer://localhost:1972'; % default

ft_realtime_fileproxy(cfg)