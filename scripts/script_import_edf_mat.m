clc; close all; clear;
% convert .edf file into .mat
directory = 'C:\Users\thomas.bancel\Documents\matlab_thomas_internship\data\physionet_database\';
files = {'chb01_03.edf';'chb01_04.edf';'chb01_18.edf';'chb09_06.edf';'chb12_06.edf';'chb12_09.edf';'chb12_42.edf';'chb17a_04.edf';'chb17b_63.edf';'chb23_06.edf'};

for i=1:length(files)
    filename = files{i};
    dat = ft_read_data(strcat(directory, filename));
    hdr = ft_read_header(strcat(directory, filename));

    v=genvarname(erase(filename, '.edf'));

    eval([v '.interval = 1/hdr.Fs;']);
    eval([v '.values = dat;']);
    eval([v '.length = size(dat, 2);']);
    
    save(v, v);
    
end


% define trials
% cfg            = [];
% cfg.dataset    = filename;
% cfg.continuous = 'yes';
% cfg.channel    = 'all';
% data           = ft_preprocessing(cfg);

% visually inspect the data
% cfg            = [];
% cfg.viewmode   = 'vertical';
% ft_databrowser(cfg, data);



