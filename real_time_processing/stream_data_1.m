% Fieldtriptbuffer basic usage

ft_defaults

dataname = 'DJ18.eeg';
datafile   = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\eeg_rt\Setup 12-15Hz\DJ18\DJ18.eeg';
headerfile = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\eeg_rt\Setup 12-15Hz\DJ18\DJ18.vhdr';
eventfile  = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\data\eeg_rt\Setup 12-15Hz\DJ18\DJ18.vmrk';


%datafile = '/Users/xnavarro/Downloads/fichier_severine_essai.smr';
%headerfile   = '/Users/xnavarro/Downloads/fichier_severine_essai.S2R';

% % To read all data 
full_header = ft_read_header(headerfile);
full_data = ft_read_data(datafile);

% plot whole data
fs = full_header.Fs;
time = (1:size(full_data,2))/fs;
plot(time, full_data)
xlabel('Time (s)');
title(dataname);
% legend(full_header.label);

% Configure emulated data real-time stream
cfg                      = [];
cfg.blocksize            = 1; % seconds
cfg.channel              = 'all';
cfg.jumptoeof            = 'no';
cfg.readevent            = 'no'; %event type can also be specified; e.g., 'UPPT002')
cfg.fsample              = 250; % sampling frequency

%  The source of the data is configured as
cfg.source.datafile      = datafile;
cfg.source.headerfile    = headerfile;
cfg.source.eventfile     = eventfile;

cfg.source.dataset       = datafile;

% The target to write the data to is configured as
cfg.target.datafile      = 'buffer://localhost:1972'; % default

% ft_realtime_fileproxy(cfg)

% details de la fonction fileproxy

if ~isfield(cfg, 'source'),               cfg.source = [];                                  end
if ~isfield(cfg, 'target'),               cfg.target = [];                                  end
if ~isfield(cfg.source, 'headerformat'),  cfg.source.headerformat = [];                     end % default is detected automatically
if ~isfield(cfg.source, 'dataformat'),    cfg.source.dataformat = [];                       end % default is detected automatically
if ~isfield(cfg.target, 'headerformat'),  cfg.target.headerformat = [];                     end % default is detected automatically
if ~isfield(cfg.target, 'dataformat'),    cfg.target.dataformat = [];                       end % default is detected automatically
if ~isfield(cfg.target, 'datafile'),      cfg.target.datafile = 'buffer://localhost:1972';  end
if ~isfield(cfg, 'minblocksize'),         cfg.minblocksize = 0;                             end % in seconds
if ~isfield(cfg, 'maxblocksize'),         cfg.maxblocksize = 1;                             end % in seconds
if ~isfield(cfg, 'channel'),              cfg.channel = 'all';                              end
if ~isfield(cfg, 'jumptoeof'),            cfg.jumptoeof = 'no';                             end % jump to end of file at initialization
if ~isfield(cfg, 'readevent'),            cfg.readevent = 'no';                             end % capture events?
if ~isfield(cfg, 'speed'),                cfg.speed = inf ;                                 end % inf -> run as fast as possible

% translate dataset into datafile+headerfile
cfg.source = ft_checkconfig(cfg.source, 'dataset2files', 'yes');
cfg.target = ft_checkconfig(cfg.target, 'dataset2files', 'yes');
ft_checkconfig(cfg.source, 'required', {'datafile' 'headerfile'});
ft_checkconfig(cfg.target, 'required', {'datafile' 'headerfile'});

if ~isfield(cfg.source,'eventfile') || isempty(cfg.source.eventfile)
    cfg.source.eventfile = cfg.source.datafile;
end

if ~isfield(cfg.target,'eventfile') || isempty(cfg.target.eventfile)
    cfg.target.eventfile = cfg.target.datafile;
end

% ensure that the persistent variables related to caching are cleared
clear ft_read_header

%%% VERY IMPORTANT
% read the header for the first time
hdr = ft_read_header(cfg.source.headerfile);
fprintf('updating the header information, %d samples available\n', hdr.nSamples*hdr.nTrials);
%%%

% define a subset of channels for reading
cfg.channel = ft_channelselection(cfg.channel, hdr.label); % put an array of cells in the things
chanindx    = match_str(hdr.label, cfg.channel); % index of the channel
nchan       = length(chanindx); % number of channels

if nchan==0
    ft_error('no channels were selected');
end

minblocksmp = round(cfg.minblocksize*hdr.Fs); % 0 if not configured
minblocksmp = max(minblocksmp, 1);
maxblocksmp = round(cfg.maxblocksize*hdr.Fs);
count       = 0;

if strcmp(cfg.jumptoeof, 'yes')
    prevSample = hdr.nSamples * hdr.nTrials;
else
    prevSample  = 0;
end

evt = [];
while true

    % determine number of samples available in buffer
    hdr = ft_read_header(cfg.source.headerfile, 'cache', true);

    % see whether new samples are available
    newsamples = (hdr.nSamples*hdr.nTrials-prevSample);

    if newsamples>=minblocksmp

        begsample  = prevSample+1;
        endsample  = prevSample+min(newsamples,maxblocksmp);

        % remember up to where the data was read
        count       = count + 1;
        fprintf('processing segment %d from sample %d to %d\n', count, begsample, endsample);

        % read data segment
        dat = ft_read_data(cfg.source.datafile,'header', hdr, 'dataformat', cfg.source.dataformat, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx, 'checkboundary', false);

%         size_d = size(dat, 1);
%         for i = 1:size_d
%             plot(dat(i,:));
%             hold on;
%         end

        % it only makes sense to read those events associated with the currently processed data
        if ~strcmp(cfg.readevent,'no')
          evt = ft_read_event(cfg.source.eventfile, 'header', hdr, 'minsample', begsample, 'maxsample', endsample);

          if ~strcmp(cfg.readevent,'yes')
            evt = ft_filter_event(evt, 'type', cfg.readevent);
          end
          
        end

        prevSample  = endsample;

        if count==1
            % the input file may have a different offset than the output file
            offset = begsample - 1;
            % flush the file, write the header and subsequently write the data segment
            ft_write_data(cfg.target.datafile, dat, 'header', hdr, 'dataformat', cfg.target.dataformat, 'chanindx', chanindx, 'append', false);
            if ~strcmp(cfg.readevent,'no')
                for i=1:numel(evt)
                    evt(i).sample = evt(i).sample - offset;
                end
                %%% BIG TIME
                ft_write_event(cfg.target.eventfile,evt,'append',false);
            end
        else
            % write the data segment
            ft_write_data(cfg.target.datafile, dat, 'header', hdr, 'dataformat', cfg.target.dataformat, 'chanindx', chanindx, 'append', true);
            if ~strcmp(cfg.readevent,'no')
                for i=1:numel(evt)
                    evt(i).sample = evt(i).sample - offset;
                end
                ft_write_event(cfg.target.eventfile,evt,'append',true);
            end
        end % if count==1

        % wait for a realistic amount of time
        pause(((endsample-begsample+1)/hdr.Fs)/cfg.speed);

    end % if enough new samples
end % while true

