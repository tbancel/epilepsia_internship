function convert_spike2_file_into_mat_file(filename, filepath)
    % saves in the working directory all the files in the right format
    
    % % INPUTS:
    % - filename
    % - filepath
    % - channel_numbers : array
    % 
    % % OUTPUT - SAVED VARIABLE:
    % - saved under the name filename
    % - contains
    
    fid=fopen(filepath);
    
    relevant_channel_names ={'Vm', 'EEG','EEG S1', 'Puffs', 'To', 'SWD end', 'SWD onset', 'SDW end', 'SDW onset'}; 
    regexp='Vm|EEG|S1|Puffs|To|SWD|SDW';

    channel_map = SONChanList(fid);

    % From Spike 2 doc:
    % Returns A code for the channel type or -3 if this is not a time, XY or result view:
    % 0 None/deleted  6 WaveMark 9 Real wave
    % 1 Waveform 4 Level 7 RealMark 120 XY channel
    % 2 Event (Event-) 5 Marker 8 TextMark 127 Result channel

    extracted_channel_names = {};
   

    for i=1:numel(relevant_channel_names)
        channel_name = relevant_channel_names{i};

        % get channel id for the relevant channel to name (if exists)
        channel_id=find(cellfun(@(x)isequal(x,channel_name),{channel_map.title}));

        if ~isempty(channel_id)
            channel_number=channel_map(channel_id).('number');
            channel_kind = channel_map(channel_id).('kind');
            channel_struct = get_channel_struct_from_spike2file(filepath, channel_number, channel_kind);
            var_channel_name = genvarname(channel_name);
            eval([var_channel_name '= channel_struct;']);
        end
    end

    save(strcat(erase(filename, '.smr'),'.mat'), '-regexp',regexp, 'channel_map');
end