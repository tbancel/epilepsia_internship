% Read data from buffer

addpath('/Users/xnavarro/matlab/fieldtrip')
ft_defaults

cfg                = [];
cfg.blocksize      = 1;                            % seconds
cfg.dataset        = 'buffer://localhost:1972';    % where to read the data
ft_realtime_signalviewer(cfg)