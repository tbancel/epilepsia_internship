% script to generate txt file Mark.
clc; clear; close all;

folder_path = 'C:\DATA\Fichiers HFO\';
current_path = pwd;
save_folder = 'C:\Users\thomas.bancel\Documents\2018_matlab_thomas_internship\convert_data_mark\saved_txt_files\'

cd(save_folder);
list = dir(folder_path);

for i=4:size(list,1)
    filename = list(i).('name');
    load(strcat(folder_path, filename));
    
    v = who('-regexp', 'Ch1');
    if ~isempty(v)
        str = v{1};

        data = eval(str);

        values = data.values;
        interval = data.interval;
        title = data.title;

        % create .txt file
        % /!\ WARNING : remove if already exists and creates new one
        fid = fopen(strcat(filename, '.txt'), 'wt' );
        fprintf(fid, strcat(title, '\n'));
        fmt = '%f\n';
        for j=1:size(values, 1)
            fprintf(fid, fmt, values(j,1));
        end
        fclose(fid);
        
    end
    
    % clear variables which contains 'VXXXX...' which are values extracted
    % from Spike2
    clearvars -regexp V
    disp(strcat(filename, " treated"));
    draw now
end

cd(current_folder)
