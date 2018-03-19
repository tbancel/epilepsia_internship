% Get the recording from a .mat file previously loaded.

% creates variable in the workspace
% - signal (1xN matrix)
% - dt (space time)
% - time (1xN matrix)

%%% !!! WARNING !!!
% HORRIBLE CODE IN THIS PART, NEEDS TO BE WRITTEN IN CLEAN MATLAB
% Look at I/O convention and data loading

object = matfile(filepath);
varlist=who(object);

% Trick because of human errors
index_eeg = find(contains(varlist,'EEG'));
index_end_crisis = find(contains(varlist,'End'));
index_start_crisis = find(contains(varlist,'Onset'));
index_crisis_info_matrix = find(contains(varlist,'crisis_info_matrix'));

% if the loaded data contains Onset / End then we create the crisis info
% matrix
% if it directly contains the crisis_info_matrix, we just load it.

if ~isempty(index_end_crisis) & ~isempty(index_start_crisis)
    onset_crisis = load(filepath, char(varlist(index_start_crisis)));
    end_crisis = load(filepath, char(varlist(index_end_crisis)));
    
    % Create the crisis_info_matrix:
    cell = struct2cell(onset_crisis);
    onset_crisis=cell{1};

    cell = struct2cell(end_crisis);
    end_crisis=cell{1};
    
    % NOT WELL CODED !!
    crisis_info_matrix = [];
    crisis_info_matrix(:,1)=onset_crisis.values;
    crisis_info_matrix(:,2)=end_crisis.values;
    
elseif ~isempty(index_crisis_info_matrix)
    crisis_info_matrix = load(filepath, 'crisis_info_matrix');
    crisis_info_matrix = crisis_info_matrix.crisis_info_matrix;
end

EEG = load(filepath, char(varlist(index_eeg)));
fds = fieldnames(EEG); 
EEG = EEG.(fds{1});

% clearvars -except EEG crisis_info_matrix FileName PathName
% load the signal

signal = (EEG.values);
length = size(signal, 2); % length of data
fs= 1/EEG.interval; % sampling frequency
dt = EEG.interval; % time step

% dt = 0.000360; % in seconds

time = (1:length)*dt; % time vector