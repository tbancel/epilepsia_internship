% WARNING THIS FUNCTION HAS PROBLEMS ON SOME DATA:
% 1106 GAERS S1 2016_09_05 A _M2 does not work, values are split in 2 sub
% arrays.

function spike2export=get_channel_struct_from_spike2file(filepath, channel_number_to_extract, channel_kind)
	% This function returns a structure containing what a Spike2 
	% export of 1 phychannel would look like 

	% INPUTS:

	% OUPUTS: structure corresponding to a channel containing the following fields:
    %
    % - title: title of the channel
    % - values: vector with all values
    % - channel_number: the number of the channel
    %
    % Some fields differ depending on the channel kind (waveform or event, see Spike2 doc)
	% If channel kind = 1 (Waveform)
	% - interval: time interval between each sample point
	% - length: number of datapoints
	% - timevector: time vector with absolute time values in seconds
	% - offset, comments, units, starts: parameters which are similar to what SONGetChannel extracts
    %
	% If channel kind = 3 (Event)
	% - data
    

	% Else : not coded yet

	fid=fopen(filepath);

	% DOES NOT WORK WELL
	% SONImport(fid);
	% SONGetChannel(fid, 2);
	% SONGetChannel(fid, 2, 'mat', 'essai.mat')

	[data, header] = SONGetChannel(fid, channel_number_to_extract, 'scale');

    values = data;

    spike2export.channel_number = channel_number_to_extract;
    spike2export.values = values;
    spike2export.channel_kind = channel_kind;
    spike2export.title = header.title;
    spike2export.comment = header.comment;


	% Converting SON Library export into compatible Spike2 export
	if channel_kind == 1
		sampleinterval = header.sampleinterval;
		timevector = (1:1:header.npoints)*sampleinterval;
		% values = detrend(double(data));
		spike2export.interval = sampleinterval;
		spike2export.length = length(values);
		spike2export.timevector = timevector;
		spike2export.offset = header.offset
		spike2export.units = header.units;
		spike2export.start = header.start;
	end
end

% Import script using the SON Library

% export Spike2
% 1 structure per channel
% which contains field: title, comment, interval, scale, offset, unit,
% start, length, values
% 
% and 1 file structure containing the path of the file

% export SON Library:

% SONImport
% creates a .mat file in the working directory
% containing an ARRAY 'chan21' (of 1 dimension and the number of
% points) and a STRUCTURE 'head21' for each channel.
% 
% 'head2' contains the following fields: sampleinterval, min, max, units,
% interleave, mode, start, stop, comment, title, filename and a few other
% fields
%
% [data, header] = SONGetChannel
% data contains a ARRAY of all values
% header is a structure with following fields: npoints, mode, start, stop,
% sampleinterval, title, comment, etc.