function channel_title_map=get_channel_title_map(spike2export_filepath)
    % take a .mat raw export from Spike 2 recording and returns a map of
    % all channel names and title
    
    % filepath must be of the form : 'folder_path/2015_01_13 Neuron 1081.mat'
   
    object = matfile(spike2export_filepath);
    varlist = who(object); % cell object
    
    channel_title_map = containers.Map;

    for index = 1:length(varlist)

        varName = varlist{index};
        channel_struct = object.(varName);
        
        
        % we only want to parse the channels which have a title
        if ~isempty(regexp(varName, 'Ch', 'match')) & isfield(channel_struct, 'title')
            title = channel_struct.title;
            disp(title);
            channel_title_map(title) = varName;
        end
    end

end